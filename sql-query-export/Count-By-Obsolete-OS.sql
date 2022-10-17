-- Count of assets by Obsolete OS
-- Copy the SQL query below


SELECT dos.name||' - '|| version os_version, COUNT(DISTINCT favf.asset_id)
FROM fact_asset_vulnerability_finding favf
JOIN dim_vulnerability_category dvc USING (vulnerability_id)
JOIN dim_asset da USING (asset_id)
JOIN dim_asset_operating_system daos USING (asset_Id)
JOIN dim_operating_system dos ON (dos.operating_system_id = daos.operating_system_id)
WHERE dvc.category_name='Obsolete OS'
GROUP BY dos.name||' - '|| version
ORDER BY count(distinct favf.asset_id) DESC
