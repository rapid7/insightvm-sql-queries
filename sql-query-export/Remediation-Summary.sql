-- Remediation Summary
-- Copy the SQL query below
SELECT
  fr.solution_id,
  ds.summary as solution_summary,
  fr.assets AS assets_count,
  fr.vulnerabilities AS vulns_count,
  sum(round(fr.riskscore)) as riskscore,
  fr.exploits as exploits_count,
  fr.malware_kits as malware_count
from
  fact_remediation(10, 'riskscore' || ' DESC') fr
  JOIN dim_solution ds on ds.solution_id = fr.solution_id
GROUP BY
  fr.solution_id,
  ds.summary,
  fr.assets,
  fr.vulnerabilities,
  fr.exploits,
  fr.malware_kits
ORDER BY
  riskscore DESC