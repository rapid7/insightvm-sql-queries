-- asset inventory with IP, NEXPOSE_ID, VULNERABILITY TITLE, DESCRIPTION, DATA_PUBLISHED, CVSS_VECTOR, SEVERITY_SCORE
--         SEVERITY, PCI_SEVERITY, PCI_STATUS, CVSS_SCORE, EXPLOITS (ANY NUMBER =>1 MEANS EXPLOITABLE), MALWARE_KITS (ANY NUMBER =>1 MEANS EXPLOITABLE)
-- Copy the SQL query below
SELECT
    da.ip_address,
    nexpose_id,
    title,
    proofAsText(description) AS description,
    date_published,
    cvss_vector,
    severity_score,
    severity,
    pci_severity_score,
    pci_status,
    round(riskscore :: numeric, 0) AS risk_score,
    round(cvss_score :: numeric, 2) AS cvss_score,
    exploits,
    malware_kits
FROM
    fact_asset_vulnerability_finding favf
    JOIN dim_asset da using (asset_id)
    JOIN dim_vulnerability dv using (vulnerability_id)
ORDER BY
    title ASC