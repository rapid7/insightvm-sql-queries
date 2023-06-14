-- List service that there was an authentication attempt on per asset, and the subsequent authentication status.
-- Copy the SQL query below
SELECT
    ip_address AS "IP Address",
    date AS "Date",
    name AS "Service Name",
    credential_status_description AS "Credential Status"
FROM
    fact_asset_scan_service
    JOIN dim_credential_status USING (credential_status_id)
    JOIN dim_service USING (service_id)
    JOIN dim_asset USING (asset_id)