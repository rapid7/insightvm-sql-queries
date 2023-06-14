-- Risk Score of Identified
-- Copy the SQL query below
SELECT
    title,
    ROUND(riskscore) as risk_score,
    severity,
    exploits,
    malware_kits
FROM
    dim_vulnerability as dv
ORDER BY
    dv.severity,
    dv.title,
    dv.riskscore,
    dv.exploits,
    dv.malware_kits