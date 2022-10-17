-- Software Inventory
-- Copy the SQL query below

SELECT da.mac_address AS "MAC ID",
	da.ip_address AS "IP Address",
	da.host_name AS "Host Name",
	ds."name" AS "Software Name",
	ds."version" AS "Version"
FROM
	fact_asset AS fa
JOIN dim_asset AS da ON fa.asset_id = da.asset_id
AND da.mac_address IS NOT NULL
JOIN dim_asset_software AS das ON fa.asset_id = das.asset_id
JOIN dim_software AS ds ON das.software_id = ds.software_id
GROUP BY
	da.ip_address,
	da.host_name,
	da.mac_address,
	ds."name",
	ds."version"
ORDER BY
	da.mac_address,
	da.ip_address ASC,
	da.host_name ASC,
	ds."name" ASC,
	ds."version" ASC
