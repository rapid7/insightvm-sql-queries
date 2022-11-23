-- Query to show all Obsolete Software vulnerabilities grouped by aggregates of assets affected
-- Copy the SQL query below


SELECT
dv.title AS "Vulnerability Title",
fasvi.proof AS "Proof of Vulnerability",
STRING_AGG(da.host_name,', ') AS "Hosts Affected",
STRING_AGG(da.ip_address,', ') AS "IPs Affected",
count(da.asset_id) AS "Number of Affected Assets",
COALESCE(ds.summary,'Upgrade to latest version') AS "Solution Summary",
min(fasvi.date)::date AS "Discovery Date",
dv.date_published AS "Publish Date",
NOW()::date - min(fasvi.date)::date AS "Age in Days"

FROM fact_asset_scan_vulnerability_instance fasvi

JOIN dim_asset da ON fasvi.asset_id=da.asset_id
JOIN dim_vulnerability dv ON dv.vulnerability_id=fasvi.vulnerability_id
JOIN dim_vulnerability_category dvc ON dv.vulnerability_id=dvc.vulnerability_id
LEFT JOIN dim_solution ds ON dv.nexpose_id=ds.nexpose_id

WHERE dvc.category_name = 'Obsolete Software'

GROUP BY 
dv.title,
fasvi.proof,
ds.summary,
dv.date_published
