-- Track Asset that are remediated
-- Copy the SQL query below

WITH site_last_scan AS (
	SELECT
		site_id,
		(
			SELECT
				scan_id AS last_scan
			FROM
				dim_site_scan
			JOIN dim_scan USING (scan_id)
			WHERE
				site_id = ds.site_id
			ORDER BY
				finished DESC
			LIMIT 1
		) AS last_scan
	FROM
		dim_site ds
),
 site_previous_scan AS (
	SELECT
		site_id,
		(
			SELECT
				scan_id AS last_scan
			FROM
				dim_site_scan
			JOIN dim_scan USING (scan_id)
			WHERE
				site_id = ds.site_id
			AND scan_id NOT IN (
				SELECT
					last_scan
				FROM
					site_last_scan
				WHERE
					site_id = ds.site_id
			)
			ORDER BY
				finished DESC
			LIMIT 1
		) AS previous_scan
	FROM
		dim_site ds
),
 previous_asset_list AS (
	SELECT
		sps.site_id,
		fas.asset_id AS previous_asset_list
	FROM
		site_previous_scan AS sps
	LEFT OUTER JOIN fact_asset_scan AS fas ON sps.previous_scan = fas.scan_id
	GROUP BY
		sps.site_id,
		fas.asset_id
),
 last_asset_list AS (
	SELECT
		sls.site_id,
		fas.asset_id AS last_asset_list
	FROM
		site_last_scan AS sls
	LEFT OUTER JOIN fact_asset_scan AS fas ON sls.last_scan = fas.scan_id
	GROUP BY
		sls.site_id,
		fas.asset_id
),
 common_asset_list AS (
	SELECT
		pal.site_id,
		pal.previous_asset_list AS common_assets
	FROM
		previous_asset_list AS pal
	JOIN last_asset_list AS lal ON pal.previous_asset_list = lal.last_asset_list
),
 assets_vulns AS (
	SELECT
		fasv.asset_id,
		fasv.vulnerability_id,
		baselineComparison (fasv.scan_id, current_scan) AS baseline
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
 existing_vulns AS (
	SELECT
		cal.site_id,
		COUNT (av.vulnerability_id) AS existing_vulns
	FROM
		assets_vulns AS av
	JOIN common_asset_list AS cal ON cal.common_assets = av.asset_id
	WHERE
		av.baseline = 'Same'
	GROUP BY
		cal.site_id
),
 remediated_vulns AS (
	SELECT
		cal.site_id,
		COUNT (av.vulnerability_id) AS remediated_vulns
	FROM
		assets_vulns AS av
	JOIN common_asset_list AS cal ON cal.common_assets = av.asset_id
	WHERE
		av.baseline = 'Old'
	GROUP BY
		cal.site_id
),
 new_vulns AS (
	SELECT
		cal.site_id,
		COUNT (av.vulnerability_id) AS new_vulns
	FROM
		assets_vulns AS av
	JOIN common_asset_list AS cal ON cal.common_assets = av.asset_id
	WHERE
		av.baseline = 'New'
	GROUP BY
		cal.site_id
) SELECT
	ds. NAME AS site_name,
	COALESCE (ev.existing_vulns, 0) AS existing_vulns,
	COALESCE (rv.remediated_vulns, 0) AS remediated_vulns,
	COALESCE (nv.new_vulns, 0) AS new_vulns
FROM
	existing_vulns AS ev
FULL JOIN remediated_vulns AS rv ON ev.site_id = rv.site_id
FULL JOIN new_vulns AS nv ON ev.site_id = nv.site_id
JOIN dim_site AS ds ON ev.site_id = ds.site_id
