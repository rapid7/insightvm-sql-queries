-- New and Remediated Vulns with Vuln details
-- Copy the SQL query below

WITH
assets_vulns AS (
	SELECT
		fasv.asset_id,
		fasv.vulnerability_id,
		baselineComparison (fasv.scan_id, current_scan) AS baseline,
		s.baseline_scan,
		s.current_scan
	FROM
		fact_asset_scan_vulnerability_instance fasv
	JOIN (
		SELECT
			asset_id,
			previousScan (asset_id) AS baseline_scan,
			lastScan (asset_id) AS current_scan
		FROM
			dim_asset
	) s ON s.asset_id = fasv.asset_id
	AND (
		fasv.scan_id = s.baseline_scan
		OR fasv.scan_id = s.current_scan
	)		
	GROUP BY
		fasv.asset_id,		
		fasv.vulnerability_id,
		s.baseline_scan,
		s.current_scan
	HAVING
		(
			baselineComparison (fasv.scan_id, current_scan) = 'Same'
		)
	OR (
		baselineComparison (fasv.scan_id, current_scan) = 'New'
	)
	OR (
		baselineComparison (fasv.scan_id, current_scan) = 'Old'
	)
),
baseline_scan_date as (
	SELECT
		av.asset_id,
		finished
	FROM assets_vulns av
	LEFT JOIN dim_scan ds ON ds.scan_id = av.baseline_scan
	GROUP BY av.asset_id, finished
),

current_scan_date AS (
	SELECT
		av.asset_id,
		finished
	FROM assets_vulns av
	LEFT JOIN dim_scan ds ON ds.scan_id = av.current_scan
	GROUP BY av.asset_id, finished
),
new_vulns AS (
	SELECT
		av.asset_id,
		av.vulnerability_id,
		COUNT (av.vulnerability_id) AS new_vulns
	FROM
		assets_vulns AS av
	WHERE
		av.baseline = 'New'
	GROUP BY
		av.asset_id,
		av.vulnerability_id
),
 remediated_vulns AS (
	SELECT
		av.asset_id,
		av.vulnerability_id,		
		COUNT (av.vulnerability_id) AS remediated_vulns
	FROM
		assets_vulns AS av
	WHERE
		av.baseline = 'Old'
	GROUP BY
		av.asset_id,
		av.vulnerability_id
	
),
vuln_exploit_count AS (
	SELECT 
		CASE WHEN ec1.vulnerability_id IS NOT NULL THEN ec1.vulnerability_id ELSE ec2.vulnerability_id END AS vulnerability_id, metasploit, exploitdb
	FROM
	(SELECT
		av.vulnerability_id,
		COUNT(dve.source) AS metasploit
	FROM assets_vulns av
	JOIN dim_vulnerability_exploit dve ON av.vulnerability_id = dve.vulnerability_id
	WHERE dve.source = 'Metasploit'
	GROUP BY 
		av.vulnerability_id	
	) ec1
	
	FULL JOIN
	
	(SELECT
		av.vulnerability_id,
		COUNT(dve.source) AS exploitdb
	FROM assets_vulns av
	JOIN dim_vulnerability_exploit dve ON av.vulnerability_id = dve.vulnerability_id
	WHERE dve.source = 'Exploit DB'
	GROUP BY 
		av.vulnerability_id		
	) ec2
	
	ON ec2.vulnerability_id = ec1.vulnerability_id
)

SELECT
	'Remediated' AS status,
	da1.ip_address AS ip_address, 
	da1.host_name AS hostname,
	bsd.finished AS baseline_scan_datetime, 
	csd.finished AS current_scan_datetime,
	dv1.vulnerability_id,
	dv1.title,
	CAST(dv1.cvss_score AS decimal(10,2)) AS cvss_score,
	CAST(dv1.riskscore AS decimal(10,0)) AS riskscore,
	dv1.malware_kits,
	CASE WHEN vec.metasploit IS NULL THEN 0 ELSE vec.metasploit END AS metasploit,
	CASE WHEN vec.exploitdb IS NULL THEN 0 ELSE vec.exploitdb END AS exploitdb
FROM
	remediated_vulns rv
	JOIN dim_asset da1 ON da1.asset_id = rv.asset_id
	LEFT JOIN baseline_scan_date bsd ON bsd.asset_id = da1.asset_id
	LEFT JOIN current_scan_date csd ON csd.asset_id = da1.asset_id
	JOIN dim_vulnerability dv1 ON dv1.vulnerability_id = rv.vulnerability_id
	LEFT JOIN vuln_exploit_count vec ON vec.vulnerability_id = rv.vulnerability_id
	
UNION ALL

SELECT
	'New' AS status,
	da2.ip_address AS ip_address, 
	da2.host_name AS hostname,
	bsd.finished AS baseline_scan_datetime, 
	csd.finished AS current_scan_datetime,
	dv2.vulnerability_id,
	dv2.title,
	CAST(dv2.cvss_score AS decimal(10,2)) AS cvss_score,
	CAST(dv2.riskscore AS decimal(10,0)) AS riskscore,
	dv2.malware_kits,
	CASE WHEN vec.metasploit IS NULL THEN 0 ELSE vec.metasploit END AS metasploit,	
	CASE WHEN vec.exploitdb IS NULL THEN 0 ELSE vec.exploitdb END AS exploitdb
FROM
	new_vulns nv
	JOIN dim_asset AS da2 ON da2.asset_id = nv.asset_id
	LEFT JOIN baseline_scan_date bsd ON bsd.asset_id = da2.asset_id
	LEFT JOIN current_scan_date csd ON csd.asset_id = da2.asset_id
	JOIN dim_vulnerability dv2 ON dv2.vulnerability_id = nv.vulnerability_id	
	LEFT JOIN vuln_exploit_count vec ON vec.vulnerability_id = nv.vulnerability_id
ORDER BY status DESC, ip_address, hostname, title
