-- provides all asssets with expiring certificiates.  Default is within 90 days, modifiable in last line
-- Copy the SQL query below
WITH cert_expiration_dates AS (
   SELECT
      DISTINCT asset_id,
      service_id,
      name,
      value
   FROM
      dim_asset_service_configuration
   WHERE
      lower(name) LIKE '%ssl.cert.not.valid.after'
)
SELECT
   ip_address,
   host_name,
   mac_address,
   date(ced.value)
FROM
   dim_asset
   JOIN cert_expiration_dates AS ced USING (asset_id)
WHERE
   CURRENT_TIMESTAMP - cast(ced.value AS DATE) <= INTERVAL '90 days'
ORDER BY
   date