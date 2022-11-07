--Data Warehouse
--Useful if you setup something like an out of band patch for critical or obsolete vulnerabilities
--IMPORTANT, this list is not all inclusive, you will need to add and/or remove vulnerabilities that meet your org's needs
--Copy the query below and modify it to fit

WITH cveob AS
  (SELECT dv_1.vulnerability_id
   FROM dim_vulnerability dv_1
   WHERE dv_1.nexpose_id ~~ '%cve-2017-9805%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-5638%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-8759%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-7494%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-11771%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-11772%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-0143%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-0144%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-0145%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-0146%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-0147%'::text
     OR dv_1.nexpose_id ~~ '%cve-2017-0148%'::text
   UNION SELECT dvc.vulnerability_id
   FROM dim_vulnerability_category dvc
   WHERE dvc.category_name = 'Obsolete OS'::text ),
     cert AS
  (SELECT daos.asset_id,
          max(daos.certainty) AS certainty
   FROM dim_asset_operating_system daos
   WHERE (EXISTS
            (SELECT 1
             FROM dim_asset da_1
             WHERE daos.asset_id = da_1.asset_id))
   GROUP BY daos.asset_id),
     solution AS
  (SELECT davfs.asset_id,
          davfs.vulnerability_id,
          string_agg(ds.summary, ' | '::text
                     ORDER BY ds.solution_id) AS "Solution Summary",
          string_agg(htmltotext(ds.fix), ' | '::text
                     ORDER BY ds.solution_id) AS "Solution"
   FROM dim_asset_vulnerability_finding_solution davfs
   JOIN dim_solution ds ON davfs.solution_id = ds.solution_id
   JOIN fact_asset_vulnerability_finding f_1 ON f_1.asset_id = davfs.asset_id
   AND f_1.vulnerability_id = davfs.vulnerability_id
   JOIN cveob cveob_1 ON davfs.vulnerability_id = cveob_1.vulnerability_id
   GROUP BY davfs.asset_id,
            davfs.vulnerability_id)
SELECT da.ip_address AS "IP Address",
       da.host_name AS "Host Name",
       dv.vulnerability_id,
       dv.nexpose_id AS "Nexpose ID",
       da.os_description AS "OS Name",
       cert.certainty AS "Os Certainty",
       da.sites AS "Site",
       CASE
           WHEN lower(dv.nexpose_id) ~~ '%obsolete%'::text THEN 'Obsolete OS'::text
           WHEN lower(dv.nexpose_id) ~~ '%cve-2017-5638%'::text THEN 'Struts (5638)'::text
           WHEN lower(dv.nexpose_id) ~~ '%cve-2017-9805%'::text THEN 'Struts (9805)'::text
           WHEN lower(dv.nexpose_id) ~~ '%cve-2017-7494%'::text THEN 'SambaCry'::text
           WHEN lower(dv.nexpose_id) ~~ '%cve-2017-0143%'::text
                OR lower(dv.nexpose_id) ~~ '%cve-2017-0144%'::text
                OR lower(dv.nexpose_id) ~~ '%cve-2017-0145%'::text
                OR lower(dv.nexpose_id) ~~ '%cve-2017-0146%'::text
                OR lower(dv.nexpose_id) ~~ '%cve-2017-0147%'::text
                OR lower(dv.nexpose_id) ~~ '%cve-2017-0148%'::text THEN 'WannaCry'::text
           WHEN lower(dv.nexpose_id) ~~ '%cve-2017-11771%'::text
                OR lower(dv.nexpose_id) ~~ '%cve-2017-11772%'::text THEN 'Windows RCE'::text
           WHEN lower(dv.nexpose_id) ~~ '%cve-2017-8759%'::text THEN '.Net Framework'::text
           ELSE NULL::text
       END AS "Out Of Band Critical Patches",
       da.last_assessed_for_vulnerabilities AS "Last Date Found",
       date_part('day'::text, 'now'::text::date::timestamp without time zone - f.date) AS "Vulnerability Age",
       solution."Solution"
FROM fact_asset_vulnerability_finding f
JOIN cveob ON f.vulnerability_id = cveob.vulnerability_id
JOIN dim_asset da ON f.asset_id = da.asset_id
JOIN dim_vulnerability dv ON f.vulnerability_id = dv.vulnerability_id
LEFT JOIN solution ON f.asset_id = solution.asset_id
AND f.vulnerability_id = solution.vulnerability_id
LEFT JOIN cert ON f.asset_id = cert.asset_id;
