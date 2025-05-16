-- ===========================================
-- I. API Query Verification
-- ===========================================

-- Test Case: Specific Report Lookup
SELECT * FROM ae WHERE report_id = '18619789';

-- ===========================================
-- II. Raw Data Validation Before Cleaning
-- ===========================================

-- Test Case: Row Count in Original Dataset
SELECT COUNT(*) AS total_rows_raw FROM ae;

-- Test Case: Unique Record Count
SELECT COUNT(DISTINCT ROW(
    report_id, receive_date, serious, report_country, occurrence_country,
    source_qualification, drug_characterization, medicinal_product,
    generic_name, brand_name, reaction
)) AS unique_rows FROM ae;

-- ===========================================
-- III. Data Cleaning Queries
-- ===========================================

-- Test Case: Replacing 'NULL' Strings with Actual NULLs
UPDATE ae
SET source_qualification = NULL
WHERE source_qualification = 'NULL';

-- Test Case: Extract Clean Dataset for 2020 Statin Reports
WITH clean AS (
    SELECT DISTINCT report_id, receive_date, serious, report_country, occurrence_country,
           source_qualification, drug_characterization, medicinal_product,
           generic_name, brand_name, reaction
    FROM ae
    WHERE
        receive_date >= '20200101' AND receive_date < '20210101'
        AND (generic_name ILIKE '%SIMVASTATIN%' OR
             generic_name ILIKE '%ATORVASTATIN%' OR
             generic_name ILIKE '%ROSUVASTATIN%')
        AND drug_characterization IS NOT NULL
    ORDER BY report_id
)
SELECT * FROM clean;

-- ===========================================
-- IV. Overall Data Integrity Checks
-- ===========================================

-- Test Case: Total Row Count Verification
SELECT COUNT(*) AS total_rows FROM ae_cleaned;

-- Test Case: Date Range Verification
SELECT MAX(receive_date) AS max_date, MIN(receive_date) AS min_date FROM ae_cleaned;

-- ===========================================
-- V. Dashboard Validation Queries
-- ===========================================

-- Test Case: Most Common Reported Reactions
SELECT reaction, COUNT(*) AS report_count
FROM ae_cleaned
GROUP BY reaction
ORDER BY report_count DESC
LIMIT 15;

-- Test Case: Report Count for March 2020
SELECT COUNT(report_id) AS march_2020_reports
FROM ae_cleaned
WHERE receive_date >= '20200301' AND receive_date < '20200401';

-- Test Case: Source Qualification Breakdown
WITH ae_joined AS (
    SELECT
        r.report_id, r.receive_date,
        r.serious, s.serious_description,
        r.report_country, r.occurrence_country,
        r.source_qualification, sq.qualification_description,
        r.drug_characterization, dc.drug_characterization_description,
        r.medicinal_product, r.generic_name, r.brand_name, r.reaction
    FROM ae_cleaned r
    LEFT JOIN serious_codes s ON r.serious = s.serious
    LEFT JOIN drug_characterization_codes dc ON r.drug_characterization = dc.drug_characterization
    LEFT JOIN source_qualification_codes sq ON r.source_qualification = sq.source_qualification
)
SELECT qualification_description, COUNT(*) AS count
FROM ae_joined
GROUP BY qualification_description
ORDER BY count DESC;

-- Test Case: Serious vs Not Serious Breakdown
WITH ae_joined AS (
    SELECT
        r.report_id, r.receive_date,
        r.serious, s.serious_description,
        r.report_country, r.occurrence_country,
        r.source_qualification, sq.qualification_description,
        r.drug_characterization, dc.drug_characterization_description,
        r.medicinal_product, r.generic_name, r.brand_name, r.reaction
    FROM ae_cleaned r
    LEFT JOIN serious_codes s ON r.serious = s.serious
    LEFT JOIN drug_characterization_codes dc ON r.drug_characterization = dc.drug_characterization
    LEFT JOIN source_qualification_codes sq ON r.source_qualification = sq.source_qualification
)
SELECT serious_description,
       ROUND(COUNT(*) * 100.0 / total.total_count, 2) AS percentage
FROM ae_joined,
     (SELECT COUNT(*) AS total_count FROM ae_joined) AS total
GROUP BY serious_description, total.total_count;

-- ===========================================
-- VI. Muscle-Related Events by Statin
-- ===========================================

-- Atorvastatin
SELECT reaction, COUNT(*) AS count
FROM ae_cleaned
WHERE reaction IN (
    'Blood creatine phosphokinase increased', 'Muscle discomfort', 'Muscle fatigue',
    'Muscle injury', 'Muscle rupture', 'Muscle spasms', 'Muscle strain',
    'Muscular weakness', 'Musculoskeletal pain', 'Musculoskeletal stiffness',
    'Myalgia', 'Myopathy', 'Rhabdomyolysis'
) AND generic_name ILIKE '%atorvastatin%'
GROUP BY reaction
ORDER BY count DESC;

-- Rosuvastatin
SELECT reaction, COUNT(*) AS count
FROM ae_cleaned
WHERE reaction IN (
    'Blood creatine phosphokinase increased', 'Muscle discomfort', 'Muscle fatigue',
    'Muscle injury', 'Muscle rupture', 'Muscle spasms', 'Muscle strain',
    'Muscular weakness', 'Musculoskeletal pain', 'Musculoskeletal stiffness',
    'Myalgia', 'Myopathy', 'Rhabdomyolysis'
) AND generic_name ILIKE '%rosuvastatin%'
GROUP BY reaction
ORDER BY count DESC;

-- Simvastatin
SELECT reaction, COUNT(*) AS count
FROM ae_cleaned
WHERE reaction IN (
    'Blood creatine phosphokinase increased', 'Muscle discomfort', 'Muscle fatigue',
    'Muscle injury', 'Muscle rupture', 'Muscle spasms', 'Muscle strain',
    'Muscular weakness', 'Musculoskeletal pain', 'Musculoskeletal stiffness',
    'Myalgia', 'Myopathy', 'Rhabdomyolysis'
) AND generic_name ILIKE '%simvastatin%'
GROUP BY reaction
ORDER BY count DESC;