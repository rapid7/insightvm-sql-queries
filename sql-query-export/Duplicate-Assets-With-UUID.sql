-- Duplicate Asset with UUID
-- The query will provide the following:   asset_id, uuid, source, ip_address, mac_address, host_name, sites

-- Copy the SQL query below

SELECT dauid.asset_id, MAX(dauid.unique_id) as uuid, MAX(dauid.source) AS source, da.ip_address, da.mac_address, da.host_name, da.sites 
FROM dim_asset_unique_id dauid
JOIN dim_asset da USING (asset_Id)
WHERE unique_Id in (SELECT unique_Id FROM (SELECT unique_Id, count(*)
FROM dim_asset_unique_id
GROUP BY unique_Id having count(*) >1) AS dupes)
GROUP BY dauid.asset_id, da.ip_address, da.mac_address, da.host_name, da.sites 
ORDER BY uuid
