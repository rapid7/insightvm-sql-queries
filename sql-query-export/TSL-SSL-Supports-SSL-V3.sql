Gives you the following: IP | HOSTNAME | OS | TAG NAME | VULN | PROOF | SUMMARY

SELECT da.ip_address, da.host_name, dos.description, dt.tag_name, dv.title, favf.proof, ds.summary 

FROM fact_asset_vulnerability_instance favf 
JOIN dim_vulnerability dv ON dv.vulnerability_id = favf.vulnerability_id 
JOIN dim_asset da ON da.asset_id = favf.asset_id 
JOIN dim_operating_system dos ON dos.operating_system_id = da.operating_system_id 
LEFT OUTER JOIN dim_tag_asset dta ON dta.asset_id = favf.asset_id 
LEFT OUTER JOIN dim_tag dt ON dt.tag_id = dta.tag_id 
JOIN dim_vulnerability_solution vs ON vs.vulnerability_id = favf.vulnerability_id 
JOIN dim_solution ds ON ds.solution_id = vs.solution_id 

WHERE dv.title like '%TLS/SSL Server Supports SSL version 3%' 
ORDER BY dv.title ASC 
