Presents the number of days to remediate asset vulnerabilities and whether or not they sit inside or outside a 30 day (modifiable) remediation SLA. And, it filters down to Microsoft vulnerabilities published on November 12th 2024 (modifiable). 
This query filters for Microsoft Vulnerabilites (modifiable) that were published on a specific date (2024-11-12) (modifiable). 
This uses first discovered date minus most recently discovered to assume remediation time. 

SELECT
    da.ip_address,
    da.host_name,
    dv.title,
    EXTRACT(day FROM vfa.first_discovered - vfa.most_recently_discovered) AS sla_days,
    (EXTRACT(day FROM vfa.first_discovered - vfa.most_recently_discovered) <=
30)::text AS sla_met
FROM
    fact_asset_vulnerability_age vfa
JOIN dim_asset da USING (asset_id)
JOIN dim_vulnerability dv ON vfa.vulnerability_id = dv.vulnerability_id
WHERE
    dv.date_published = '2024-11-12'
    AND dv.title LIKE '%Microsoft%';
