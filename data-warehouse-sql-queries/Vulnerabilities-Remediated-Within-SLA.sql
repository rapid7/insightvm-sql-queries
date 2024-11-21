-- Data Warehouse
-- Presents the number of days to remediate asset vulnerabilities and whether or not they sit inside or outside a 30 day (modifiable) remediation SLA.  
-- This query only assumes remediation in that the vulnerability was no longer located on the asset and wrote the vulnerability no longer found out to the 'fact_asset_vulnerability_remediation_date' table
-- Copy the SQL query below

select vfd.asset_id, vfd.vulnerability_id, vfd.critical_vulnerabilities,
vfd.severe_vulnerabilities, extract (day from rd.day - vfd.date) as sla_days,
case when (select extract (day from rd.day - vfd.date)) <= 30 then 'yes'
else 'no'
end sla_met
from fact_asset_vulnerability_finding_date vfd
join fact_asset_vulnerability_remediation_date rd ON (rd.vulnerability_id = vfd.vulnerability_id AND rd.asset_id = vfd.asset_id)
where vfd.critical_vulnerabilities = '1' or
vfd.severe_vulnerabilities = '1'
