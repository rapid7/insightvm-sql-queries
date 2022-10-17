-- Compares two asset group results
-- Copy the SQL query below


WITH
   timestamps AS (
      SELECT date (ts) AS upper_date, date (ts - INTERVAL '1 months') AS lower_date
      FROM generate_series(now() - INTERVAL '1 months', now(), INTERVAL '1 months') AS ts
   ),
   asset_scans AS (
      SELECT da.asset_id, ts.lower_date, ts.upper_date, scanAsOf(da.asset_id, ts.lower_date) AS previous_scan, scanAsOf(da.asset_id, ts.upper_date) AS current_scan
      FROM dim_asset  AS da
         CROSS JOIN timestamps ts
      ORDER BY asset_id, lower_date
   ),
   assets_with_change_between_scans AS (
      SELECT asset_id, upper_date AS date, previous_scan, current_scan
      FROM asset_scans
      WHERE previous_scan <> current_scan
   ),
   assets_with_no_change_between_scans AS (
      SELECT asset_id, upper_date AS date, previous_scan, current_scan
      FROM asset_scans
      WHERE previous_scan = current_scan
   ),
   asset_no_change_previous_vulnerabilities AS (
      SELECT ac.asset_id, ac.date AS date, scan_id, ac.current_scan, vulnerability_id
      FROM assets_with_change_between_scans ac
         JOIN fact_asset_scan_vulnerability_finding fasvf ON fasvf.asset_id = ac.asset_id AND fasvf.scan_id = previous_scan
   ),
   asset_change_current_vulnerabiliites AS (
      SELECT ac.asset_id, ac.date AS date, scan_id, ac.current_scan, vulnerability_id
      FROM assets_with_change_between_scans ac
         JOIN fact_asset_scan_vulnerability_finding fasvf ON fasvf.asset_id = ac.asset_id AND fasvf.scan_id = current_scan
   ),
   asset_previous_and_current_vulnerabilities AS (
      SELECT *
      FROM asset_no_change_previous_vulnerabilities apv
      UNION
      SELECT *
      FROM asset_change_current_vulnerabiliites acv
      ORDER BY asset_id, date
   ),
   asset_previous_and_current_vulnerability_difference AS (
      SELECT asset_id, date, vulnerability_id, baselineComparison(scan_id, current_scan) AS change
      FROM asset_previous_and_current_vulnerabilities
      GROUP BY asset_id, date, vulnerability_id
   ),
   asset_change_count_per_date AS (
      SELECT asset_id, date, change, COUNT(*) AS count
      FROM asset_previous_and_current_vulnerability_difference
      GROUP BY asset_id, date, change
   ),
   asset_change_vulnerability_difference AS (
      SELECT anc.asset_id, anc.date, 'Same'::text, COUNT(*) AS count
      FROM assets_with_no_change_between_scans anc
         JOIN fact_asset_scan_vulnerability_finding fasvf ON fasvf.asset_id = anc.asset_ID AND fasvf.scan_id = anc.current_scan
      GROUP BY anc.asset_id, anc.date
   ),
   asset_change_for_new_and_unchanged_scans AS (
      SELECT * FROM asset_change_count_per_date
      UNION
      SELECT * FROM asset_change_vulnerability_difference
      ORDER BY asset_id, date
   ),
   site_change_by_date AS (
      SELECT asset_group_id, date, change, SUM(count) AS count
      FROM asset_change_for_new_and_unchanged_scans
         JOIN dim_asset_group_asset USING (asset_id)
      GROUP BY asset_group_id, date, change
   ),
   site_dates AS (
      SELECT DISTINCT asset_group_id, date
      FROM site_change_by_date
   ),
   site_change_totals_flattened AS (
      SELECT sd.asset_group_id, sd.date, COALESCE(scnew.count, 0) AS new_count, COALESCE(scold.count, 0) AS old_count, COALESCE(scsame.count, 0) AS same_count
      FROM site_dates sd
         LEFT OUTER JOIN site_change_by_date scnew ON scnew.asset_group_id = sd.asset_group_id AND scnew.date = sd.date AND scnew.change = 'New'
         LEFT OUTER JOIN site_change_by_date scold ON scold.asset_group_id = sd.asset_group_id AND scold.date = sd.date AND scold.change = 'Old'
         LEFT OUTER JOIN site_change_by_date scsame ON scsame.asset_group_id = sd.asset_group_id AND scsame.date = sd.date AND scsame.change = 'Same'
   ),
   asset_change_current_vulnerabiliites_by_severity AS (
      SELECT ac.asset_id, ac.upper_date AS date,
         COUNT(*) AS total_vulnerabilities,
         SUM(CASE WHEN severity = 'Moderate' THEN 1 ELSE 0 END) AS moderate_vulns,
         SUM(CASE WHEN severity = 'Severe' THEN 1 ELSE 0 END) AS severe_vulns,
         SUM(CASE WHEN severity = 'Critical' THEN 1 ELSE 0 END) AS critical_vulns
      FROM asset_scans ac
         JOIN fact_asset_scan_vulnerability_finding fasvf ON fasvf.asset_id = ac.asset_id AND fasvf.scan_id = ac.current_scan
         JOIN dim_vulnerability USING (vulnerability_id)
      GROUP BY ac.asset_id, ac.upper_date
   ),
   site_current_vulnerabilities_by_severity AS (
      SELECT asset_group_id, date, SUM(total_vulnerabilities) AS total_vulnerabilities, SUM(moderate_vulns) AS moderate_vulns, SUM(severe_vulns) AS severe_vulns, SUM(critical_vulns) AS critical_vulns
      FROM asset_change_current_vulnerabiliites_by_severity
         JOIN dim_asset_group_asset USING (asset_id)
      GROUP BY asset_group_id, date
   ),
  two_week_scans AS ( SELECT ds.name, site_change_totals_flattened.*, scvs.total_vulnerabilities, scvs.moderate_vulns, scvs.severe_vulns, scvs.critical_vulns
   FROM site_change_totals_flattened
      JOIN dim_asset_group ds USING (asset_group_id)
      LEFT OUTER JOIN site_current_vulnerabilities_by_severity scvs USING (asset_group_id, date)
JOIN dim_scope_asset_group dsag ON ds.asset_group_id = dsag.asset_group_id
ORDER BY site_change_totals_flattened.date DESC),
 
last_scan AS (SELECT dag.asset_group_id,
(
SELECT tws.date
FROM two_week_scans AS tws
WHERE asset_group_id = dag.asset_group_id
LIMIT 1) AS current_scan
FROM dim_asset_group dag),
 
old_scan AS (SELECT dag.asset_group_id,
(SELECT tws.date
FROM two_week_scans AS tws
WHERE asset_group_id = dag.asset_group_id AND date NOT IN (SELECT current_scan FROM last_scan WHERE asset_group_id = dag.asset_group_id)
LIMIT 1
) AS prev_scan
FROM dim_asset_group dag),
 
current_data AS (SELECT tws.name, tws.asset_group_id, tws.date, tws.new_count, tws.old_count, tws.same_count, tws.total_vulnerabilities, tws.moderate_vulns, tws.severe_vulns, tws.critical_vulns
FROM two_week_scans tws
JOIN last_scan ls ON ls.asset_group_id = tws.asset_group_id AND ls.current_scan = tws.date),
 
prev_data AS (SELECT tws.name, tws.asset_group_id, tws.date, tws.new_count, tws.old_count, tws.same_count, tws.total_vulnerabilities, tws.moderate_vulns, tws.severe_vulns, tws.critical_vulns
FROM two_week_scans tws
JOIN old_scan os ON os.asset_group_id = tws.asset_group_id AND os.prev_scan = tws.date)
 
SELECT cd.name as asset_group, cd.date as current_date, cd.new_count as current_new_count, cd.old_count as current_old_count, cd.same_count as current_same_count, cd.total_vulnerabilities as current_total_vulns, cd.moderate_vulns AS current_moderate_vulns, cd.severe_vulns as current_severe_vulns, cd.critical_vulns AS current_critical_vulns, pd.date as previous_date, pd.new_count as previous_new_count, pd.old_count as previous_old_count, pd.same_count as previous_same_count, pd.total_vulnerabilities as previous_total_vulns, pd.moderate_vulns as previous_moderate_vulns, pd.severe_vulns AS previous_severe_vulns, pd.critical_vulns AS previous_critical_vulns,
 
COALESCE(ROUND(CAST(((CAST((cd.total_vulnerabilities - pd.total_vulnerabilities) AS DECIMAL)*100)/NULLIF(pd.total_vulnerabilities,0)) AS DECIMAL)),0) AS percent_change_total_vulns,
 
COALESCE(ROUND(CAST(((CAST((cd.old_count - pd.old_count) AS DECIMAL)*100)/NULLIF(pd.old_count,0)) AS DECIMAL)),0)  AS percent_change_old_vulns,
 
COALESCE(ROUND(CAST(((CAST((cd.same_count - pd.same_count) AS DECIMAL)*100)/NULLIF(pd.same_count,0)) AS DECIMAL)),0) AS percent_change_same_vulns,
 
COALESCE(ROUND(CAST((CAST((cd.old_count) AS DECIMAL)*100/NULLIF(pd.total_vulnerabilities,0)) AS DECIMAL)),0) AS percent_vulns_fixed,
 
CASE WHEN COALESCE(ROUND(CAST(((CAST((cd.total_vulnerabilities - pd.total_vulnerabilities) AS DECIMAL)*100)/NULLIF(pd.total_vulnerabilities,0)) AS DECIMAL)),0) > 0 THEN '<font color=red>INCREASED</font>'
WHEN COALESCE(ROUND(CAST(((CAST((cd.total_vulnerabilities - pd.total_vulnerabilities) AS DECIMAL)*100)/NULLIF(pd.total_vulnerabilities,0)) AS DECIMAL)),0) < 0 THEN '<font color=green>DECREASED</font>'
ELSE '<font color=blue>NO CHANGE</font>'
END AS percent_change_total_vulns_word,
 
CASE WHEN COALESCE(ROUND(CAST(((CAST((cd.old_count - pd.old_count) AS DECIMAL)*100)/NULLIF(pd.old_count,0)) AS DECIMAL)),0) > 0 THEN '<font color=green>INCREASED</font>'
WHEN COALESCE(ROUND(CAST(((CAST((cd.old_count - pd.old_count) AS DECIMAL)*100)/NULLIF(pd.old_count,0)) AS DECIMAL)),0) < 0 THEN '<font color=red>DECREASED</font>'
ELSE '<font color=blue>NO CHANGE</font>'
END AS percent_change_old_vulns_word,
 
CASE WHEN COALESCE(ROUND(CAST(((CAST((cd.same_count - pd.same_count) AS DECIMAL)*100)/NULLIF(pd.same_count,0)) AS DECIMAL)),0) > 0 THEN '<font color=green>INCREASED</font>'
WHEN COALESCE(ROUND(CAST(((CAST((cd.same_count - pd.same_count) AS DECIMAL)*100)/NULLIF(pd.same_count,0)) AS DECIMAL)),0) < 0 THEN '<font color=red>DECREASED</font>'
ELSE '<font color=blue>NO CHANGE</font>'
END AS percent_change_same_vulns_word,
 
CASE WHEN cd.total_vulnerabilities > pd.total_vulnerabilities THEN '<font color=red>INCREASED</font>'
WHEN cd.total_vulnerabilities < pd.total_vulnerabilities THEN '<font color=green>DECREASED</font>'
ELSE '<font color=blue>NO CHANGE</font>'
END AS percent_change_same_vulns_word
 
FROM current_data AS cd
JOIN prev_data AS pd USING (asset_group_id)
