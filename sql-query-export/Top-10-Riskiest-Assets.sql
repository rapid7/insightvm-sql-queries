-- This query will provide you with the following:

-- Asset ID
-- Host Name
-- Risk Score
-- Total Vulnerabilities
-- Malware Count
-- Exploit Count

-- Copy the SQL query below

SELECT da.asset_id AS asset_id, da.host_name AS Hostname, da.ip_address AS IP, fa.riskscore AS riskscore,
   fa.vulnerabilities AS total_vulns, fa.malware_kits AS malware_count, fa.exploits AS exploit_count
FROM fact_asset fa
JOIN dim_asset da ON da.asset_id = fa.asset_id
WHERE fa.riskscore > 0
ORDER BY fa.riskscore DESC
LIMIT 10
