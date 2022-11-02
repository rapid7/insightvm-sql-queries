--This example query is one of the ways to get an idea on what sites and assets have poorly managed credentials such as default accounts.
--Copy the Query Below

SELECT ds.name AS site,
       da.ip_address,
       da.host_name,
       dv.title AS vulnerability_title,
       dos.description AS operating_system,
       dos.cpe
FROM fact_asset_vulnerability_finding favf
JOIN dim_asset da USING (asset_id)
JOIN dim_operating_system dos USING (operating_system_id)
JOIN dim_vulnerability dv USING (vulnerability_id)
JOIN dim_vulnerability_category dvc USING (vulnerability_id)
JOIN dim_site_asset dsa USING (asset_id)
JOIN dim_site ds USING (site_id)
WHERE (dvc.category_name LIKE '%Default Account%')
ORDER BY ds.name ASC,
         dv.title ASC
