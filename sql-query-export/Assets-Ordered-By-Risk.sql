-- See Assets and order them by risk.  This lists Assets with IP, Hostname, OS, and Riskscore
--  Copy the SQL query below


SELECT
    da.ip_address AS "IP",
    da.host_name AS "Hostname",
    os.description AS "OS",
    fa.riskscore AS "Risk Score"
FROM
    dim_asset da
JOIN
    fact_asset fa
ON
    da.asset_id=fa.asset_id
JOIN
    dim_operating_system os
ON
    da.operating_system_id=os.operating_system_id
ORDER BY riskscore DESC
