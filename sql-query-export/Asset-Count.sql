-- Console query to sum up the number of ip addresses in db
-- Copy the SQL query below
SELECT COUNT(*) FROM (
SELECT DISTINCT da.ip_address
FROM dim_asset da) s
