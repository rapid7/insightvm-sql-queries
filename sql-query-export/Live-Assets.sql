-- Live Assets
-- Copy the SQL query below
WITH latest_scan AS (
    SELECT
        dss.site_id,
        max(dss.scan_id) as last_scan
    FROM
        dim_site_scan AS dss
    GROUP BY
        dss.site_id
),
assets AS (
    SELECT
        ls.site_id,
        ls.last_scan,
        count(das.asset_id) as assets
    FROM
        latest_scan AS ls
        JOIN dim_asset_scan AS das ON das.scan_id = ls.last_scan
    GROUP BY
        ls.site_id,
        ls.last_scan
)
SELECT
    ds.name AS Site,
    assets.assets
FROM
    assets AS assets
    JOIN dim_site AS ds ON ds.site_id = assets.site_id
ORDER BY
    Site