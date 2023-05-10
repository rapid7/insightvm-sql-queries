--This query will provide you with the following:

-- IP Address
-- MAC Address
-- Hostname
-- Operating System
-- Risk Score
-- Asset Type
-- Asset ID

-- Copy the SQL query below

WITH asset_info as (select da.asset_id, da.ip_address, da.mac_address, da.host_name, dos.name, dos.asset_type
     FROM dim_asset da
     JOIN dim_operating_system dos USING (operating_system_id))
     SELECT ai.ip_address, ai.mac_address, ai.host_name, ai.name, fa.riskscore, ai.asset_type, ai.asset_id
     FROM fact_asset fa
     JOIN asset_info ai USING (asset_id)
ORDER BY asset_id
