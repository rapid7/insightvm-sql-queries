-- Report showing scan duration, start and stop times.
-- Copy the SQL query below

SELECT dscan.scan_name, ds.name, dscan.started as "Started", dscan.finished as "Finished", date_trunc('seconds', (finished - started))::TEXT AS duration
FROM fact_site fs
JOIN dim_site ds USING (site_id)
JOIN dim_site_scan dss USING (site_id)
JOIN dim_scan dscan USING (scan_id)
order by ds.name
