--Report that shows the servers (Asset Group) that have actively target MS vulnerabilities with severity
-- copy query below

SELECT fasvi.asset_id, da.host_name, da.ip_address, dv.severity, dos.name, dag.name FROM fact_asset_scan_vulnerability_instance fasvi
JOIN dim_asset da ON (fasvi.asset_id = da.asset_id)
JOIN dim_vulnerability dv ON (fasvi.vulnerability_id = dv.vulnerability_id)
JOIN dim_scan ds ON (fasvi.scan_id = ds.scan_id)
JOIN dim_asset_operating_system daos ON (fasvi.asset_id = daos.asset_id)
JOIN dim_operating_system dos ON (daos.operating_system_id = dos.operating_system_id)
JOIN dim_asset_group_asset daga ON (fasvi.asset_id = daga.asset_id)
JOIN dim_asset_group dag ON (daga.asset_group_id = dag.asset_group_id)
WHERE dag.name LIKE '%servers%' AND dos.name LIKE '%Windows%'
GROUP BY fasvi.asset_id, da.host_name, da.ip_address, dv.severity, dos.name, dag.name
