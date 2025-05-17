# Visualizing Statin Safety: Creating an Adverse Event Dashboard Using OpenFDA (FAERS) Data

## From Raw Data to Meaningful Insights (and Some Warnings!)

### Introduction

Drug safety is crucial. Once a drug is on the market, real-world data is needed to ensure it remains safe. One valuable source for such data is the **FDA Adverse Event Reporting System (FAERS)**. But raw FAERS data can be overwhelming.

This project focuses on visualizing FAERS data for **statins** — a common class of cholesterol-lowering drugs — using **OpenFDA’s public API** and a dashboard built in **Tableau**.

---

## Why Statins? Why a Dashboard?

Statins (e.g., Atorvastatin, Simvastatin, Rosuvastatin) are widely used, so ongoing safety monitoring is essential.

### Why a Dashboard?

Raw FAERS data is hard to interpret.

A dashboard helps users:

- Visualize report trends  
- Identify common side effects  
- Assess seriousness and source of reports  
- Focus on specific issues (e.g., muscle-related side effects)

---

## About the Data: OpenFDA FAERS

The FAERS database provides:

- Patient demographics  
- Drug names  
- Side effects (coded with MedDRA)  
- Reporter identity  
- Seriousness of the event  

### Limitations to Remember:

- Voluntary reporting → incomplete data  
- Reporting bias due to media or public concern  
- No causality — a report ≠ proof  
- Duplicates and errors exist  
- No denominator — we don't know how many people took the drug safely  

---

## Project Steps

### 1. Focus Definition

- **Drugs:** Atorvastatin, Simvastatin, Rosuvastatin (and combinations)  
- **Region:** U.S. only  
- **Timeframe:** Jan 1 – Dec 31, 2020  

**Key Questions:**

- How many reports over time?  
- Most common side effects?  
- Proportion of serious reports?  
- Who reported them?  
- Muscle-related side effects by statin?

---

### 2. Data Collection (Python + API)

- Used `requests` to access OpenFDA API  
- Built queries with pagination  
- Saved progress during interruptions  

---

### 3. Data Extraction (Python + Pandas)

- Parsed JSON output  
- Extracted fields:  
  - Report ID  
  - Date  
  - Seriousness  
  - Reporter  
  - Drug name  
  - Side effects  
- Saved as CSV  

---

### 4. Data Cleaning (PostgreSQL)

- Removed **253,570 duplicate records**  
- Filtered for 2020 only  
- Focused on primary suspect statins  
- Removed rows with:  
  - Unrelated drugs  
  - Missing `drug_characterization`  
  - Misformatted `source_qualification`  

---

### 5. Dashboard Creation (Tableau)

- Connected Tableau to cleaned CSV  
- Created visualizations:  
  - Line chart (trend)  
  - Heatmap (side effects)  
  - Pie charts (seriousness, reporters)  
  - Bar chart (muscle issues per statin)  
- Grouped name variants using calculated fields  
- Added filters and a disclaimer  

---

## Final Dashboard Highlights

- Trends in adverse event reports  
- Top side effects like fatigue and kidney issues  
- Breakdown of serious vs. non-serious events  
- Source: patients vs. professionals  
- Comparison of muscle-related issues across statins  

🔗 **Interactive Tableau Dashboard**: [FAERS_Statin](https://public.tableau.com/app/profile/ullas.aradhya/viz/FAERS_Statin/Dashboard1?publish=yes)

---

## Key Learnings

- **APIs need care**: especially for pagination and errors  
- **Data cleaning is critical**  
- **Proper interpretation avoids misleading insights**  
- **Right tools (Python + Tableau) make the job smoother**

---

## Limitations

This dashboard is exploratory and not meant to:

- Prove causality  
- Measure actual risk or incidence  
- Make drug comparisons without further analysis  

---

## Final Thoughts

This project was a great learning experience in real-world healthcare analytics. It taught me:

- How to handle messy health data  
- The power of visual storytelling  
- The importance of caution in public health reporting  

**Next steps:**

- Add more drugs and years  
- Explore methods like **disproportionality analysis**

**Medium article**: [Visualizing Statin Safety: Creating an Adverse Event Dashboard Using OpenFDA (FAERS) Data](https://medium.com/@ullas97/visualizing-statin-safety-creating-an-adverse-event-dashboard-using-openfda-faers-data-e744070e6fde)