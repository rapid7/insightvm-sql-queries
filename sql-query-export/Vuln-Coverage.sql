-- List of all vulnerability coverage in the console
-- Copy the SQL query below

SELECT nexpose_id, title, proofAsText(description) AS description, date_published, cvss_vector, severity_score, severity, pci_severity_score, pci_status, round(riskscore::numeric, 0) AS risk_score, round(cvss_score::numeric, 2) AS cvss_score, exploits, malware_kits
FROM dim_vulnerability ORDER BY title ASC
