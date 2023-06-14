--- Policy results and exceptions (if present)
--- Copy the SQL query below
SELECT
    dpr.title,
    dpr.description,
    dpr.severity,
    da.ip_address,
    dpr.remediation,
    dp.title Benchmark,
    htmlToText(fapr.proof) proof,
    dpo.comments,
    dpo.review_comments
FROM
    fact_asset_policy_rule fapr
    JOIN dim_policy dp on dp.policy_id = fapr.policy_id
    JOIN dim_policy_rule dpr on dpr.policy_id = fapr.policy_id
    and fapr.rule_id = dpr.rule_id
    JOIN dim_asset da on da.asset_id = fapr.asset_id
    LEFT JOIN dim_policy_result_status AS dprs ON fapr.status_id = dprs.status_id
    LEFT JOIN dim_policy_override AS dpo ON fapr.override_id = dpo.override_id