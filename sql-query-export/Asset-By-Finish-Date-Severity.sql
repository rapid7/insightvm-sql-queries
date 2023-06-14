-- Report that shows the asset details by scan finish date and vulnerability severity
-- Copy the SQL query below
SELECT
    fasvi.scan_id,
    fasvi.asset_id,
    da.host_name,
    da.ip_address,
    dv.severity,
    ds.finished
FROM
    fact_asset_scan_vulnerability_instance fasvi
    JOIN dim_asset da ON (fasvi.asset_id = da.asset_id)
    JOIN dim_vulnerability dv ON (fasvi.vulnerability_id = dv.vulnerability_id)
    JOIN dim_scan ds ON (fasvi.scan_id = ds.scan_id) --WHERE fasvi.scan_id = 'scan id number'
GROUP BY
    fasvi.scan_id,
    fasvi.asset_id,
    da.host_name,
    da.ip_address,
    dv.severity,
    ds.finished
ORDER BY
    ds.finished DESC,
    dv.severity DESC