-- Vulnerabilities Greater than 30 days old
-- Copy the SQL query below

WITH asset_vulns AS (
    SELECT favi.asset_id, favi.vulnerability_id, string_agg(htmlToText(favi.proof), E'\n') AS proof
    FROM fact_asset_vulnerability_instance favi
    GROUP BY favi.asset_id, favi.vulnerability_id
),
solutions AS (
    SELECT av.vulnerability_id, string_agg(htmlToText(ds.fix), E'\n') as fix
    FROM asset_vulns av
    JOIN dim_asset_vulnerability_best_solution davbs ON (davbs.asset_id = av.asset_id AND davbs.vulnerability_id = av.vulnerability_id)
    JOIN dim_solution ds ON ds.solution_id = davbs.solution_id
    GROUP BY av.vulnerability_id
)
SELECT da.ip_address, da.host_name, dv.title, dv.date_published, av.proof, s.fix AS solution
FROM asset_vulns av
JOIN solutions s ON av.vulnerability_id = s.vulnerability_id
JOIN dim_asset da ON da.asset_id = av.asset_id
JOIN dim_vulnerability dv ON dv.vulnerability_id = av.vulnerability_id
WHERE dv.date_published < current_date - interval '30 day'
AND dv.severity = 'Critical'
ORDER BY da.ip_address ASC, da.host_name ASC
