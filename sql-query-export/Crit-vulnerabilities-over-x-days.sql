-- All assets with Critical Vulnerabilities
-- Copy the SQL query below

WITH assets_grouped_by_site_and_vulnerability AS (
SELECT site_id, vulnerability_id, first_discovered, age_in_days, array_to_string(array_agg((ip_address) || (CASE WHEN host_name IS NULL THEN '' ELSE ' (' || host_name || ')' END)), ', ') AS affected_assets
FROM fact_asset_vulnerability_age
JOIN dim_asset USING (asset_id)
JOIN dim_site_asset USING (asset_id)
GROUP BY site_id, vulnerability_id, first_discovered, age_in_days)
SELECT ds.name AS "Site Name", dv.title AS "Vulnerability Title", dv.severity, age_in_days AS "Vulnerability age", affected_assets AS "Affected Assets"
FROM assets_grouped_by_site_and_vulnerability
JOIN dim_vulnerability dv USING (vulnerability_id)
JOIN dim_site ds USING (site_id)
WHERE dv.severity LIKE '%Critical%' and first_discovered < (NOW() - INTERVAL '30 days')
ORDER BY ds.name, dv.title
