-- New assets discovered against previous scan
--Query Will Provide:
-- IP Address
-- Host Name
-- Operating System
-- OS Ver
-- Date when asset was discovered
-- Asset State
-- Copy the SQL query below
WITH last_two_scans AS (
  SELECT
    scan_id,
    finished
  FROM
    dim_scan
  ORDER BY
    finished DESC
  LIMIT
    2
), previous_scan_id AS (
  SELECT
    scan_id
  FROM
    last_two_scans
  ORDER BY
    finished ASC
  LIMIT
    1
), last_scan_id AS (
  SELECT
    scan_id
  FROM
    last_two_scans
  ORDER BY
    finished DESC
  LIMIT
    1
), asset_state_difference AS (
  SELECT
    asset_id,
    scan_id,
    baselineComparison(
      scan_id,
      (
        SELECT
          scan_id
        FROM
          last_scan_id
      )
    ) AS delta_in_last_scan
  FROM
    (
      SELECT
        asset_id,
        scan_id
      FROM
        fact_asset_scan
      WHERE
        scan_id = (
          SELECT
            scan_id
          FROM
            previous_scan_id
        )
      UNION
      SELECT
        asset_id,
        scan_id
      FROM
        fact_asset_scan
      WHERE
        scan_id = (
          SELECT
            scan_id
          FROM
            last_scan_id
        )
    ) state
  GROUP BY
    asset_id,
    scan_id
)
SELECT
  da.ip_address,
  da.host_name,
  dos.name,
  dos.version,
  CAST(das.scan_finished as DATE) AS Date,
  asd.delta_in_last_scan
FROM
  asset_state_difference asd
  JOIN dim_asset da USING (asset_id)
  JOIN dim_operating_system dos USING (operating_system_id)
  JOIN dim_asset_scan AS das USING (scan_id)
WHERE
  delta_in_last_scan LIKE 'New'
  or delta_in_last_scan LIKE '%Old%'