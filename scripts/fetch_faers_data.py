import requests
import json
import time
import pandas as pd
import signal
import sys

# Global flag to indicate if we should stop processing
stop_requested = False

def signal_handler(sig, frame):
    """Handle keyboard interrupt (Ctrl+C)"""
    global stop_requested
    print("\nStop requested. Completing current batch and saving data...")
    stop_requested = True
    # Don't exit immediately - let the main loop complete its current batch

def fetch_adverse_events_data():
    # Set up signal handler for graceful exit
    signal.signal(signal.SIGINT, signal_handler)
    
    # Base URL and query parameters
    base_url = "https://api.fda.gov/drug/event.json"
    search_query = '(patient.drug.openfda.generic_name:"ATORVASTATIN"+OR+patient.drug.openfda.generic_name:"SIMVASTATIN"+OR+patient.drug.openfda.generic_name:"ROSUVASTATIN")+AND+occurcountry:"US"+AND+receivedate:[20200101+TO+20241231]'
    limit = 100
    
    # First request to get total number of results
    print("Making initial request to get total number of records...")
    initial_url = f"{base_url}?search={search_query}&limit={limit}"
    
    try:
        response = requests.get(initial_url)
        
        if response.status_code != 200:
            print(f"Error: {response.status_code}")
            print(response.text)
            return None
        
        data = response.json()
        total_records = data['meta']['results']['total']
        print(f"Total records to fetch: {total_records}")
        
        # Initialize list to store all results
        all_results = data['results']
        
        # Save first batch immediately to start building the CSV
        process_and_save_batch(all_results, "statin_adverse_events.csv", first_batch=True)
        
        # Keep track of total processed records
        total_processed = len(all_results)
        
        # Implement pagination
        skip = limit
        while skip < total_records and not stop_requested:
            print(f"Fetching records {skip} to {skip + limit - 1}...")
            
            paginated_url = f"{base_url}?search={search_query}&limit={limit}&skip={skip}"
            response = requests.get(paginated_url)
            
            if response.status_code == 200:
                data = response.json()
                batch_results = data['results']
                
                # Process and save this batch
                process_and_save_batch(batch_results, "statin_adverse_events.csv", first_batch=False)
                
                skip += limit
                total_processed += len(batch_results)
                
                # Print progress
                progress = (total_processed / total_records) * 100
                print(f"Progress: {progress:.2f}% ({total_processed}/{total_records} records)")
                
            elif response.status_code == 429:  # Rate limit exceeded
                print("Rate limit exceeded. Waiting before retrying...")
                time.sleep(5)  # Wait 5 seconds before retrying
                continue
            else:
                print(f"Error: {response.status_code}")
                print(response.text)
                break
                
            # Add a small delay to avoid hitting rate limits
            time.sleep(0.2)
        
        if stop_requested:
            print(f"\nSuccessfully fetched and processed {total_processed} records before stopping.")
            print(f"This represents {(total_processed / total_records) * 100:.2f}% of the total available data.")
        else:
            print(f"\nSuccessfully fetched and processed all {total_processed} records.")
        
        return True
    
    except KeyboardInterrupt:
        # This is a fallback in case the signal handler doesn't catch it
        print("\nProcess interrupted by user. Data saved up to this point.")
        return True
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return False

def process_and_save_batch(events_batch, filename, first_batch=False):
    """Process a batch of events and append to CSV file"""
    processed_data = []
    
    for event in events_batch:
        # Extract basic event information
        event_info = {
            'report_id': event.get('safetyreportid', ''),
            'receive_date': event.get('receivedate', ''),
            'serious': event.get('serious', ''),  # Added serious field
            'report_country': event.get('primarysourcecountry', ''),
            'occurrence_country': event.get('occurcountry', '')
        }
        
        # Add primary source qualification if available
        if 'primarysource' in event:
            event_info['source_qualification'] = event['primarysource'].get('qualification', '')
        else:
            event_info['source_qualification'] = ''
            
        # Extract patient information
        patient = event.get('patient', {})
        
        # Process drug information
        if 'drug' in patient:
            for drug in patient['drug']:
                drug_info = event_info.copy()
                
                # Get drug details
                drug_info['drug_characterization'] = drug.get('drugcharacterization', '')
                drug_info['medicinal_product'] = drug.get('medicinalproduct', '')
                
                # Extract generic name from openfda if available
                openfda = drug.get('openfda', {})
                drug_info['generic_name'] = openfda.get('generic_name', [''])[0] if openfda.get('generic_name') else ''
                drug_info['brand_name'] = openfda.get('brand_name', [''])[0] if openfda.get('brand_name') else ''
                
                # Extract reaction information
                if 'reaction' in patient:
                    for reaction in patient['reaction']:
                        reaction_info = drug_info.copy()
                        reaction_info['reaction'] = reaction.get('reactionmeddrapt', '')
                        processed_data.append(reaction_info)
                else:
                    # No reaction information available
                    processed_data.append(drug_info)
    
    # Convert to DataFrame and save to CSV (append mode if not first batch)
    if processed_data:
        df = pd.DataFrame(processed_data)
        mode = 'w' if first_batch else 'a'
        header = first_batch
        df.to_csv(filename, mode=mode, index=False, header=header)
        print(f"Batch of {len(processed_data)} records saved to {filename}")
    else:
        print("No data to save in this batch")

if __name__ == "__main__":
    print("Fetching adverse events data for statins from openFDA...")
    print("You can press Ctrl+C at any time to stop the process and save data collected so far.")
    success = fetch_adverse_events_data()
    
    if success:
        print("Data has been saved to statin_adverse_events.csv")
    else:
        print("Failed to fetch data.")