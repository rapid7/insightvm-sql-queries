-- list the usernames present in the asset
-- Copy the SQL query below

SELECT ds. NAME AS site, da.ip_address, da.host_name, daua."name" AS user_account_name, daua.full_name AS user_account_full_name, dos.name AS os, dos.version AS os_ver 
FROM dim_asset AS da
JOIN dim_asset_operating_system AS daos ON da.asset_id = daos.asset_id
JOIN dim_operating_system AS dos ON daos.operating_system_id = dos.operating_system_id
JOIN dim_site_asset AS dsa ON da.asset_id = dsa.asset_id
JOIN dim_site AS ds ON dsa.site_id = ds.site_id
JOIN dim_asset_user_account AS daua ON da.asset_id = daua.asset_id
GROUP BY ds. NAME, da.ip_address, da.host_name, daua."name", daua.full_name, dos.name, dos.version
