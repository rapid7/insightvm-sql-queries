-- Credential Verification Report, shows certainty per port per asset
-- Copy the SQL query below

SELECT dsite.name as site, da.ip_address, da.host_name, dos.description as OS, os.certainty_max, dcs.credential_status_description, dasc.port, TO_CHAR(fa.scan_started, 'MM-DD-YYYY') AS date, fa.last_scan_id, dos.asset_type, 

      CASE WHEN certainty_max = '1' then 'YES'

                ELSE 'NO'

      END AS authenticated_scan,

      fa.vulnerabilities, fa.malware_kits, fa.exploits

FROM fact_asset AS fa

   JOIN dim_asset da ON da.asset_id = fa.asset_id

   JOIN (

      SELECT asset_id, MAX(daos.certainty) as certainty_max

      FROM dim_asset_operating_system AS daos

      GROUP BY asset_id

   ) os ON fa.asset_id = os.asset_id

JOIN dim_operating_system as dos

ON da.operating_system_id = dos.operating_system_id

JOIN dim_site_asset as dsa

ON fa.asset_id = dsa.asset_id

JOIN dim_site as dsite ON dsa.site_id = dsite.site_id

JOIN dim_asset_service_credential dasc on fa.asset_id = dasc.asset_id

JOIN dim_credential_status dcs ON dcs.credential_status_id = dasc.credential_status_id

 

GROUP BY dsite.name, da.ip_address, da.host_name,dos.description, os.certainty_max, dcs.credential_status_description, dasc.port, fa.vulnerabilities, fa.malware_kits, fa.exploits, fa.scan_started, fa.last_scan_id, dos.asset_type

ORDER BY dsite.name, da.ip_address
