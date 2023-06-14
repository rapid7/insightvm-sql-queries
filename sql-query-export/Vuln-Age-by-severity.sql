--- Vulnerability Age categorized for Emergency, Severe, Moderate and low where:
---Emergency = Critical vulnerabilities with malware Kits/exploits and 15days in the wild
---Severe = Critical vulnerabilities greater than 30 days old in the wild.
---Moderate = Moderate vulnerabilities greater than 60days in the wild.
---Low = anything that does not satisfy above.
--- This also includes the solution
--- Copy the SQL query below
SELECT
    site_id,
    dv.vulnerability_id,
    dv.date_published,
    fava.age_in_days,
    dv.severity,
    dv.exploits,
    dv.malware_kits,
    array_to_string(
        array_agg(
            (ip_address) || (
                CASE
                    WHEN host_name IS NULL THEN ''
                    ELSE ' (' || host_name || ')'
                END
            )
        ),
        ', '
    ) AS affected_assets,
    CASE
        WHEN dv.severity = 'Critical'
        AND dv.exploits != '0'
        AND dv.malware_kits >= '1'
        AND dv.date_published < (NOW() - INTERVAL '15 days') THEN 'Emergency'
        WHEN dv.severity = 'Critical'
        OR (
            dv.severity = 'Severe'
            AND date_published < (NOW() - INTERVAL '31 days')
        ) THEN 'Severe'
        WHEN dv.severity = 'Moderate'
        AND dv.date_published > (NOW() - INTERVAL '60 days') THEN 'Moderate'
        ELSE 'Low'
    END AS VULN_SEVERITY,
    CASE
        WHEN dv.severity = 'Critical'
        AND dv.exploits != '0'
        AND dv.malware_kits >= '1'
        AND dv.date_published < (NOW() - INTERVAL '31 days') THEN '1'
        WHEN dv.severity = 'Critical'
        OR (
            dv.severity = 'Severe'
            AND date_published < (NOW() - INTERVAL '31 days')
        ) THEN '2'
        WHEN dv.severity = 'Moderate'
        AND dv.date_published > (NOW() - INTERVAL '60 days') THEN '4'
        ELSE '5'
    END AS VULN_SEVERITY_SORT,
    ds.summary
FROM
    fact_asset_vulnerability_age fava
    JOIN fact_asset_vulnerability_finding USING (asset_id, vulnerability_id)
    JOIN dim_vulnerability dv USING (vulnerability_id)
    JOIN dim_asset da USING (asset_id)
    JOIN dim_site_asset USING (asset_id)
    JOIN dim_asset_vulnerability_best_solution davbs ON (davbs.asset_id = da.asset_id)
    AND (davbs.vulnerability_id = dv.vulnerability_id)
    JOIN dim_solution ds USING (solution_id)
GROUP BY
    dim_site_asset.site_id,
    dv.vulnerability_id,
    dv.date_published,
    fava.age_in_days,
    dv.severity,
    dv.exploits,
    dv.malware_kits,
    VULN_SEVERITY,
    VULN_SEVERITY_SORT,
    ds.summary
ORDER BY
    VULN_SEVERITY_SORT