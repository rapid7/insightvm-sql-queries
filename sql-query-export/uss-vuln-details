WITH owner AS (
    SELECT dt.name
    FROM dim_tag dt
    JOIN dim_asset_tag dat ON dt.tag_id = dat.tag_id
    WHERE dt.type = 'OWNER'
),
custom AS (
    SELECT dt.name
    FROM dim_tag dt
    JOIN dim_asset_tag dat ON dt.tag_id = dat.tag_id
    WHERE dt.type = 'CUSTOM'
)
SELECT DISTINCT ON (dv.vulnerability_id, da.ip_address, da.host_name)
    da.host_name AS "Host Name",
    da.ip_address AS "IP Address",
    dv.severity AS "Vulnerability Severity Level",
    dv.title AS "Vulnerability Title",
    htmlToText(dv.description) AS "Vulnerability Description",
    favf.date AS "Vulnerability Finding Date",
    DATE_PART('day', NOW()::date - favf.date) AS "Vulnerability Age",
    htmlToText(ds.fix) AS "Solution",
    htmlToText(favi.proof) AS "Vulnerability Proof",
    da.last_assessed_for_vulnerabilities AS "Last Date Found",
    da.os_family AS "Asset OS Family",
    da.os_name AS "Asset OS Name",
    da.sites AS "Site",
    das.port AS "Service Port",
    das.protocol AS "Service Protocol",
    SUBSTRING(dv.nexpose_id FROM 'cve-[0-9]+-[0-9]+') AS "CVE ID",
    dv.date_published AS "Vulnerability Published Date",
    dv.risk_score AS "Vulnerability Risk Score",
    dv.cvss_v3_score AS "Vulnerability CVSSv3 Score",
    dv.cvss_v3_vector AS "Vulnerability CVSSv3 Vector",
    owner AS "Asset Owner",
    custom AS "Custom Tag",
    fa.risk_score AS "Asset Risk Score",
    dv.exploits AS "Exploit Count",
    dv.malware_kits AS "Malware Kit Count",
    dv.cvss_score AS "Vulnerability CVSS Score",
    dv.cvss_vector AS "Vulnerability CVSS Vector"
FROM fact_asset_vulnerability_finding favf
JOIN dim_asset da ON favf.asset_id = da.asset_id
JOIN fact_asset_vulnerability_instance favi ON da.asset_id = favi.asset_id
JOIN fact_asset fa ON favi.asset_id = fa.asset_id
LEFT JOIN dim_asset_service das ON fa.asset_id = das.asset_id
left JOIN dim_asset_tag dat ON fa.asset_id = dat.asset_id
LEFT JOIN dim_tag dt ON dat.tag_id = dt.tag_id
JOIN dim_vulnerability dv ON favf.vulnerability_id = dv.vulnerability_id
JOIN dim_asset_vulnerability_finding_solution davfs ON favf.asset_id = davfs.asset_id AND favf.vulnerability_id = davfs.vulnerability_id
JOIN dim_solution ds ON davfs.solution_id = ds.solution_id
LEFT JOIN owner ON dt.name = owner.name
LEFT JOIN custom ON dt.name = custom.name
