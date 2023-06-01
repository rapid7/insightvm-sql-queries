-- Site Summary with OS asset count

-- Query Will Provide:
--  Site Name
--	Asset Count
--	Count of Windows Assets
--	Count of Linux Assets
--	Count of other OS asset that are not linux or windows
--	Critical Vulnerability Count
--	Severe Vulnerability Count
--	Moderate Vulnerability Count
--	Site Risk Score

-- Copy the SQL query below

WITH
   assets_by_operating_system AS (
      SELECT site_id, SUM(CASE WHEN windows THEN 1 ELSE 0 END) AS windows_count, SUM(CASE WHEN linux THEN 1 ELSE 0 END) AS linux_count,
         SUM(CASE WHEN NOT linux AND NOT windows THEN 1 ELSE 0 END) AS other_count
      FROM (
         SELECT asset_id, LOWER(dos.description) LIKE '%windows%' AS windows, LOWER(dos.description) LIKE '%linux%' AS linux
         FROM dim_asset
            JOIN dim_operating_system dos USING (operating_system_id)
      ) s
         JOIN dim_site_asset USING (asset_id)
      GROUP BY site_id
   )

SELECT ds.name, fs.assets, abos.windows_count AS windows_assets, abos.linux_count AS linux_assets, abos.other_count AS other_assets,
   fs.critical_vulnerabilities, fs.severe_vulnerabilities, fs.moderate_vulnerabilities, fs.riskscore
FROM fact_site fs
   JOIN dim_site ds using (site_id)
   JOIN assets_by_operating_system abos USING (site_id)
