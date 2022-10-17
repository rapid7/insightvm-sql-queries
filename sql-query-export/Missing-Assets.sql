-- Delta of assets between the last 2 scans
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
 site_scans AS (
	SELECT
		site_id,
		last_scan,
		previous_scan
	FROM
		site_last_scan
	JOIN site_previous_scan USING (site_id)
),
 site_asset_delta AS (
	SELECT
		site_id,
		asset_id,
		baselineComparison (
			fas.scan_id,
			(
				SELECT
					last_scan
				FROM
					site_last_scan
				WHERE
					site_id = dsa.site_id
			)
		) AS STATE
	FROM
		fact_asset_scan fas
	JOIN dim_site_asset dsa USING (asset_id)
	WHERE
		fas.scan_id IN (
			SELECT
				last_scan
			FROM
				site_scans
			UNION
				SELECT
					previous_scan
				FROM
					site_scans
		)
	GROUP BY
		site_id,
		fas.asset_id
) SELECT
	sad.site_id,
	asset_id,
	da.ip_address,
	da.host_name,
	dos. NAME,
	dos. VERSION,
	CAST (dsc.finished AS DATE) AS DATE,
	sad. STATE AS delta_in_last_scan
FROM
	site_asset_delta sad
JOIN dim_asset da USING (asset_id)
JOIN dim_operating_system dos USING (operating_system_id)
JOIN dim_site ds USING (site_id)
JOIN dim_scan dsc ON dsc.scan_id = ds.last_scan_id
WHERE
	sad. STATE = 'Old'
