-- list users found during scans
--Query Will Provide:
--  name
--	full_name
--  ip_address
-- 	host_name
-- Copy the SQL query below
SELECT
    daua.name,
    daua.full_name,
    da.ip_address,
    da.host_name
FROM
    dim_asset_user_account daua
    JOIN dim_asset da using (asset_id)