-- Most Critical assets by severity and age.
-- Copy the SQL query below

SELECT fa.asset_id, da.ip_address, da.host_name, dv.nexpose_id, dv.title, dv.severity, dv.cvss_score, dv.exploits, dv.malware_kits, TO_CHAR(fava.first_discovered, 'MM-DD-YYYY') AS first_discovered_date, TO_CHAR(max_date, 'MM-DD-YYYY') AS last_discovered_date, fava.age_in_days
FROM fact_asset AS fa
JOIN dim_asset AS da ON fa.asset_id = da.asset_id
JOIN fact_asset_vulnerability_finding AS favf ON fa.asset_id = favf.asset_id
JOIN (
        SELECT vulnerability_id, nexpose_id, title, severity, cvss_score, exploits, malware_kits
        FROM dim_vulnerability
        WHERE (severity = 'Critical') AND (exploits >= 1 OR malware_kits >= 1)
        ) AS dv
ON dv.vulnerability_id = favf.vulnerability_id
JOIN (
        SELECT asset_id, vulnerability_id, first_discovered, MAX(most_recently_discovered) AS max_date, age_in_days
        FROM fact_asset_vulnerability_age AS fava
        WHERE age_in_days > 0
        GROUP BY asset_id, first_discovered, vulnerability_id, age_in_days
        ) AS fava
ON fa.asset_id = fava.asset_id
WHERE lastScan(fa.asset_id) = favf.scan_id
GROUP BY fa.asset_id, da.ip_address, da.host_name, favf.scan_id, dv.nexpose_id, dv.title, dv.severity, dv.cvss_score, dv.exploits, dv.malware_kits, fava.first_discovered, fava.max_date, fava.age_in_days
ORDER BY fa.asset_id, dv.cvss_score DESC, fava.age_in_days DESC
