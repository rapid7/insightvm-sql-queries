-- Total solution count of vulnerabilities by asset.
-- Copy the SQL query below


WITH
total_vulns AS (
     SELECT DISTINCT
         ON (da.ip_address) da.ip_address, dahn.host_name, da.asset_id, COUNT (dv.vulnerability_id) AS vulns
     FROM
         fact_asset_vulnerability_instance AS favi
     JOIN dim_asset AS da ON favi.asset_id = da.asset_id
     JOIN dim_asset_host_name AS dahn ON favi.asset_id = dahn.asset_id AND dahn.source_type_id LIKE 'D'
     JOIN dim_vulnerability AS dv ON favi.vulnerability_id = dv.vulnerability_id 
     GROUP BY da.asset_id, da.ip_address, dahn.host_name
     ORDER BY da.ip_address ASC, da.asset_id DESC, dahn.host_name ASC ), 
total_solns AS (
     SELECT davs.asset_id,
     COUNT (ds.summary) 
     FROM dim_asset_vulnerability_solution AS davs
     LEFT OUTER JOIN dim_solution AS ds ON davs.solution_id = ds.solution_id AND ((ds.summary LIKE '%Apply%') OR (ds.summary LIKE '%Upgrade%') OR (ds.summary LIKE '%Download%'))
     GROUP BY davs.asset_id ) 
     SELECT tv.ip_address, tv.host_name, tv.vulns, ts.COUNT AS patches
     FROM total_vulns AS tv
     JOIN total_solns AS ts ON tv.asset_id = ts.asset_id 
     GROUP BY tv.ip_address, tv.host_name, tv.vulns, ts.COUNT
     ORDER BY tv.ip_address ASC, tv.host_name ASC
