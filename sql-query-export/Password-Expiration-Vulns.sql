-- List of assets with "Password does not expire" type vulnerabilities 
-- Copy the SQL query below

SELECT DISTINCT fa.asset_id, favi.scan_id, lastScan(favi.scan_id), da.ip_address, favi.proof, favi.key
FROM fact_asset AS fa
JOIN fact_asset_vulnerability_instance AS favi ON fa.asset_id = favi.asset_id AND favi.proof LIKE '%Password does not expire%'
JOIN dim_asset AS da ON da.asset_id = favi.asset_id
WHERE favi.key NOT LIKE '%$%' AND lastScan(favi.asset_id) = favi.scan_id
ORDER BY da.ip_address
