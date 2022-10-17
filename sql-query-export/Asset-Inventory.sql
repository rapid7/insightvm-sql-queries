-- asset inventory with site name, ip address, host name, OS description, OS certainty
-- Copy the SQL query below

SELECT dsite."name" as "Site", da.ip_address, da.host_name, dos.description as "OS", os.certainty_max
FROM fact_asset AS fa
   JOIN dim_asset da ON da.asset_id = fa.asset_id
   JOIN (
      SELECT asset_id, MAX(certainty) as certainty_max
      FROM dim_asset_operating_system
      GROUP BY asset_id
   ) os ON fa.asset_id = os.asset_id AND os.certainty_max < 1
JOIN dim_operating_system as dos
ON da.operating_system_id = dos.operating_system_id
JOIN dim_site_asset as dsa
ON fa.asset_id = dsa.asset_id
JOIN dim_site as dsite
ON dsa.site_id = dsite.site_id
GROUP BY dsite."name", da.ip_address, da.host_name,dos.description, os.certainty_max
ORDER BY "Site", host(da.ip_address)
