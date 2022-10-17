-- Delta between last 2 scans for services results
-- Copy the SQL query below


WITH
asset_last_scan AS (
	SELECT
		asset_id,
		(
			SELECT
				scan_id AS last_scan
			FROM
				dim_asset_scan
			JOIN dim_scan USING (scan_id)
			WHERE
				asset_id = da.asset_id
			ORDER BY
				finished DESC
			LIMIT 1
		) AS last_scan
	FROM
		dim_asset da
),
 asset_previous_scan AS (
	SELECT
		asset_id,
		(
			SELECT
				scan_id AS last_scan
			FROM
				dim_asset_scan
			JOIN dim_scan USING (scan_id)
			WHERE
				asset_id = da.asset_id
			AND scan_id NOT IN (
				SELECT
					last_scan
				FROM
					asset_last_scan
				WHERE
					asset_id = da.asset_id
			)
			ORDER BY
				finished DESC
			LIMIT 1
		) AS previous_scan
	FROM
		dim_asset da
),
 asset_scans AS (
	SELECT
		asset_id,
		last_scan,
		previous_scan
	FROM
		asset_last_scan
	JOIN asset_previous_scan USING (asset_id)
),
 asset_service_delta AS (
	SELECT
		asset_id,
		service_id,
		port,
		baselineComparison (
			fas.scan_id,
			(
				SELECT
					last_scan
				FROM
					asset_last_scan
				WHERE
					asset_id = fas.asset_id
			)
		) AS STATE
	FROM
		fact_asset_scan_service fas
	WHERE
		fas.scan_id IN (
			SELECT
				last_scan
			FROM
				asset_scans
			UNION
				SELECT
					previous_scan
				FROM
					asset_scans
		)
	GROUP BY
		asset_id,
		fas.service_id,
		fas.port
) SELECT
	asd.asset_id,
	da.ip_address,
	da.host_name,
	ds.NAME AS service,
	asd.port,
	CAST (fa.scan_finished AS DATE) AS DATE,
	asd.STATE AS delta_in_last_scan
FROM
	asset_service_delta asd
JOIN dim_asset da ON asd.asset_id = da.asset_id
JOIN fact_asset fa ON asd.asset_id = fa.asset_id
JOIN dim_service ds ON asd.service_id = ds.service_id
WHERE asd.STATE LIKE 'Old'
