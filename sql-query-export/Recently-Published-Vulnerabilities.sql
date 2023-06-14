/*Depending on how you run your program, you may have a need to report on new vulnerabilities,
 such as anything that came out in the last 2 months. One of the reasons may be that you have an
 SLA around remediation of new vulnerabilities. This example query provides that information.
 
 You can adjust 2 months to the most appropriate interval for you.*/
--Copy the Query below
SELECT
    da.host_name AS "Host Name",
    da.ip_address AS "IP Address",
    nexpose_id AS "Nexpose ID",
    title AS "Vulnerability Title",
    proofAsText(Description) AS Description,
    fasvi.date AS "Date Discovered",
    date_published AS "Date Published",
    severity_score AS "Severity Score",
    severity AS "Severity",
    round(riskscore :: numeric, 0) AS "Risk score",
    round(cvss_score :: numeric, 2) AS "CVSS Score",
    exploits AS Exploits,
    malware_kits AS "Malware Kits"
FROM
    dim_vulnerability
    JOIN fact_asset_vulnerability_finding favf USING (vulnerability_id)
    JOIN dim_asset da USING (asset_id)
    JOIN fact_asset_scan_vulnerability_instance fasvi USING (vulnerability_id)
WHERE
    now() - date_published < INTERVAL '2 months'
ORDER BY
    da.ip_address ASC