-- Software Inventory
-- Copy the SQL query below
SELECT
    DISTINCT fass.asset_id,
    da.ip_address,
    da.host_name,
    ds.vendor,
    ds.name,
    ds.version
FROM
    fact_asset_scan_software as fass
    JOIN dim_asset AS da ON da.asset_id = fass.asset_id
    JOIN dim_software AS ds ON ds.software_id = fass.software_id
WHERE
    ds.vendor != 'Ubuntu'