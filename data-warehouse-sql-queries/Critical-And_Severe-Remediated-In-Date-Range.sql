-- Data Warehouse
-- This will simply count the number of critical and severe vulns remediated within a range of time (assuming supported by data retention settings)
-- Copy the SQL query below

select count (vrd.vulnerability_id)
from fact_asset_vulnerability_remediation_date vrd
join fact_asset_vulnerability_finding_date vfd
using (vulnerability_id)
where vrd.day between '2020-08-21' and '2020-08-29' AND
vfd.critical_vulnerabilities = '1' or
vfd.severe_vulnerabilities = '1'
