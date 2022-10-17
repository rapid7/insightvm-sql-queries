-- collects site, IP address, host, vulnerability title, solution
-- Copy the SQL query below

SELECT dsite.name AS "Site Name", da.ip_address AS "IP Address", da.host_name AS "Host Name", dv.title  AS "Vulnerabiltiy", ds.solution_type  AS "Solution Type", ds.summary AS "Solution"
FROM fact_asset_vulnerability_instance AS fav
JOIN fact_vulnerability AS fv ON fav.vulnerability_id = fv.vulnerability_id
JOIN dim_vulnerability AS dv ON fav.vulnerability_id = dv.vulnerability_id
JOIN dim_site_asset AS dsa ON fav.asset_id = dsa.asset_id
JOIN dim_site AS dsite ON dsa.site_id = dsite.site_id
JOIN dim_ASset AS da ON fav.asset_id = da.asset_id
JOIN dim_vulnerability_solution AS dvs ON fv.vulnerability_id = dvs.vulnerability_id
JOIN dim_solution AS ds ON dvs.solution_id = ds.solution_id
GROUP by dsite.name, da.ip_address, da.host_name,dv.title, ds.solution_type, ds.summary
ORDER by dsite.name ASC
