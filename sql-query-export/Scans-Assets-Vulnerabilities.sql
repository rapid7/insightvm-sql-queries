-- To pull all scans, assets and vulnerabilities

-- Query Will Provide:
--  scan_date
--	site     
--	ip_address     
--	mac_address     
--	vulnerability_title

-- Copy the SQL query below

SELECT fa.scan_finished AS scan_date, ds.name AS site, da.ip_address, da.host_name, da.mac_address, dv.title AS vulnerability_title 
FROM fact_asset_vulnerability_finding favf  
   JOIN dim_asset da USING (asset_id)  
   JOIN dim_operating_system dos USING (operating_system_id)  
   JOIN dim_vulnerability dv USING (vulnerability_id)  
   JOIN dim_site_asset dsa USING (asset_id)  
   JOIN dim_site ds USING (site_id)
   JOIN fact_asset fa USING (asset_id)  
ORDER BY fa.scan_finished ASC, da.ip_address ASC, dv.title ASC
