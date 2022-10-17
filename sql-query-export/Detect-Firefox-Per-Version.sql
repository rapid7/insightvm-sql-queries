-- Detection of firefox per version - can do other sw by replacing firefox in like line
-- Copy the SQL Query Below

SELECT
da.sites AS "Site_Name",
da.ip_address AS "IP_Address",
da.mac_address AS "MAC_Address",
da.host_name AS "DNS_Hostname",
ds.vendor AS "Vendor",
ds.name AS "Software_Name",
ds.family AS "Software_Family",
ds.version AS "Software_Version",
ds.software_class AS "Software_Class"
FROM dim_asset_software das
JOIN dim_software ds USING(software_id)
JOIN dim_asset da ON da.asset_id = das.asset_id
WHERE
ds.software_class like'Internet Client%'
AND ds.name like 'Firefox%'
AND ds.version < '67.04'
ORDER BY ds.name ASC
