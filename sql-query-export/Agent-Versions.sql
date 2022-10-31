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
JOIN dim_software ds ON das.software_id=ds.software_id
JOIN dim_asset da ON da.asset_id=das.asset_id
WHERE ds.name = 'Rapid7 Insight Agent'
ORDER BY ds.name ASC
