-- List all asset groups along with asset hostnames and IP addresses as well as indicate whether the asset group is dynamic(true) or static(false)
-- Copy the SQL query below

SELECT distinct(da.ip_address) AS "IP Address", da.host_name AS "Hostname", dag.name AS "Asset Group Name", dag.dynamic_membership AS "Dynamic (True)/ Static (False)"
FROM fact_asset_group fag
JOIN dim_asset_group dag USING (asset_group_id)
JOIN dim_asset_group_asset daga USING (asset_group_id)
JOIN dim_asset da USING (asset_id)
ORDER BY dag.name
