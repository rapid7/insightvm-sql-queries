-- collects details on Asset Group based on critical, High, medium and low risk vulnd
-- Copy the SQL query below
WITH group_asset_summary as (
  SELECT
    dag.asset_group_id,
    dag.name,
    fa.asset_id
  FROM
    fact_asset as fa
    JOIN dim_asset da USING (asset_id)
    JOIN dim_asset_group_asset USING (asset_id)
    JOIN dim_asset_group dag USING (asset_group_id)
),
vulnerability_summary as (
  SELECT
    gas.asset_group_id,
    gas.name,
    gas.asset_id,
    dv.vulnerability_id,
    dv.cvss_score,
    dv.date_published,
    dv.exploits
  FROM
    dim_vulnerability dv
    LEFT JOIN dim_vulnerability_exception dve ON dv.vulnerability_id = dve.vulnerability_id
    JOIN fact_asset_vulnerability_finding favf ON favf.vulnerability_id = dv.vulnerability_id
    JOIN group_asset_summary gas ON gas.asset_id = favf.asset_id
  WHERE
    dve.vulnerability_id IS NULL
)
SELECT
  dag.name as "Asset Group",
  (
    SELECT
      count(DISTINCT(vs.asset_id))
    FROM
      vulnerability_summary vs
    WHERE
      dag.asset_group_id = vs.asset_group_id
  ) as "Total Assets In Group",
  fag.assets as "# of Assets Discovered Last Scan",
  (
    SELECT
      count(DISTINCT(vs.asset_id))
    FROM
      vulnerability_summary vs
      JOIN dim_asset_service_credential dasc USING(asset_id)
    WHERE
      dasc.credential_status_id IN(3, 4, 5, 6)
      AND dag.asset_group_id = vs.asset_group_id
  ) as "# of Assets Authenticated",
  (
    SELECT
      COUNT(DISTINCT(vs.asset_id))
    FROM
      vulnerability_summary vs
    WHERE
      vs.exploits > 0
      AND vs.asset_group_id = dag.asset_group_id
  ) AS "# of Assets with 0 Day Exploits",
  (
    SELECT
      COUNT(vs.asset_id)
    FROM
      vulnerability_summary vs
    WHERE
      vs.asset_group_id = dag.asset_group_id
      AND vs.cvss_score >= 9
      AND vs.cvss_score <= 10
      AND vs.date_published <= date(now() - interval '30 days')
  ) as "Critical Vulns > 30 Days",
  (
    SELECT
      COUNT(vs.asset_id)
    FROM
      vulnerability_summary vs
    WHERE
      vs.asset_group_id = dag.asset_group_id
      AND vs.cvss_score >= 7
      AND vs.cvss_score <= 8
      AND vs.date_published <= date(now() - interval '30 days')
  ) as "High Vulns > 30 Days",
  (
    SELECT
      COUNT(vs.asset_id)
    FROM
      vulnerability_summary vs
    WHERE
      vs.asset_group_id = dag.asset_group_id
      AND vs.cvss_score >= 4
      AND vs.cvss_score <= 6
      AND vs.date_published <= date(now() - interval '90 days')
  ) as "Medium Vulns > 90 Days",
  (
    SELECT
      COUNT(vs.asset_id)
    FROM
      vulnerability_summary vs
    WHERE
      vs.asset_group_id = dag.asset_group_id
      AND vs.cvss_score >= 0
      AND vs.cvss_score <= 3
      AND vs.date_published <= date(now() - interval '180 days')
  ) as "Low Vulns > 180 Days"
FROM
  dim_asset_group dag
  JOIN fact_asset_group fag ON dag.asset_group_id = fag.asset_group_id