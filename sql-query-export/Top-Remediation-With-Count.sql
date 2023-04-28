-- This query will provide you with the following:
-- Solution Summary
-- Asset Count
-- Vulnerability Count
-- Risk Score
-- Exploit Count
-- Malware Count

-- Copy the SQL query below

SELECT  ds.summary as solution_summary, fr.assets as asset_count, fr. vulnerabilities as vulns_count, fr.riskscore,fr.exploits as exploits_count, fr.malware_kits as malware_count
FROM fact_remediation(2147483647, 'riskscore DESC') fr
JOIN dim_solution ds on ds.solution_id = fr.solution_id 
Order by fr.riskscore desc
