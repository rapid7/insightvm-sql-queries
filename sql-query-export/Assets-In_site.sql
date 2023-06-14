-- Show each asset in a site with -
--   Asset Name
--   Asset OS
--   Last Scan Date
--   Credential Status of Services
--   Total Vulnerabilities (per asset).
-- Copy the SQL query below
WITH service_info AS (
    SELECT
        fasc.asset_id,
        fasc.scan_id,
        fasc.service_id,
        fasc.credential_status_id,
        fasc.port,
        dserv.name,
        dcs.credential_status_description
    FROM
        fact_asset_scan_service fasc
        JOIN dim_asset da USING(asset_id)
        JOIN dim_scan dscan USING(scan_id)
        JOIN dim_service dserv USING(service_id)
        JOIN dim_credential_status dcs ON (
            fasc.credential_status_id = dcs.credential_status_ID
        )
)
SELECT
    DISTINCT da.host_name AS "Asset Name",
    --Asset
    fa.vulnerabilities AS "Asset Vuln Count",
    --Total Vulnerabilities
    dos.name AS "Operating System",
    --OS
    fa.last_scan_id AS "Last Scan ID",
    --Scan ID
    da.last_assessed_for_vulnerabilities as "Last Scan Date",
    --Last Scan
    si.name AS "Service Name",
    --Service Auth
    si.port AS "Service Port",
    --Service Auth
    si.credential_status_description AS "Service Credential Status" --Service Auth
FROM
    fact_asset fa
    JOIN dim_asset da ON (fa.asset_id = da.asset_id)
    JOIN service_info si ON (da.asset_id = si.asset_id)
    JOIN dim_asset_operating_system daos ON (da.asset_id = daos.asset_id)
    JOIN dim_operating_system dos ON (
        daos.operating_system_id = dos.operating_system_id
    )
    JOIN dim_asset_scan das ON (fa.last_scan_id = das.scan_id)
WHERE
    fa.last_scan_id = das.scan_id
ORDER BY
    da.host_name,
    si.name