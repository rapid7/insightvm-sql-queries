-- Asset report with first and last discovered dates.
-- Provides asset IP, hostname, mac_address, first date discovered, and last date discovered.
-- Copy the SQL query below
SELECT
    da.ip_address,
    da.host_name,
    da.mac_address,
    fad.first_discovered,
    fad.last_discovered
FROM
    fact_asset_discovery fad
    JOIN dim_asset da USING (asset_id)