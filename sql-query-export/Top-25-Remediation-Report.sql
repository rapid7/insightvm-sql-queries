-- sql version of in product report top 25 remediations  can also adjust number by the number listed below
-- Copy the SQL query below

SELECT DISTINCT
ds.summary AS "Solution",
proofAsText(ds.fix) AS "Fix",
ds.estimate AS "Estimate",
dv.title AS "Vulnerability Title",
da.ip_address AS "IP Address",
da.host_name AS "Host Name",
dacs.aggregated_credential_status_description AS "Access Level",
round(dv.riskscore) AS "Risk Score",
dv.severity AS "Severity",
da.last_assessed_for_vulnerabilities AS "last discovered"
FROM fact_remediation(25, 'riskscore DESC') fr
JOIN dim_solution ds ON (fr.solution_id = ds.solution_id)
JOIN dim_asset_vulnerability_solution davs ON (fr.solution_id = davs.solution_id)
JOIN dim_vulnerability dv USING (vulnerability_id)
JOIN dim_asset da USING (asset_id)
JOIN fact_asset fa USING (asset_id)
JOIN dim_aggregated_credential_status dacs using (aggregated_credential_status_id)
