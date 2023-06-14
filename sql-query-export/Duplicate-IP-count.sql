-- Finding and listing duplicate IP's
-- Copy the SQL query below
SELECT
    ip_address AS "IP Address",
    sites AS "Sites IP Address Appears"
FROM
    dim_asset
where
    sites like '%,%';