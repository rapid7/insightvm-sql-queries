-- List assets by software in this case "Chrome" 
-- Copy the SQL query below

SELECT da.ip_address, da.host_name, ds.vendor, ds.name as software_name,  ds.family, ds.version
FROM dim_asset_software das
JOIN dim_software ds using (software_id)
JOIN dim_asset da on da.asset_id = das.asset_id
where ds.name ilike '%chrome%'
