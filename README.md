# Visualizing Statin Safety: An Adverse Event Dashboard with OpenFDA Data

This project explores adverse event data for commonly prescribed statin medications (Atorvastatin, Simvastatin, Rosuvastatin) using the FDA Adverse Event Reporting System (FAERS) accessed via the OpenFDA API. The primary goal was to develop an interactive dashboard to visualize reporting trends, common issues, and specific safety topics like muscle-related events, while emphasizing the importance of understanding the limitations of FAERS data.

---

**Live Project Links:**

*   **Interactive Tableau Dashboard:** [FAERS_Statin](https://public.tableau.com/app/profile/ullas.aradhya/viz/FAERS_Statin/Dashboard1?publish=yes)

---

## Table of Contents

*   [Project Goal](#project-goal)
*   [Data Source](#data-source)
*   [Technologies Used](#technologies-used)
*   [Methodology & Pipeline](#methodology--pipeline)
*   [Dashboard Features](#dashboard-features)
*   [Key Findings (Interpreted with Caution)](#key-findings-interpreted-with-caution)
*   [FAERS Data Limitations (Important!)](#faers-data-limitations-important)
*   [Repository Structure](#repository-structure)
*   [Setup & Usage](#setup--usage)
*   [Validation](#validation)
*   [Future Enhancements](#future-enhancements)
*   [Contact](#contact)

## Project Goal

The objective of this project was to:
1.  Retrieve and process adverse event data related to specific statin medications from the OpenFDA FAERS API.
2.  Develop an interactive Tableau dashboard to visualize key metrics, trends, and comparisons from this data.
3.  Highlight the critical limitations of FAERS data and promote responsible interpretation.
4.  Demonstrate an end-to-end data analysis pipeline, from data acquisition to visualization and validation.

## Data Source

*   **Source:** FDA Adverse Event Reporting System (FAERS)
*   **Access:** OpenFDA API (`drug/event` endpoint) - [https://open.fda.gov/apis/drug/event/](https://open.fda.gov/apis/drug/event/)
*   **Scope:**
    *   **Drugs:** Reports mentioning Atorvastatin, Simvastatin, or Rosuvastatin (including combination products and salt forms).
    *   **Region:** Reports occurring in the United States (US).
    *   **Timeframe:** Reports received by the FDA from January 1, 2020, to December 31, 2020.

## Technologies Used

*   **Data Acquisition & Processing:** Python (`requests`, `pandas`)
*   **Data Validation:** PostgreSQL
*   **Data Visualization:** Tableau Public
*   **Version Control:** Git & GitHub
*   **Reporting/Documentation:** Medium

## Methodology & Pipeline

1.  **Data Acquisition (Python):**
    *   The `scripts/fetch_faers_data.py` script queries the OpenFDA API.
    *   It filters data based on the defined drug names, occurrence country (US), and receive date range.
    *   Handles API pagination (`skip`/`limit`) to retrieve all relevant records.
2.  **Data Cleaning & Preparation (Python & Tableau):**
    *   The Python script parses the JSON response and extracts relevant fields.
    *   Initial data cleaning steps like handling duplicates and ensuring specific fields are not null were performed via SQL queries (as documented in the validation section, resulting in `ae_cleaned.csv`).
    *   The final cleaned dataset (`data/ae_cleaned.csv`) serves as the primary data source for Tableau.
    *   A calculated field (`Statin Group`) was created in Tableau to group variations of statin names (e.g., "ATORVASTATIN CALCIUM," "AMLODIPINE AND ATORVASTATIN") into "Atorvastatin," "Simvastatin," and "Rosuvastatin" for accurate analysis.
3.  **Data Validation (PostgreSQL):**
    *   The cleaned CSV data was loaded into a PostgreSQL database.
    *   SQL queries were written to independently recalculate all metrics and figures displayed on the dashboard.
    *   Results from SQL were compared against the Tableau dashboard to ensure data correctness (see `validation/validation_queries.sql`).
4.  **Visualization (Tableau):**
    *   The Tableau packaged workbook (`tableau/FAERS_Statin.twbx`) connects to the cleaned data.
    *   Interactive charts and filters were built to address the project's key questions.

## Dashboard Features

The interactive dashboard allows users to explore:
*   **Most Common Reported Issues:** A heatmap displaying the top MedDRA Preferred Terms.
*   **Overall Reporting Trends:** Line chart showing the volume of reports over time.
*   **Seriousness Breakdown:** Pie chart showing serious vs. non-serious reports.
*   **Source Breakdown:** Pie chart illustrating the qualification of the primary reporter.
*   **Muscle-Related Event Analysis:** Grouped bar chart comparing the frequency of specific muscle-related adverse events across Atorvastatin, Simvastatin, and Rosuvastatin.
*   **Interactive Filters:** Users can filter the entire dashboard by `Reaction term`, `Drug Characterization Description`, `Receive Date`, `Statin Group` and `Qualification Description`.

![image](https://github.com/user-attachments/assets/3536c9a5-35ca-47e3-aa99-227f37d6755c)

![image](https://github.com/user-attachments/assets/8d4f7be2-7266-469b-8345-fb77e1fb3639)


## Key Findings (Interpreted with Caution)

*   During the January-December 2020 period for US reports, Fatigue, Death and Pain were among the most frequently reported terms alongside the selected statins.
*   The muscle-related event analysis indicated that Myalgia and Muscle Spasms were commonly reported muscle-related terms for all three statins, with varying reported frequencies across the drugs.
*   **It is crucial to reiterate that these are observations from reported data and do not imply causality or a definitive safety profile.**

## FAERS Data Limitations (Important!)

This analysis uses FAERS data, which has inherent limitations:
*   **Spontaneous Reporting System:** Not all adverse events are reported (under-reporting).
*   **Reporting Biases:** Reporting can be influenced by various factors (e.g., length of time a drug is on the market, media attention, severity of the event).
*   **Correlation, Not Causation:** Reports indicate an association between a drug and an event, **not** that the drug caused the event.
*   **Data Quality:** Reports can be incomplete or contain inaccuracies.
*   **No Denominator:** The data does not include the total number of patients taking the drug, so true incidence rates or risks **cannot** be calculated.
*   **Counts Are Not Directly Comparable for Safety:** Higher report counts for one drug over another do not necessarily mean one drug is less safe. Usage rates, time on market, and reporting biases play significant roles.

**This dashboard is an exploratory tool for observing reporting patterns and should not be used for clinical decision-making or definitive safety assessments.**

## Repository Structure

<pre>
<code>
├── README.md                     # This file
├── scripts/
│   ├── fetch_faers_data.py       # Python script for OpenFDA API data acquisition
│   └── requirements.txt          # Python dependencies
├── data/
│   ├── ae_cleaned.csv            # Cleaned dataset used for Tableau (102,356 rows for 2020 US data)
│   ├── serious_codes.csv         # Dimension table for seriousness codes
│   ├── source_qualification_codes.csv  # Dimension table for reporter qualification codes
│   └── drug_characterization_codes.csv # Dimension table for drug characterization codes
├── tableau/
│   ├── FAERS_Statin.twbx         # Packaged Tableau workbook (data is embedded)
│   └── dashboard_screenshots/    # Screenshots of the dashboard
├── validation/
│   ├── validation_summary.md     # Summary of the data validation process
│   ├── validation_queries.sql    # SQL queries used for validation against PostgreSQL
│   └── validation_evidence/      # Snippets of validation evidence
└── report/
    └── medium_article.md         # Markdown version of the detailed blog post
</code>
</pre>


## Setup & Usage

**1. Python Script (Data Acquisition):**
   *   Ensure Python (latest version) is installed.
   *   Navigate to the `scripts/` directory.
   *   Install dependencies: `pip install -r requirements.txt`
   *   Run the script: `python fetch_faers_data.py`
   *   *(Note: The script is configured to fetch data for 2020-2024 for US reports on Atorvastatin, Simvastatin, and Rosuvastatin. This may take a significant amount of time due to API calls and data volume.)*
   *   The primary output used for this project's dashboard is `data/ae_cleaned.csv`, which was generated for the 2020 scope (102,356 rows) after specific SQL-based cleaning steps detailed in the validation documents. The provided script will generate a more comprehensive raw dataset if run for the full 2020-2024 range.

**2. Tableau Dashboard:**
   *   Open the `tableau/FAERS_Statin.twbx` file using Tableau Desktop or Tableau Reader.
   *   The data (based on `data/ae_cleaned.csv` for the 2020 scope) is embedded within the packaged workbook.
   *   Alternatively, connect Tableau to the `data/ae_cleaned.csv` (or the output of your own script run) and the provided dimension tables (`serious_codes.csv`, etc.) to rebuild or explore.

**3. Validation Database (PostgreSQL):**
   *   If you wish to replicate the validation, you will need a PostgreSQL instance.
   *   Create a table (schema provided in `validation/validation_queries.sql` or the testing plan).
   *   Load the `data/ae_cleaned.csv` into the table using the `COPY` command.
   *   Run the queries from `validation/validation_queries.sql`.

## Validation

A rigorous validation process was conducted by loading the cleaned dataset into PostgreSQL and writing SQL queries to independently verify all metrics and chart data points displayed on the Tableau dashboard. This ensured data accuracy and integrity. See the `validation/` folder for detailed SQL queries and a summary of the process. Refer the documents in `validation_evidence/` for evidences

## Future Enhancements

*   Expand the date range to include more historical data.
*   Incorporate additional relevant drug classes for comparison.
*   Explore basic disproportionality analysis (e.g., PRR) as a screening tool, with appropriate caveats.
*   Automate the data pipeline for periodic updates.

## Contact

*   **Name:** Ullas Aradhya
*   **LinkedIn:** www.linkedin.com/in/ullas-aradhya
*   **GitHub:** https://github.com/ullas-aradhya

---
