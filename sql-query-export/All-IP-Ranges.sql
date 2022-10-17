--Select All included IP ranges entered into Nexpose
-- Copy the SQL query below


SELECT name AS site_Name, s.site_Id AS site_id, target AS IP_or_range
FROM dim_site s, dim_site_target t
where s.site_Id=t.site_id
and included='true' order by s.site_id, target
