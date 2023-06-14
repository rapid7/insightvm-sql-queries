-- List most vulnerable sites in descending order based on risk score per asset
-- Copy the SQL query below
SELECT
    ds.name AS site,
    assets,
    riskscore,
    (
        CASE
            riskscore
            WHEN 0 THEN NULL
            ELSE riskscore
        END
    ) / (
        CASE
            assets
            WHEN 0 THEN NULL
            ELSE assets
        END
    ) AS "RiskPerAsset"
FROM
    fact_site
    JOIN dim_site ds USING (site_id)
ORDER BY
    "RiskPerAsset" DESC