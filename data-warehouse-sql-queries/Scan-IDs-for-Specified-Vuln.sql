SELECT ds.scan_id AS Scan_ID, da.ip_address AS Asset_IP, dv.vulnerability_id AS Vuln_ID, dv.title AS Vuln_Title, favi.date AS Vuln_Found_Date
FROM fact_asset_vulnerability_instance favi
JOIN dim_vulnerability dv ON favi.vulnerability_id = dv.vulnerability_id
JOIN dim_asset da ON favi.asset_id = da.asset_id
JOIN fact_asset_event fae ON da.asset_id = fae.asset_id
JOIN dim_scan ds ON fae.scan_id = ds.scan_id
WHERE dv.title LIKE '%Drupal%'
AND favi.asset_id = #####
