-- Top 25 Remediation SQL Query. Can always change the 25 in the query to any number.
-- Copy the SQL query below

SELECT ds.summary AS "Solution Summary", 
               proofAsText(ds.fix) AS "Solution Steps", 
               array_to_string(array_agg(da.ip_address), ', ') AS "IP Addresses", 
               array_to_string(array_agg(da.host_name),', ') AS "Host Names"
  FROM fact_remediation(25, 'riskscore DESC') AS fr
  JOIN dim_solution AS ds ON fr.solution_id = ds.solution_id
  JOIN dim_asset_vulnerability_solution davs ON fr.solution_id = davs.solution_id
  JOIN dim_asset AS da ON davs.asset_id = da.asset_id
  GROUP BY ds.summary, ds.fix
