-- Vulnerability Checks by Category
-- Copy the SQL query below

SELECT  dvc.category_id, dvc.category_name, title, htmlToText(description), severity, cvss_score
FROM dim_vulnerability dv
JOIN dim_vulnerability_category dvc ON dvc.vulnerability_id = dv.vulnerability_id
--If looking to produce a list of a specific category uncomment below...
WHERE dvc.category_id = '54'
--WHERE dvc.category_name = 'Default Account'
ORDER BY dvc.category_id, title
