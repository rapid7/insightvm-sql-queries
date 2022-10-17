-- Unauthenticated Assets with max certainty less than 1
-- Copy the SQL query below

SELECT
	dsite."name" AS "Site",
	da.ip_address,
	da.host_name,
	dh.description AS "Host Type",
	dos.description AS "OS",
	os.certainty_max
FROM
	fact_asset AS fa
JOIN dim_asset da ON da.asset_id = fa.asset_id
JOIN (
	SELECT
		asset_id,
		MAX (certainty) AS certainty_max
	FROM
		dim_asset_operating_system
	GROUP BY
		asset_id
) os ON fa.asset_id = os.asset_id
JOIN dim_host_type AS dh ON da.host_type_id = dh.host_type_id
JOIN dim_operating_system AS dos ON da.operating_system_id = dos.operating_system_id
JOIN dim_site_asset AS dsa ON fa.asset_id = dsa.asset_id
JOIN dim_site AS dsite ON dsa.site_id = dsite.site_id
WHERE
	os.certainty_max < 1
GROUP BY
	dsite."name",
	da.ip_address,
	da.host_name,
	dh.description,
	dos.description,
	os.certainty_max
ORDER BY
	"Site",
	HOST (da.ip_address)
