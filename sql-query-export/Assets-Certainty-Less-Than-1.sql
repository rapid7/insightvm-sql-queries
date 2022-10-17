--List assets which have not attained a certainty of 1.0 and only return the max attained certainty.
-- Copy the SQL query below



SELECT da.ip_address AS "IP Address", da.host_name AS "Hostname", dos.description AS "OS", max(daos.certainty) AS "Certainty", da.last_assessed_for_vulnerabilities AS "Last Assessed"
FROM dim_asset AS da 
JOIN dim_operating_system AS dos ON da.operating_system_id = dos.operating_system_id 
JOIN dim_asset_operating_system AS daos ON da.asset_id = daos.asset_id 
WHERE certainty < 1 
GROUP BY da.ip_address, da.host_name, dos.description, da.last_assessed_for_vulnerabilities
