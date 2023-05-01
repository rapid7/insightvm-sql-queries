-- List of services running on assets.
-- Copy the SQL query below

SELECT DISTINCT da.asset_id, lastScan(da.asset_id) AS last_scan_id, TO_CHAR(dscan.started, 'MM-DD-YYYY') as date , dsite.name AS site, dse.name AS scan_engine, da.ip_address, da.host_name, ds.name AS service_name, fass.port, dsf.name AS service_fingerprint, dsf.version
FROM fact_asset AS fa
JOIN dim_asset AS da USING (asset_id)
JOIN fact_asset_scan_service AS fass USING (asset_id)
JOIN fact_asset_scan AS fas USING (scan_id)
JOIN dim_service AS ds USING (service_id)
JOIN dim_service_fingerprint AS dsf USING (service_fingerprint_id)
JOIN dim_scan AS dscan USING (scan_id)
JOIN dim_site_scan AS dss USING (scan_id)
JOIN dim_site AS dsite USING (site_id)
JOIN dim_site_scan_config AS dssc USING (site_id)
JOIN dim_scan_engine AS dse USING (scan_engine_id) 
WHERE lastScan(da.asset_id) = fas.scan_id
ORDER BY da.asset_id ASC, fass.port ASC
