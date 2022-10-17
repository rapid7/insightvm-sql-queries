-- Assets where creds failed
-- Copy the SQL query below

SELECT da.sites AS "Site", da.ip_address AS "IP Address", da.host_name AS "Hostname", dos.description AS "OS", daos.certainty AS "Certainty", da.last_assessed_for_vulnerabilities AS "Last Assessed"
FROM dim_asset AS da
JOIN dim_operating_system AS dos ON da.operating_system_id = dos.operating_system_id
JOIN dim_asset_operating_system AS daos ON da.asset_id = daos.asset_id
WHERE certainty < 1
AND last_assessed_for_vulnerabilities < '2018-03-07'::date
GROUP BY da.sites , da.ip_address , da.host_name ,dos.description ,daos.certainty, da.last_assessed_for_vulnerabilities
ORDER by da.sites ASC
