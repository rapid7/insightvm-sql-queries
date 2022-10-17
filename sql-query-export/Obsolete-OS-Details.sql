-- Obsolete OS Details
-- Copy the SQL query below

select distinct ip_address, host_name, sites, last_assessed_for_vulnerabilities, dos.name||' - '|| version os_version
from fact_asset_vulnerability_finding favf
JOIN dim_vulnerability_category dvc using (vulnerability_id)
JOIN dim_asset da USING (asset_id)
JOIN dim_asset_operating_system daos using (asset_Id)
JOIN dim_operating_system dos on dos.operating_system_Id=daos.operating_system_id
where dvc.category_name='Obsolete OS'
order by ip_address
