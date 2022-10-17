-- Validate Incorrect Correlation
-- Copy the SQL query below

WITH
base_line AS (SELECT da.host_name, da.asset_id
FROM dim_asset da
GROUP BY da.host_name, da.asset_id
)
SELECT bl.host_name, bl.asset_id
FROM base_line bl
FULL OUTER JOIN dim_asset da ON (da.host_name = bl.host_name)
WHERE bl.asset_id != da.asset_id
ORDER BY da.host_name
