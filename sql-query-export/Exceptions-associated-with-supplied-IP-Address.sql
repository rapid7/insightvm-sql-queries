-- Exceptions associated with supplied IP Address
-- Copy the SQL query below

SELECT dve.*
FROM dim_vulnerability_exception AS dve
JOIN dim_asset AS da USING (asset_id)
WHERE da.ip_address = '<IP Adress>'
