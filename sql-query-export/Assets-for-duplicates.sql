-- Lists assets for comparison to determine duplicates.
-- Copy the SQL query below

WITH
ip_counts_by_site AS (SELECT ip_address, COUNT(DISTINCT ds.name) AS sites, array_to_string(array_agg(DISTINCT ds.name), ',') AS site_names
FROM dim_site ds
JOIN dim_site_asset USING (site_id)
JOIN dim_asset USING (asset_id)
GROUP BY ip_address
HAVING COUNT(DISTINCT site_id) > 1)
SELECT ip_address, da.asset_id, da.host_name, site_names
FROM ip_counts_by_site
JOIN dim_asset da USING (ip_address)
ORDER BY ip_address
