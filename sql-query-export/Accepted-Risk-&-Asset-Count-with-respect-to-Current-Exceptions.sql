-- Determines total risk and a count of instances impacted by current exceptions
-- Copy the SQL query below

WITH exceptions_list AS (
    SELECT
   CASE
      WHEN dve.scope_id = 'G' THEN 'All instances across all assets'
      WHEN dve.scope_id = 'D' THEN 'All instances on asset on asset "' || COALESCE(da.host_name, da.ip_address) ||  ' "'
      WHEN dve.scope_id = 'I' THEN 'Specific instance on asset "' || da.host_name || 'or' || da.ip_address || ' "'
      WHEN dve.scope_id = 'S' THEN 'All instances on this site "' || ds.name ||  ' "'
   END AS exceptionscope, COALESCE(dve.additional_comments,'') as additional_comments, dve.submitted_date, dve.submitted_by,
   dve.review_date, dve.reviewed_by, dve.review_comment, dve.expiration_date, des.description as status, der.description as reason,
   dv.title, (dv.riskscore::Integer), (dv.cvss_v2_score::Integer), dve.vulnerability_exception_id, dve.reason_id, des.status_id
FROM dim_vulnerability_exception dve
   LEFT OUTER JOIN dim_asset da USING (asset_id)
   LEFT OUTER JOIN dim_site ds USING (site_id)
   JOIN dim_exception_status des on des.status_id = dve.status_id
   JOIN dim_exception_reason der on der.reason_id = dve.reason_id
   JOIN dim_exception_scope descope on descope.scope_id = dve.scope_id
   JOIN dim_vulnerability dv on dv.vulnerability_id = dve.vulnerability_id
),
 total_accepted_risk AS (
SELECT SUM(dv.riskscore::INTEGER) AS total_accepted_risk, favie.vulnerability_exception_id, COUNT(DISTINCT favie.asset_id) AS asset_count
FROM fact_asset_vulnerability_instance_excluded favie
JOIN dim_vulnerability dv ON (dv.vulnerability_id = favie.vulnerability_id)
GROUP BY favie.vulnerability_exception_id
)


SELECT DISTINCT exceptionscope, COALESCE(el.additional_comments,'') as additional_comments, el.submitted_date, el.submitted_by,
   el.review_date, el.reviewed_by, el.review_comment, el.expiration_date, el.status, el.reason,
   el.title, (el.riskscore::Integer), (el.cvss_v2_score::Integer), COALESCE(total_accepted_risk, 0) AS "Total Accepted Risk", tar.asset_count AS "Asset Count"
FROM exceptions_list el
LEFT OUTER JOIN total_accepted_risk tar on tar.vulnerability_exception_id = el.vulnerability_exception_id

WHERE el.expiration_date >= current_date or el.expiration_date is null

ORDER BY "Total Accepted Risk" DESC 
