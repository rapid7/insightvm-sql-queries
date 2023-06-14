-- Software Counts and Listing
--Query Will Provide:
--  Count of assets
--	Software Vendor
--	Software Name
--	Software Family
--	Software Version 
-- Copy the SQL query below
SELECT
  count(da.asset_id) as asset_count,
  ds.vendor,
  ds.name as software_name,
  ds.family,
  ds.version
FROM
  dim_asset_software das
  JOIN dim_software ds using (software_id)
  JOIN dim_asset da on da.asset_id = das.asset_id
GROUP BY
  ds.vendor,
  ds.name,
  ds.family,
  ds.version,
  ds.cpe
ORDER BY
  asset_count DESC