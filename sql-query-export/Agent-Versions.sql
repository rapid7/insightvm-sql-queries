-- Console query to retrieve agent versions
-- Copy the SQL query below

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
WHERE ds.vendor like'Rapid7%'
ORDER BY ds.name ASC
