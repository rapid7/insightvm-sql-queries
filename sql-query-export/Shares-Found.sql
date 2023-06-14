-- Shares found during scan
--Query Will Provide:
--  IP Address
--	Host Name
--	Share Name
--	Operating System
--	Scan Finished
--	Asset ID
-- Copy the SQL query below
SELECT
    da.host_name,
    da.ip_address,
    dos.description AS operating_system,
    daf.name AS share_name,
    scan_finished,
    fa.asset_id as id
FROM
    fact_asset fa
    JOIN dim_asset da USING (asset_id)
    JOiN dim_asset_file daf USING (asset_id)
    JOIN dim_operating_system dos USING (operating_system_id)
ORDER BY
    fa.asset_id