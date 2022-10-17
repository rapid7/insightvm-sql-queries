-- For comparing vuln counts between the first scan and the current scan
-- Copy the SQL query below

WITH assets_vulns AS (
	SELECT
		fasv.asset_id,
		fasv.vulnerability_id,
		baselineComparison (fasv.scan_id, current_scan)
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
		fasv.vulnerability_id
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
 current_assets_vulns_count AS (
	SELECT
		COUNT (DISTINCT av.asset_id) AS total_assets_now,
		COUNT (av.vulnerability_id) AS total_vulns_now,
		SUM (dv.riskscore) AS total_vuln_risk_now,
		ROUND(SUM(dv.riskscore)) AS round_total_vuln_risk_now,
		SUM (dv.riskscore) / COUNT (DISTINCT av.asset_id) AS avg_risk_now,
		ROUND(
			CAST (
				SUM (dv.riskscore) / COUNT (DISTINCT av.asset_id) AS DECIMAL
			)
		) AS round_avg_risk_now
	FROM
		assets_vulns AS av
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	WHERE
		av.baselineComparison = 'New'
	OR av.baselineComparison = 'Same'
),
 previous_asset_vulns_count AS (
	SELECT
		COUNT (DISTINCT av.asset_id) AS total_assets_then,
		COUNT (av.vulnerability_id) AS total_vulns_then,
		SUM (dv.riskscore) AS total_vuln_risk_then,
		ROUND(SUM(dv.riskscore)) AS round_total_vuln_risk_then,
		SUM (dv.riskscore) / COUNT (DISTINCT av.asset_id) AS avg_risk_then,
		ROUND(
			CAST (
				SUM (dv.riskscore) / COUNT (DISTINCT av.asset_id) AS DECIMAL
			)
		) AS round_avg_risk_then
	FROM
		assets_vulns AS av
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	WHERE
		av.baselineComparison = 'Old'
	OR av.baselineComparison = 'Same'
),
 asset_vuln_diff AS (
	SELECT
		CASE
	WHEN cavc.total_assets_now - pavc.total_assets_then > 0 THEN
		'INCREASED'
	WHEN cavc.total_assets_now - pavc.total_assets_then < 0 THEN
		'DECREASED'
	ELSE
		'NO CHANGE'
	END AS asset_diff,
	CASE
WHEN cavc.total_vulns_now - pavc.total_vulns_then > 0 THEN
	'INCREASED'
WHEN cavc.total_vulns_now - pavc.total_vulns_then < 0 THEN
	'DECREASED'
ELSE
	'NO CHANGE'
END AS vuln_diff,
 CASE
WHEN cavc.total_vuln_risk_now - pavc.total_vuln_risk_then > 0 THEN
	'INCREASED'
WHEN cavc.total_vuln_risk_now - pavc.total_vuln_risk_then < 0 THEN
	'DECREASED'
ELSE
	'NO CHANGE'
END AS vuln_risk_diff,
 CASE
WHEN cavc.avg_risk_now - pavc.avg_risk_then > 0 THEN
	'INCREASED'
WHEN cavc.avg_risk_now - pavc.avg_risk_then < 0 THEN
	'DECREASED'
ELSE
	'NO CHANGE'
END AS avg_risk_diff,
 CASE
WHEN cavc.total_assets_now - pavc.total_assets_then > 0 THEN
	ROUND(
		(
			(
				CAST (
					(
						cavc.total_assets_now - pavc.total_assets_then
					) AS DECIMAL
				) * 100
			) / pavc.total_assets_then
		),
		1
	)
WHEN cavc.total_assets_now - pavc.total_assets_then < 0 THEN
	ROUND(
		(
			(
				CAST (
					(
						pavc.total_assets_then - cavc.total_assets_now
					) AS DECIMAL
				) * 100
			) / pavc.total_assets_then
		),
		1
	)
ELSE
	0
END AS asset_diff_percent,
 CASE
WHEN cavc.total_vulns_now - pavc.total_vulns_then > 0 THEN
	ROUND(
		(
			(
				CAST (
					(
						cavc.total_vulns_now - pavc.total_vulns_then
					) AS DECIMAL
				) * 100
			) / pavc.total_vulns_then
		),
		1
	)
WHEN cavc.total_vulns_now - pavc.total_vulns_then < 0 THEN
	ROUND(
		(
			(
				CAST (
					(
						pavc.total_vulns_then - cavc.total_vulns_now
					) AS DECIMAL
				) * 100
			) / pavc.total_vulns_then
		),
		1
	)
ELSE
	0
END AS vuln_diff_percent,
 CASE
WHEN cavc.total_assets_now - pavc.total_assets_then > 0 THEN
	ROUND(
		(
			(
				CAST (
					(
						cavc.total_assets_now - pavc.total_assets_then
					) AS DECIMAL
				) * 100
			) / pavc.total_assets_then
		),
		1
	)
WHEN cavc.total_assets_now - pavc.total_assets_then < 0 THEN
	ROUND(
		(
			(
				CAST (
					(
						pavc.total_assets_then - cavc.total_assets_now
					) AS DECIMAL
				) * 100
			) / pavc.total_assets_then
		),
		1
	)
ELSE
	0
END AS asset_diff_percent,
 CASE
WHEN cavc.total_vuln_risk_now - pavc.total_vuln_risk_then > 0 THEN
	ROUND(
		CAST (
			(
				(
					CAST (
						(
							cavc.total_vuln_risk_now - pavc.total_vuln_risk_then
						) AS DECIMAL
					) * 100
				) / pavc.total_vuln_risk_then
			) AS DECIMAL
		),
		1
	)
WHEN cavc.total_vuln_risk_now - pavc.total_vuln_risk_then < 0 THEN
	ROUND(
		CAST (
			(
				(
					CAST (
						(
							pavc.total_vuln_risk_then - cavc.total_vuln_risk_now
						) AS DECIMAL
					) * 100
				) / pavc.total_vuln_risk_then
			) AS DECIMAL
		),
		1
	)
ELSE
	0
END AS total_risk_diff_percent,
 CASE
WHEN cavc.avg_risk_now - pavc.avg_risk_then > 0 THEN
	ROUND(
		CAST (
			(
				(
					CAST (
						(
							cavc.avg_risk_now - pavc.avg_risk_then
						) AS DECIMAL
					) * 100
				) / pavc.avg_risk_then
			) AS DECIMAL
		),
		1
	)
WHEN cavc.avg_risk_now - pavc.avg_risk_then < 0 THEN
	ROUND(
		CAST (
			(
				(
					CAST (
						(
							pavc.avg_risk_then - cavc.avg_risk_now
						) AS DECIMAL
					) * 100
				) / pavc.avg_risk_then
			) AS DECIMAL
		),
		1
	)
ELSE
	0
END AS avg_risk_diff_percent
FROM
	current_assets_vulns_count AS cavc,
	previous_asset_vulns_count AS pavc
),
 current_critical_vulns_count AS (
	SELECT
		COUNT (av.vulnerability_id) AS critical_vulns_now,
		COUNT (DISTINCT av.asset_id) AS critical_assets_now
	FROM
		assets_vulns AS av
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	AND dv.severity = 'Critical'
	WHERE
		av.baselineComparison = 'New'
	OR av.baselineComparison = 'Same'
),
 previous_critical_vulns_count AS (
	SELECT
		COUNT (av.vulnerability_id) AS critical_vulns_then
	FROM
		assets_vulns AS av
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	AND dv.severity = 'Critical'
	WHERE
		av.baselineComparison = 'Old'
	OR av.baselineComparison = 'Same'
),
 current_severe_vulns_count AS (
	SELECT
		COUNT (av.vulnerability_id) AS severe_vulns_now,
		COUNT (DISTINCT av.asset_id) AS severe_assets_now
	FROM
		assets_vulns AS av
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	AND dv.severity = 'Severe'
	WHERE
		av.baselineComparison = 'New'
	OR av.baselineComparison = 'Same'
),
 previous_severe_vulns_count AS (
	SELECT
		COUNT (av.vulnerability_id) AS severe_vulns_then
	FROM
		assets_vulns AS av
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	AND dv.severity = 'Severe'
	WHERE
		av.baselineComparison = 'Old'
	OR av.baselineComparison = 'Same'
),
 current_moderate_vulns_count AS (
	SELECT
		COUNT (av.vulnerability_id) AS moderate_vulns_now,
		COUNT (DISTINCT av.asset_id) AS moderate_assets_now
	FROM
		assets_vulns AS av
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	AND dv.severity = 'Moderate'
	WHERE
		av.baselineComparison = 'New'
	OR av.baselineComparison = 'Same'
),
 previous_moderate_vulns_count AS (
	SELECT
		COUNT (av.vulnerability_id) AS moderate_vulns_then
	FROM
		assets_vulns AS av
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	AND dv.severity = 'Moderate'
	WHERE
		av.baselineComparison = 'Old'
	OR av.baselineComparison = 'Same'
),
 vuln_severity_diff AS (
	SELECT
		CASE
	WHEN ccvc.critical_vulns_now - pcvc.critical_vulns_then > 0 THEN
		'INCREASED'
	WHEN ccvc.critical_vulns_now - pcvc.critical_vulns_then < 0 THEN
		'DECREASED'
	ELSE
		'NO CHANGE'
	END AS critical_diff,
	CASE
WHEN csvc.severe_vulns_now - psvc.severe_vulns_then > 0 THEN
	'INCREASED'
WHEN csvc.severe_vulns_now - psvc.severe_vulns_then < 0 THEN
	'DECREASED'
ELSE
	'NO CHANGE'
END AS severe_diff,
 CASE
WHEN cmvc.moderate_vulns_now - pmvc.moderate_vulns_then > 0 THEN
	'INCREASED'
WHEN cmvc.moderate_vulns_now - pmvc.moderate_vulns_then < 0 THEN
	'DECREASED'
ELSE
	'NO CHANGE'
END AS moderate_diff
FROM
	current_critical_vulns_count AS ccvc,
	previous_critical_vulns_count AS pcvc,
	current_severe_vulns_count AS csvc,
	previous_severe_vulns_count AS psvc,
	current_moderate_vulns_count AS cmvc,
	previous_moderate_vulns_count AS pmvc
),
 current_site_risk AS (
	SELECT
		ds.site_id AS site_id,
		ds."name" AS site_name,
		ROUND(SUM(dv.riskscore)) AS site_risk_now
	FROM
		assets_vulns AS av
	JOIN dim_site_asset AS dsa ON av.asset_id = dsa.asset_id
	JOIN dim_site AS ds ON dsa.site_id = ds.site_id
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	WHERE
		av.baselineComparison = 'New'
	OR av.baselineComparison = 'Same'
	GROUP BY
		ds.site_id,
		ds. NAME
	ORDER BY
		site_risk_now DESC
	LIMIT 1
),
 previous_site_risk AS (
	SELECT
		csr.site_id AS site_id,
		csr.site_name AS site_name,
		ROUND(SUM(dv.riskscore)) AS site_risk_then
	FROM
		assets_vulns AS av
	JOIN dim_site_asset AS dsa ON av.asset_id = dsa.asset_id
	JOIN current_site_risk AS csr ON dsa.site_id = csr.site_id
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	WHERE
		(
			av.baselineComparison = 'Old'
			OR av.baselineComparison = 'Same'
		)
	AND dsa.site_id = csr.site_id
	GROUP BY
		csr.site_id,
		csr.site_name
	ORDER BY
		site_risk_then DESC
	LIMIT 1
),
 asset_risk_now AS (
	SELECT
		da.asset_id AS asset_id,
		da.host_name AS asset_name,
		ROUND(sum(dv.riskscore)) AS asset_risk_now
	FROM
		assets_vulns AS av
	JOIN dim_asset AS da ON av.asset_id = da.asset_id
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	WHERE
		av.baselineComparison = 'New'
	OR av.baselineComparison = 'Same'
	GROUP BY
		da.asset_id,
		da.host_name
	ORDER BY
		asset_risk_now DESC
	LIMIT 1
),
 asset_risk_then AS (
	SELECT
		arn.asset_id AS asset_id,
		arn.asset_name AS asset_name,
		ROUND(sum(dv.riskscore)) AS asset_risk_then
	FROM
		assets_vulns AS av
	JOIN asset_risk_now AS arn ON av.asset_id = arn.asset_id
	JOIN dim_vulnerability AS dv ON av.vulnerability_id = dv.vulnerability_id
	WHERE
		av.baselineComparison = 'New'
	OR av.baselineComparison = 'Same'
	GROUP BY
		arn.asset_id,
		arn.asset_name
	ORDER BY
		asset_risk_then DESC
	LIMIT 1
) SELECT
	*
FROM
	current_assets_vulns_count,
	previous_asset_vulns_count,
	asset_vuln_diff,
	current_critical_vulns_count,
	previous_critical_vulns_count,
	current_severe_vulns_count,
	previous_severe_vulns_count,
	current_moderate_vulns_count,
	previous_moderate_vulns_count,
	vuln_severity_diff,
	current_site_risk,
	previous_site_risk,
	asset_risk_now,
	asset_risk_then
