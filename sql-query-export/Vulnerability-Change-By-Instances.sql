-- Vulnerability Changes by Instance
-- Copy the SQL query below

WITH 
lower_baseline_assets AS ( 
    SELECT asset_id, scanAsOf(asset_id, date_trunc( 'month', now() )::date) as scan_id,
    date_trunc( 'month', now() )::date as lower_timestamp
    FROM dim_asset 
), 
current_baseline_asset AS ( 
    SELECT asset_id, scanAsOf(asset_id, (date_trunc( 'month', now() + INTERVAL '1 MONTH - 1 day')::date - INTERVAL '1 day')::date) as scan_id,
    (date_trunc( 'month', now() + INTERVAL '1 MONTH - 1 day')::date - INTERVAL '1 day')::date as baseline_timestamp
    FROM dim_asset 
), 
first_asset_snapshot_vulnerabilities AS ( 
    SELECT asset_id, scan_id as scan_id, vulnerability_id, lower_timestamp, vulnerability_instances
    FROM fact_asset_scan_vulnerability_finding 
      JOIN lower_baseline_assets USING (asset_id, scan_id) 
), 
last_asset_snapshot_vulnerabilities AS ( 
    SELECT asset_id, scan_id as scan_id, vulnerability_id, baseline_timestamp, vulnerability_instances, severity
    FROM fact_asset_scan_vulnerability_finding 
      JOIN current_baseline_asset USING (asset_id, scan_id)
      JOIN dim_vulnerability AS vs USING (vulnerability_id)
), 
vulnerability_state AS ( 
    SELECT vulnerability_id, baselineComparison(state, 2) as status, vulnerability_instances
    FROM ( 
      SELECT DISTINCT vulnerability_id, 2 AS state, baseline_timestamp, vulnerability_instances FROM last_asset_snapshot_vulnerabilities 
      UNION 
      SELECT DISTINCT vulnerability_id, 1 AS state, lower_timestamp, vulnerability_instances FROM first_asset_snapshot_vulnerabilities 
    ) all_state 
    GROUP BY vulnerability_id, vulnerability_instances
),
vulnerability_instance_counts AS (
  SELECT SUM(vulnerability_instances) AS instance_count, vulnerability_id FROM fact_asset_scan_vulnerability_finding AS fasvf
  JOIN current_baseline_asset AS cba ON cba.scan_id = fasvf.scan_id AND cba.asset_id = fasvf.asset_id
  GROUP BY fasvf.vulnerability_id
  ORDER BY fasvf.vulnerability_id
), 
vulnerability_state_counts AS ( 
    SELECT SUM(CASE WHEN status = 'New' THEN vic.instance_count ELSE 0 END) AS "New Vulnerabilities", 
      SUM(CASE WHEN status = 'Old' THEN vic.instance_count ELSE 0 END) AS "Closed Vulnerabilities",
      SUM(CASE WHEN status = 'Same' THEN vic.instance_count ELSE 0 END) AS "Existing Vulnerabilities",      
      (SELECT SUM(vulnerability_instances) FROM last_asset_snapshot_vulnerabilities WHERE severity = 'Moderate') AS "Open Moderate Vulnerabilities",
      (SELECT SUM(vulnerability_instances) FROM last_asset_snapshot_vulnerabilities WHERE severity = 'Severe') AS "Open Severe Vulnerabilities",
      (SELECT SUM(vulnerability_instances) FROM last_asset_snapshot_vulnerabilities WHERE severity = 'Critical') AS "Open Critical Vulnerabilities",
      (SELECT DISTINCT(baseline_timestamp) FROM last_asset_snapshot_vulnerabilities) AS "As Of"

    FROM vulnerability_state
    JOIN vulnerability_instance_counts AS vic USING (vulnerability_id)
) 
 
SELECT * FROM vulnerability_state_counts
