-- Retrieve asset details and proof for a specific remediation
-- Copy the SQL query below

SELECT dsi.name AS site, da.ip_address, da.host_name, dos.description AS operating_system, favi.date AS scan_finished, proofAsText(ds.fix) AS remediation, proofAsText(favi.proof)
FROM fact_asset_vulnerability_instance favi
JOIN dim_vulnerability_solution dvs USING (vulnerability_id)
JOIN dim_asset da USING (asset_id)
JOIN dim_operating_system dos USING (operating_system_id)
JOIN dim_solution ds USING (solution_id)
JOIN dim_site_asset dsa USING (asset_id)
JOIN dim_site dsi USING (site_id)
WHERE solution_id IN (
SELECT solution_id
FROM dim_solution_highest_supercedence
WHERE superceding_solution_id IN (
SELECT solution_id
FROM dim_solution
WHERE lower(summary) LIKE '%insert summary here%'
)
)
