-- Vulnerability instances with CVSS score >= 9 and percentage of total assets
-- Copy the SQL query below

WITH 
vulns_nine AS (select sum(vulnerability_instances) AS instances
FROM fact_asset_vulnerability_finding
JOIN dim_vulnerability using (vulnerability_id)
WHERE cvss_score >=9
),
all_vulns AS (SELECT sum(vulnerability_instances) AS instances
FROM fact_asset_vulnerability_finding
)
SELECT vulns_nine.instances vulns_9, all_vulns.instances all_vulns, (vulns_nine.instances/all_vulns.instances) AS percent_9
FROM vulns_nine,all_vulns
