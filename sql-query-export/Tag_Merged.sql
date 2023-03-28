--  Tags and merged

-- Report contains the following:
-- IP Address
-- Port, Service
-- Protocol
-- Report Date
-- OS
-- Tag_Name
-- Copy the SQL query below

SELECT 
  da.ip_address, 
  das.port,
  ds.name AS service,
  dp.name AS protocol, 
now() AS 
  report_date,
  dos.name AS os,
  array_to_string(array_agg(dt.tag_name),',') as 
    tag_name
FROM dim_asset_service das
JOIN 
  dim_service ds 
USING (service_id)
JOIN 
  dim_protocol dp 
USING (protocol_id)
JOIN 
  dim_asset da 
USING (asset_id)
JOIN 
  dim_operating_system dos 
USING (operating_system_id)
LEFT OUTER JOIN 
  dim_tag_asset dta 
USING (asset_id)
LEFT OUTER JOIN 
  dim_tag dt 
USING (tag_id)
GROUP BY 
  da.ip_address, 
  das.port,
  ds.name,
  dp.name,
  dos.name
ORDER BY 
  da.ip_address,
  ds.name
