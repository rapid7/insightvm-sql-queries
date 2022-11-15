--- SSL Certs providing the following detail:

-- IP Address
-- Host name
-- Port
-- Issuer
-- Subject
-- Algorithm
-- Algorithm Signature
-- Key Size
-- Invalid Before Date
-- Invalid after Date
-- Expires in Days
-- Optional: Filters SSL Certs expiring between 30 and 90 days.
-- Similar to sql written for console(SSL-Certs.sql.  Column name service_id in dim_asset_service_configuration on console does not exist in warehouse, so removed for warehouse version and change group by.
-- Copy the SQL query below
SELECT
   da.ip_address AS "Host IP Address",
   da.host_name AS "Hostname",
   da.mac_address AS "MAC Address",
   json_certs.port AS "Port",
   json_certs.cert->>'ssl.cert.issuer.dn' AS "Issuer",
   json_certs.cert->>'ssl.cert.subject.dn' AS "Subject",
   json_certs.cert->>'ssl.cert.key.alg.name' AS "Algorithm",
   json_certs.cert->>'ssl.cert.sig.alg.name' AS "Algorithm Signature",
   json_certs.cert->>'ssl.cert.key.rsa.modulusBits' AS "Key Size",
   json_certs.cert->>'ssl.cert.not.valid.before' AS "Invalid Before",
   json_certs.cert->>'ssl.cert.not.valid.after' AS "Invalid After",
   (CAST(json_certs.cert->>'ssl.cert.not.valid.after' AS DATE) - CURRENT_DATE) AS "Expires In (days)"
FROM (
SELECT asset_id, port, json_object_agg(name, replace(value::text, '"', '')) as cert
FROM dim_asset_service_configuration
WHERE lower(name) LIKE 'ssl.cert.%'
GROUP BY 1, 2
) AS json_certs
JOIN dim_asset AS da USING (asset_id)
