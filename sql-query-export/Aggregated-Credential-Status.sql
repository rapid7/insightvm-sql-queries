-- List assets based on authentication status. This would help to determine which assets are not being logged onto correctly.
-- Copy the SQL query below
WITH max_certainty AS (
    SELECT
        asset_id,
        max(certainty) AS certainty
    FROM
        dim_asset_operating_system
    GROUP BY
        asset_id
),
asset_cred_status AS (
    SELECT
        DISTINCT fa.asset_id,
        CASE
            WHEN dacs.aggregated_credential_status_id IN ('1', '2') THEN 'FAIL'
            WHEN dacs.aggregated_credential_status_id IN ('3', '4') THEN 'SUCCESS'
            ELSE 'N/A'
        END AS auth_status
    FROM
        fact_asset fa
        JOIN dim_aggregated_credential_status dacs ON (
            fa.aggregated_credential_status_id = dacs.aggregated_credential_status_id
        )
)
SELECT
    acs.asset_id,
    da.ip_address,
    da.host_name,
    acs.auth_status,
    ROUND(mc.certainty :: numeric, 2) AS certainty
FROM
    asset_cred_status acs
    JOIN dim_asset da ON (da.asset_id = acs.asset_id)
    JOIN max_certainty mc ON (mc.asset_id = da.asset_id)