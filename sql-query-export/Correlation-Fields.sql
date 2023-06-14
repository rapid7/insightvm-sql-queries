-- list of Correlation fields.  Provides Primary and alternate IP, MAC and host names as well as UUID.
-- Copy the SQL query below
WITH asset_ip AS (
    SELECT
        DISTINCT asset_id,
        array_to_string(array_agg(dip.ip_address), ',') AS alt_ip
    FROM
        dim_asset_ip_address dip
    GROUP BY
        asset_id
),
asset_host AS (
    SELECT
        DISTINCT asset_id,
        array_to_string(array_agg(dah.host_name), ',') AS alt_hosts
    FROM
        dim_asset_host_name dah
    GROUP BY
        asset_id
),
asset_mac AS (
    SELECT
        DISTINCT asset_id,
        array_to_string(array_agg(dam.mac_address), ',') AS alt_mac
    FROM
        dim_asset_mac_address dam
    GROUP BY
        asset_id
),
asset_uuid AS (
    SELECT
        DISTINCT asset_id,
        array_to_string(array_agg(dau.unique_id), ',') AS uuid
    FROM
        dim_asset_unique_id dau
    GROUP BY
        asset_id
)
SELECT
    da.host_name AS "Primary host name",
    da.ip_address AS "Primary IP address",
    da.mac_address AS "MAC address",
    alt_ip AS "Alternate IP address",
    alt_hosts AS "Alias",
    alt_mac AS "Alternate MAC address",
    uuid AS "UUID"
FROM
    dim_asset da
    JOIN asset_ip ai ON ai.asset_id = da.asset_id
    JOIN asset_host ah ON ah.asset_id = da.asset_id
    JOIN asset_mac am ON am.asset_id = da.asset_id
    JOIN asset_uuid au ON au.asset_id = da.asset_id