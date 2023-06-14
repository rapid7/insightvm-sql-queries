-- collects MAC, IP, hostname, usergroup name and usergroup  description / long name
-- Copy the SQL query below
WITH unique_assets AS (
    select
        DISTINCT ON (da.mac_address) da.mac_address as "mac",
        da.ip_address as "ip",
        da.host_name as "host",
        da.asset_id
    FROM
        fact_asset AS fa
        JOIN dim_asset AS da ON fa.asset_id = da.asset_id
        and da.mac_address IS NOT NULL
        JOIN dim_asset_software AS das ON fa.asset_id = das.asset_id
        JOIN dim_software AS ds ON das.software_id = ds.software_id
        LEFT OUTER JOIN dim_asset_file AS daf ON fa.asset_id = daf.asset_id
    GROUP BY
        da.ip_address,
        da.host_name,
        da.mac_address,
        ds."name",
        da.asset_id
    ORDER BY
        da.mac_address,
        da.ip_address ASC,
        da.host_name ASC,
        ds."name" ASC,
        da.asset_id ASC
)
SELECT
    fa.mac AS "MAC Address",
    fa.ip AS "IP Address",
    fa.host AS "Host Name",
    daf."name" AS "User-Group Name",
    daf."full_name" AS "Full Name"
FROM
    unique_assets AS fa
    JOIN dim_asset_user_account AS daf ON fa.asset_id = daf.asset_id
GROUP BY
    fa.mac,
    fa.ip,
    fa.host,
    daf."name",
    daf."full_name"