-- Score Card by Asset Group
-- Copy the SQL query below
WITH asset_data as (
     SELECT
          da.asset_group_id as group_id,
          count(da.asset_id) as assets,
          sum(fa.vulnerabilities) as vulns,
          ROUND(AVG(fa.riskscore)) as avg_host_score,
          ROUND(MAX(fa.riskscore)) as highest_host
     FROM
          fact_asset as fa
          JOIN dim_asset_group_asset as da ON fa.asset_id = da.asset_id
          JOIN dim_scope_asset_group dsag ON dsag.asset_group_id = da.asset_group_id
     GROUP BY
          da.asset_group_id
),
score_rank as (
     SELECT
          ad.group_id as group_id,
          CASE
               WHEN ad.avg_host_score > 35000 THEN 5
               WHEN ad.avg_host_score BETWEEN 25001
               and 35000 THEN 4
               WHEN ad.avg_host_score BETWEEN 10001
               and 25000 THEN 3
               WHEN ad.avg_host_score BETWEEN 2501
               and 10000 THEN 2
               ELSE 1
          END as score
     FROM
          asset_data as ad
),
host_curve as (
     SELECT
          ad.group_id as group_id,
          CASE
               WHEN ad.highest_host > 75000 THEN sr.score + 4
               WHEN ad.highest_host BETWEEN 65000
               and 75000 THEN sr.score + 3
               WHEN ad.highest_host BETWEEN 55000
               and 64999 THEN sr.score + 2
               WHEN ad.highest_host BETWEEN 45000
               and 54999 THEN sr.score + 1
               ELSE sr.score
          END as curve
     FROM
          asset_data as ad
          JOIN score_rank as sr ON ad.group_id = sr.group_id
)
SELECT
     dag.name as group_name,
     ad.assets,
     ad.vulns,
     ad.avg_host_score,
     ad.highest_host,
     CASE
          WHEN hc.curve > 4 THEN 'F'
          WHEN hc.curve = 4 THEN 'D'
          WHEN hc.curve = 3 THEN 'C'
          WHEN hc.curve = 2 THEN 'B'
          WHEN hc.curve = 1 THEN 'A'
     END as grade
FROM
     asset_data as ad
     JOIN host_curve as hc ON ad.group_id = hc.group_id
     JOIN dim_asset_group dag ON ad.group_id = dag.asset_group_id
ORDER BY
     dag.name ASC