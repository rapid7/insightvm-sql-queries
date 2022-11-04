-- Console report to pull policy, rules and rules descriptions for assets
-- Copy the SQL query below
select da.ip_address, da.host_name, dos.name as OS, dos.version as OS_Version, dp.title as Policy_Title, dpr.title as Rule_Name, dpr.description as Rule_Description, dprs.description as Complaince_Status
from fact_asset_policy_rule as fpr
join dim_asset as da on fpr.asset_id = da.asset_id
join dim_operating_system as dos using (operating_system_id)
join dim_policy as dp on fpr.policy_id = dp.policy_id
join dim_policy_rule as dpr on fpr.rule_id = dpr.rule_id
join dim_policy_result_status as dprs on fpr.status_id = dprs.status_id
WHERE dprs.description != 'Not applicable'
ORDER BY da.ip_address, dp.title
