-- Vulnerability Count Comparison
-- Copy the SQL query below

WITH
   baseline_scans AS (
      SELECT asset_id, scanAsOf(asset_id, localtimestamp - interval '30 days') AS scan_id
      FROM dim_asset
   ),
   baseline_vulns AS (
      SELECT fasv.vulnerability_id, SUM(fasv.vulnerability_instances) AS instances
      FROM baseline_scans bs
         JOIN fact_asset_scan_vulnerability_finding fasv ON fasv.asset_id = bs.asset_id AND fasv.scan_id = bs.scan_id
      GROUP BY fasv.vulnerability_id
   ),
   current_vulns AS (
      SELECT fav.vulnerability_id, SUM(fav.vulnerability_instances) AS instances
      FROM fact_asset_vulnerability_finding fav
      GROUP BY fav.vulnerability_id
   ),
   baseline_comparison AS (
      SELECT COALESCE(cv.vulnerability_id, bv.vulnerability_id) AS vulnerability_id, COALESCE(cv.instances, 0) AS current_instances, COALESCE(bv.instances, 0) AS baseline_instances,
         COALESCE(cv.instances, 0) - COALESCE(bv.instances, 0) AS difference
      FROM current_vulns cv
         FULL OUTER JOIN baseline_vulns bv ON bv.vulnerability_id = cv.vulnerability_id
   )
SELECT CASE
   WHEN bc.difference > 0 THEN '+'
   WHEN bc.difference < 0 THEN '-'
   ELSE ' '
END AS type, ABS(bc.difference) AS difference, dv.title, bc.current_instances, bc.baseline_instances,
   to_char(now(), 'MM/DD/YYYY') AS current_period, to_char(now() - interval '30 days', 'MM/DD/YYYY') AS baseline_period
FROM baseline_comparison bc
   JOIN dim_vulnerability dv ON bc.vulnerability_id = dv.vulnerability_id
ORDER BY ABS(bc.difference) DESC, dv.title ASC
