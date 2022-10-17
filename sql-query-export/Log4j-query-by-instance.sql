-- Log4j query by instance
-- Copy the SQL query below

SELECT favi.date, da.ip_address, da.host_name, dos.name AS "OS", favi.scan_id, favi.key, dvs.description AS "Status"
FROM fact_asset_vulnerability_instance favi
JOIN dim_asset da USING (asset_id)
JOIN dim_operating_system dos USING (operating_system_id)
JOIN dim_vulnerability dv USING (vulnerability_id)
JOIN dim_vulnerability_status dvs USING (status_id)
WHERE dv.nexpose_id LIKE '%apache-log4j-core-cve-2021-44228%'
ORDER BY favi.date ASC, da.host_name ASC
