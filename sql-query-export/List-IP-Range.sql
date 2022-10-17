-- List of IP Ranges
-- Copy the SQL query below

SELECT name AS "Site Name", s.site_Id AS "Site ID", target AS "IP Address or Range"
FROM dim_site s, dim_site_target t where s.site_Id=t.site_id 
ORDER by s.site_id, target
