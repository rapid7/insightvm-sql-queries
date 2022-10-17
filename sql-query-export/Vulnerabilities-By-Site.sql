-- Vulnerabilities grouped by sites with affected assets in an array.
-- Copy the SQL query below

WITH assets_grouped_by_site_and_vulnerability AS (
SELECT site_id, vulnerability_id, array_to_string(array_agg((ip_address) || (CASE WHEN host_name IS NULL THEN '' ELSE ' (' || host_name || ')' END)), ', ') AS affected_assets
FROM fact_asset_vulnerability_finding
JOIN dim_asset USING (asset_id)
JOIN dim_site_asset USING (asset_id)
GROUP BY site_id, vulnerability_id
)
SELECT ds.name AS "Site Name", dv.title AS "Vulnerability Title", proofAsText(dv.description) AS "Vulnerability Description", affected_assets AS "Affected Assets"
FROM assets_grouped_by_site_and_vulnerability
JOIN dim_vulnerability dv USING (vulnerability_id)
JOIN dim_site ds USING (site_id)
ORDER BY ds.name, title
