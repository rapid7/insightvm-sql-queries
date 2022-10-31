-- Expiring Vulnerabilities
-- Copy the SQL query below

SELECT dv.title AS vuln_title, 
       dve.expiration_date, 
       des.description AS scope, 
       der.description AS reason, 
       dest.description as status
FROM dim_vulnerability_exception dve
JOIN dim_vulnerability dv ON (dve.vulnerability_id = dv.vulnerability_id)
JOIN dim_exception_scope des ON (des.scope_id = dve.scope_id)
JOIN dim_exception_reason der ON (der.reason_id = dve.reason_id)
JOIN dim_exception_status dest ON (dest.status_id = dve.status_id)
WHERE dve.expiration_date > (current_date - interval '30 day')
  AND dve.status_id = 'A'
