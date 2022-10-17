-- Assets in Policy Compliance
-- Copy the SQL query below

SELECT da.ip_address, da.host_name, fasp.scope, fasp.date_tested, fasp.passed_rules, fasp.failed_rules, fasp.not_applicable_rules, fasp.rule_compliance, dp.title, dp.total_rules, dp.benchmark_name, dp.category,
dpr.title, dpr.description, dpr.scope
FROM fact_asset_scan_policy fasp
        JOIN dim_policy dp USING (policy_id)
        JOIN dim_policy_rule dpr USING (policy_id)
        JOIN dim_asset da USING (asset_id)
ORDER BY da.ip_address
