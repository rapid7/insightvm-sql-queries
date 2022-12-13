-- Two column report with OS and asset count
-- Copy the SQL query below

select dos.name||' - '|| version os_version, count(distinct favf.asset_id)
from fact_asset_vulnerability_finding favf
JOIN dim_vulnerability_category dvc using (vulnerability_id)
JOIN dim_asset da USING (asset_id)
JOIN dim_asset_operating_system daos using (asset_Id)
JOIN dim_operating_system dos on dos.operating_system_Id=daos.operating_system_id
where dvc.category_name='Obsolete OS'
group by dos.name||' - '|| version
order by count(distinct favf.asset_id) desc
