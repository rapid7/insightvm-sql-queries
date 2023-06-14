-- Authentication success by asset by last assessed within 50 days.
-- Copy the SQL query below
SELECT
  da.asset_id AS "asset id",
  da.ip_address AS "ip address",
  da.host_name AS "host name",
  CASE
    WHEN s.accesslevel IS NOT NULL THEN s.accesslevel
    ELSE dacs.aggregated_credential_status_description
  END AS "access level",
  0 AS "exclusions",
  CASE
    WHEN ds.name = 'Rapid7 Insight Agents' THEN 1
    ELSE 0
  END AS "agent",
  porttext AS "ports"
FROM
  dim_asset da
  JOIN fact_asset fa ON da.asset_id = fa.asset_id
  JOIN dim_site_asset dsa ON fa.asset_id = dsa.asset_id
  JOIN dim_site ds USING (site_id)
  JOIN dim_aggregated_credential_status dacs ON dacs.aggregated_credential_status_id = fa.aggregated_credential_status_id
  JOIN dim_operating_system dos ON da.operating_system_id = dos.operating_system_id
  LEFT JOIN (
    SELECT
      da1.asset_id,
      array_to_string(ARRAY_AGG(port), ',') AS porttext
    FROM
      dim_asset da1
      JOIN fact_asset fa1 ON da1.asset_id = fa1.asset_id
      JOIN dim_asset_service_credential dsc1 ON da1.asset_id = dsc1.asset_id
      JOIN dim_aggregated_credential_status dacs1 ON dacs1.aggregated_credential_status_id = fa1.aggregated_credential_status_id
      AND dacs1.aggregated_credential_status_description = 'All credentials successful'
    GROUP BY
      da1.asset_id
  ) sub ON da.asset_id = sub.asset_id
  LEFT JOIN (
    SELECT
      asset_id,
      ip_address,
      CASE
        WHEN SUM("authentication partial success") = 12 THEN 'Credentials partially successful'
      END AS accesslevel
    FROM
      (
        SELECT
          DISTINCT da.asset_id,
          dsc.port,
          da.ip_address,
          dcs.credential_status_description,
          CASE
            WHEN dsc.port = 139
            AND dcs.credential_status_description = 'Login successful' THEN 5
            WHEN dsc.port = 445
            AND dcs.credential_status_description = 'Login successful' THEN 5
            WHEN dsc.port = 135
            AND dcs.credential_status_description = 'Login successful' THEN 10
            WHEN dsc.port = 139
            AND dcs.credential_status_description = 'Login failed' THEN 1
            WHEN dsc.port = 445
            AND dcs.credential_status_description = 'Login failed' THEN 1
            WHEN dsc.port = 135
            AND dcs.credential_status_description = 'Login failed' THEN 2
            ELSE 0
          END AS "authentication partial success"
        FROM
          dim_asset da
          JOIN dim_asset_service_credential dsc ON da.asset_id = dsc.asset_id
          JOIN dim_credential_status dcs USING (credential_status_id)
        WHERE
          da.last_assessed_for_vulnerabilities > now() - INTERVAL '50 DAYS'
          AND dsc.port IN (139, 445, 135)
          AND dcs.credential_status_description IN (
            'Login failed',
            'Login successful'
          )
      ) a
    GROUP BY
      asset_id,
      ip_address
  ) s ON da.asset_id = s.asset_id
  AND da.ip_address = s.ip_address
WHERE
  da.last_assessed_for_vulnerabilities > now() - INTERVAL '50 DAYS'
ORDER BY
  da.asset_id DESC