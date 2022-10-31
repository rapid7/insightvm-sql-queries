-- Console query to find assets that may be vulnerable to Poodle/ have SSLv3 supported
-- Copy the SQL query below

WITH
 vulnerability_id AS(
   SELECT vulnerability_id
   FROM dim_vulnerability
   WHERE nexpose_id IN ('sslv3-supported')
   )
 SELECT DISTINCT ON 
 (asset_id, da.ip_address, da.host_name, CVE) asset_id, da.ip_address, da.host_name, dv.title, dos.description AS operating_system, dos.version, dvr.reference
 AS CVE, das.scan_finished as last_scan,dv.riskscore
 FROM fact_asset_vulnerability_instance favi
 JOIN vulnerability_id USING (vulnerability_id)
 JOIN dim_vulnerability dv USING (vulnerability_id)
 JOIN dim_vulnerability_reference dvr USING (vulnerability_id)
 JOIN dim_asset da USING (asset_id)
 JOIN dim_operating_system dos USING (operating_system_id)
 JOIN dim_asset_scan das USING (asset_id)
 WHERE dvr.source = 'CVE'
 ORDER BY asset_id, da.ip_address, da.host_name, CVE 
