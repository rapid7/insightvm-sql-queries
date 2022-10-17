-- Remediation Roll Up
-- Copy the SQL query below

WITH
   superceding_solution_summaries AS (
      SELECT dshs.solution_id AS superceded_solution_id, dshs.superceding_solution_id AS superceding_solution_id,
         CASE
            WHEN ds.summary like 'MS%' then substr(ds.summary,0,9)
            WHEN ds.summary like 'Upgrade jboss%' then 'Upgrade jboss'
            WHEN ds.summary like 'Disable IP source routing%' then 'Disable IP source routing'
            WHEN ds.summary like 'Disable IRDP%' then 'Disable IRDP'
            WHEN ds.summary like 'Upgrade kernel%' then 'Upgrade kernel'
            ELSE ds.summary
         END AS superceding_solution_summary
      FROM dim_solution_highest_supercedence dshs
         JOIN dim_solution ds ON ds.solution_id = dshs.superceding_solution_id
   ),
   asset_vulnerability_count_by_solution AS (
      SELECT davs.asset_id, sss.superceding_solution_summary AS solution_summary, array_agg(ds.summary) AS superceded_solutions, dv.title AS vulnerabilities,
         (SELECT COALESCE(url, 'None') FROM dim_solution WHERE solution_id = MAX(sss.superceding_solution_id)) AS url,
         (SELECT solution_type::text FROM dim_solution WHERE solution_id = MAX(sss.superceding_solution_id) LIMIT 1) AS solution_type,
         dv.riskscore AS riskscore,
         (SELECT COUNT(DISTINCT exploit_id) FROM dim_vulnerability_exploit WHERE vulnerability_id = dv.vulnerability_id) AS exploits,
         (SELECT COUNT(DISTINCT (name, popularity)) FROM dim_vulnerability_malware_kit WHERE vulnerability_id = dv.vulnerability_id) AS malware_kits
      FROM dim_asset_vulnerability_solution davs
         JOIN superceding_solution_summaries sss ON sss.superceded_solution_id = davs.solution_id
         JOIN dim_solution ds ON ds.solution_id = sss.superceded_solution_id
         JOIN dim_vulnerability dv USING (vulnerability_id)
      GROUP BY davs.asset_id, sss.superceding_solution_summary, dv.vulnerability_id, dv.title, dv.riskscore
      ORDER BY superceding_solution_summary
   )
SELECT ds.name, da.ip_address, da.host_name, avcs.solution_summary AS summary, avcs.url AS "coalesce", solution_type, replace(avcs.vulnerabilities, ',', '-') AS vulnerabilties, ceiling(avcs.riskscore), exploits, malware_kits
FROM asset_vulnerability_count_by_solution avcs
   JOIN dim_site_asset USING (asset_id)
   JOIN dim_site ds USING (site_id)
   JOIN dim_asset da USING (asset_id)
GROUP BY ds.name, da.ip_address, da.host_name, avcs.solution_summary,avcs.url, solution_type, vulnerabilties, ceiling, exploits, malware_kits
ORDER BY ip_address, summary asc
