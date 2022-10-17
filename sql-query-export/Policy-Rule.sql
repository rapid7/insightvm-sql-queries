-- Policy Compliance for specific rule
-- Copy the SQL query below


WITH
asset_table as (SELECT fa.asset_id, dacs.aggregated_credential_status_description
FROM fact_asset fa
JOIN dim_aggregated_credential_status dacs USING (aggregated_credential_status_id)
GROUP BY fa.asset_id, dacs.aggregated_credential_status_description
)
SELECT da.ip_address AS "IP Address", da.host_name AS "Host Name", dos.description AS "OS", dp.title AS "Policy", dpr.title as"Rule", dprs.description AS "Compliance", fapr.proof, at.aggregated_credential_status_description AS "Status"
FROM fact_asset_policy_rule fapr
JOIN dim_asset da USING (asset_id)
JOIN dim_policy_rule dpr USING (rule_id)
JOIN dim_policy dp ON (dp.policy_id=fapr.policy_id)
JOIN dim_policy_result_status dprs ON (dprs.status_id=fapr.status_id)
JOIN dim_operating_system dos USING (operating_system_id)
JOIN asset_table at ON (at.asset_id=fapr.asset_id)
WHERE dp.title ILIKE 'CIS Microsoft Windows Server 2008 R2 Level One%' AND dpr.title ILIKE '2.3.11.7%'
