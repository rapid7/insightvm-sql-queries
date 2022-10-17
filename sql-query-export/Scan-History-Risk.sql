-- Scan History with Risk
-- Copy the SQL query below

SELECT ds.name AS "Site Name", dsc.finished AS "Scan Finished Date", fs.assets AS "Number of Assets", fs.vulnerabilities AS "Number of Vulnerabilities", fs.riskscore AS "Riskscore"
FROM dim_site ds
JOIN dim_site_scan dss USING(site_id)

JOIN dim_scan dsc USING(scan_id)

JOIN fact_scan fs USING(scan_id) ORDER BY started DESC
