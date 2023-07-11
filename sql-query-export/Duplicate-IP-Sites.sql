-- Duplicate IPs across sites.  Note that this will likely include global (correlated) assets if you have asset linking
-- Copy the SQL query below
SELECT
    ip_address AS "IP Address",
    sites AS "Sites IP Address Appears"
FROM
    dim_asset
where
    sites like '%,%';
