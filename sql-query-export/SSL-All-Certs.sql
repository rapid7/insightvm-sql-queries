-- he following query will list all assets with both expired and current certs.
-- The query will list the following:  Last Scan Date, Host IP Address, Hostname, MAC Address, Port, Issuer, Subject, Algorithm, Algorithm Signature, Key Size, Invalid Before, Invalid After, Expires in (days)

-- Optional(add at end):
-- WHERE (CAST(json_certs.cert->>'ssl.cert.not.valid.after' AS DATE) - CURRENT_DATE) >= 30 AND (CAST(json_certs.cert->>'ssl.cert.not.valid.after' AS DATE) - CURRENT_DATE) <= 90


-- Copy the SQL query below

SELECT DISTINCT
da.last_assessed_for_vulnerabilities AS "Last Scan Date",
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
SELECT asset_id, service_id, port, json_object_agg(name, replace(value::text, '"', '')) as cert
FROM dim_asset_service_configuration

WHERE lower(name) like 'ssl.cert.%'
GROUP BY 1, 2, 3

) as json_certs
JOIN dim_asset AS da USING (asset_id)
