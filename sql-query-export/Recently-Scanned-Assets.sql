-- Assets scanned in the last 12 days.
-- Copy the SQL query below
SELECT
	da.ip_address,
	da.host_name,
	da.mac_address
FROM
	dim_asset_scan AS das
	JOIN dim_asset AS da USING (asset_id)
WHERE
	(
		CURRENT_TIMESTAMP - das.scan_finished < INTERVAL '12 days'
	)
	AND (da.mac_address IS NOT NULL)
GROUP BY
	da.ip_address,
	da.host_name,
	da.mac_address
ORDER BY
	da.ip_address ASC