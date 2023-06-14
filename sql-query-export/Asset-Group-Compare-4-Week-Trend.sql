-- Provide site asset group running totals of total vulns, moderate, severe and critical  for past 4 weeks.
-- Copy the SQL query below
WITH timestamps AS (
   SELECT
      date (ts) AS upper_date,
      date (ts - INTERVAL '1 weeks') AS lower_date
   FROM
      generate_series(
         now() - INTERVAL '3 weeks',
         now(),
         INTERVAL '1 week'
      ) AS ts
),
asset_scans AS (
   SELECT
      da.asset_id,
      ts.lower_date,
      ts.upper_date,
      scanAsOf(da.asset_id, ts.lower_date) AS previous_scan,
      scanAsOf(da.asset_id, ts.upper_date) AS current_scan
   FROM
      dim_asset AS da
      CROSS JOIN timestamps ts
   ORDER BY
      asset_id,
      lower_date
),
assets_with_change_between_scans AS (
   SELECT
      asset_id,
      upper_date AS date,
      previous_scan,
      current_scan
   FROM
      asset_scans
   WHERE
      previous_scan <> current_scan
),
assets_with_no_change_between_scans AS (
   SELECT
      asset_id,
      upper_date AS date,
      previous_scan,
      current_scan
   FROM
      asset_scans
   WHERE
      previous_scan = current_scan
),
asset_no_change_previous_vulnerabilities AS (
   SELECT
      ac.asset_id,
      ac.date AS date,
      scan_id,
      ac.current_scan,
      vulnerability_id
   FROM
      assets_with_change_between_scans ac
      JOIN fact_asset_scan_vulnerability_finding fasvf ON fasvf.asset_id = ac.asset_id
      AND fasvf.scan_id = previous_scan
),
asset_change_current_vulnerabiliites AS (
   SELECT
      ac.asset_id,
      ac.date AS date,
      scan_id,
      ac.current_scan,
      vulnerability_id
   FROM
      assets_with_change_between_scans ac
      JOIN fact_asset_scan_vulnerability_finding fasvf ON fasvf.asset_id = ac.asset_id
      AND fasvf.scan_id = current_scan
),
asset_previous_and_current_vulnerabilities AS (
   SELECT
      *
   FROM
      asset_no_change_previous_vulnerabilities apv
   UNION
   SELECT
      *
   FROM
      asset_change_current_vulnerabiliites acv
   ORDER BY
      asset_id,
      date
),
asset_previous_and_current_vulnerability_difference AS (
   SELECT
      asset_id,
      date,
      vulnerability_id,
      baselineComparison(scan_id, current_scan) AS change
   FROM
      asset_previous_and_current_vulnerabilities
   GROUP BY
      asset_id,
      date,
      vulnerability_id
),
asset_change_count_per_date AS (
   SELECT
      asset_id,
      date,
      change,
      COUNT(*) AS count
   FROM
      asset_previous_and_current_vulnerability_difference
   GROUP BY
      asset_id,
      date,
      change
),
asset_change_vulnerability_difference AS (
   SELECT
      anc.asset_id,
      anc.date,
      'Same' :: text,
      COUNT(*) AS count
   FROM
      assets_with_no_change_between_scans anc
      JOIN fact_asset_scan_vulnerability_finding fasvf ON fasvf.asset_id = anc.asset_ID
      AND fasvf.scan_id = anc.current_scan
   GROUP BY
      anc.asset_id,
      anc.date
),
asset_change_for_new_and_unchanged_scans AS (
   SELECT
      *
   FROM
      asset_change_count_per_date
   UNION
   SELECT
      *
   FROM
      asset_change_vulnerability_difference
   ORDER BY
      asset_id,
      date
),
site_change_by_date AS (
   SELECT
      asset_group_id,
      date,
      change,
      SUM(count) AS count
   FROM
      asset_change_for_new_and_unchanged_scans
      JOIN dim_asset_group_asset USING (asset_id)
   GROUP BY
      asset_group_id,
      date,
      change
),
site_dates AS (
   SELECT
      DISTINCT asset_group_id,
      date
   FROM
      site_change_by_date
),
site_change_totals_flattened AS (
   SELECT
      sd.asset_group_id,
      sd.date,
      COALESCE(scnew.count, 0) AS new_count,
      COALESCE(scold.count, 0) AS old_count,
      COALESCE(scsame.count, 0) AS same_count
   FROM
      site_dates sd
      LEFT OUTER JOIN site_change_by_date scnew ON scnew.asset_group_id = sd.asset_group_id
      AND scnew.date = sd.date
      AND scnew.change = 'New'
      LEFT OUTER JOIN site_change_by_date scold ON scold.asset_group_id = sd.asset_group_id
      AND scold.date = sd.date
      AND scold.change = 'Old'
      LEFT OUTER JOIN site_change_by_date scsame ON scsame.asset_group_id = sd.asset_group_id
      AND scsame.date = sd.date
      AND scsame.change = 'Same'
),
asset_change_current_vulnerabiliites_by_severity AS (
   SELECT
      ac.asset_id,
      ac.upper_date AS date,
      COUNT(*) AS total_vulnerabilities,
      SUM(
         CASE
            WHEN severity = 'Moderate' THEN 1
            ELSE 0
         END
      ) AS moderate_vulns,
      SUM(
         CASE
            WHEN severity = 'Severe' THEN 1
            ELSE 0
         END
      ) AS severe_vulns,
      SUM(
         CASE
            WHEN severity = 'Critical' THEN 1
            ELSE 0
         END
      ) AS critical_vulns
   FROM
      asset_scans ac
      JOIN fact_asset_scan_vulnerability_finding fasvf ON fasvf.asset_id = ac.asset_id
      AND fasvf.scan_id = ac.current_scan
      JOIN dim_vulnerability USING (vulnerability_id)
   GROUP BY
      ac.asset_id,
      ac.upper_date
),
site_current_vulnerabilities_by_severity AS (
   SELECT
      asset_group_id,
      date,
      SUM(total_vulnerabilities) AS total_vulnerabilities,
      SUM(moderate_vulns) AS moderate_vulns,
      SUM(severe_vulns) AS severe_vulns,
      SUM(critical_vulns) AS critical_vulns
   FROM
      asset_change_current_vulnerabiliites_by_severity
      JOIN dim_asset_group_asset USING (asset_id)
   GROUP BY
      asset_group_id,
      date
)
SELECT
   ds.name,
   sctf.*,
   scvs.total_vulnerabilities,
   scvs.moderate_vulns,
   scvs.severe_vulns,
   scvs.critical_vulns,
   CASE
      WHEN sctf.date = date(now()) THEN 'Week 4'
      WHEN sctf.date = date(now() - INTERVAL '1 weeks') THEN 'Week 3'
      WHEN sctf.date = date(now() - INTERVAL '2 weeks') THEN 'Week 2'
      WHEN sctf.date = date(now() - INTERVAL '3 weeks') THEN 'Week 1'
   END AS week
FROM
   site_change_totals_flattened sctf
   JOIN dim_asset_group ds USING (asset_group_id)
   LEFT OUTER JOIN site_current_vulnerabilities_by_severity scvs USING (asset_group_id, date)
   JOIN dim_scope_asset_group dsag ON ds.asset_group_id = dsag.asset_group_id
ORDER BY
   sctf.date DESC