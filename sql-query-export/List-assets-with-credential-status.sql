-- List assets with credential status.
-- Copy the SQL query below
SELECT
    asset_id,
    host_name,
    scan_id,
    date,
    name,
    credential_status_description
FROM
    fact_asset_scan_service
    JOIN dim_credential_status USING(credential_status_id)
    JOIN dim_service USING(service_id)
    JOIN dim_asset USING (asset_id)