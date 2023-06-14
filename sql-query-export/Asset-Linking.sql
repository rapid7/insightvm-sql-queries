-- Estimates for Asset linking
-- Copy the SQL query below
WITH ip_counts_by_site AS (
    SELECT
        da.mac_address,
        da.host_name,
        ip_address,
        COUNT(DISTINCT ds.name) AS sites,
        array_to_string(array_agg(DISTINCT ds.name), ',') AS site_names
    FROM
        dim_site ds
        JOIN dim_site_asset USING (site_id)
        JOIN dim_asset da USING (asset_id)
    GROUP BY
        host_name,
        ip_address,
        mac_address
    HAVING
        COUNT(DISTINCT site_id) > 1
)
SELECT
    host_name,
    ip_address,
    mac_address,
    sites,
    site_names
FROM
    ip_counts_by_site
ORDER BY
    sites DESC