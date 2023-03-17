--  list TLS 1.0 vulnerabilities
-- Copy the SQL query below

SELECT DISTINCT ds.name AS "Site", da.ip_address AS "IP Address", da.host_name AS "Host Name", dv.title AS "Vulnerability", favi.date AS "Last Scan Date",
fa.exploits AS "Exploits", fa.malware_kits AS "Malware Kits", round(fa.riskscore::numeric, 0) AS "Total Risk", fa.vulnerabilities_with_malware_kit, fa.vulnerabilities_with_exploit,
round(dv.cvss_score::numeric, 2) AS cvss_score, dv.exploits AS "Vulnerability Exploit", dv.malware_kits AS "Vulnerability Malware Kits"
FROM fact_asset_vulnerability_instance favi
JOIN dim_asset da USING (asset_id)
JOIN dim_vulnerability dv USING (vulnerability_id)
JOIN dim_site_asset dsa USING (asset_id)
JOIN dim_site ds USING (site_id)
JOIN fact_asset fa USING (asset_id)
WHERE dv.title LIKE 'TLS/SSL Server Supports SSLv3' OR dv.title LIKE 'TLS Server Supports TLS version 1.0'
ORDER BY dv.title, ds.name, da.ip_address
