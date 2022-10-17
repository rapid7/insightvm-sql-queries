-- Count vulnerabilities for 30, 60, and 60+ days with severity >= 5
-- Copy the SQL query below

SELECT to_char(fav.date, 'Mon-YY') AS date, COUNT(*) AS count,
	CASE
		WHEN age(dv.date_published) < '30 days' THEN '<30 days'
		WHEN age(dv.date_published) <= '60 days' THEN '30-60 days'
		ELSE '60+ days'
	END AS vuln_age
-- The fav table has the asset test date...
FROM fact_asset_vulnerability_instance AS fav
-- and the dv table has the vulnerability release date
	INNER JOIN dim_vulnerability AS dv
		ON fav.vulnerability_id = dv.vulnerability_id
-- Severity must five or more
WHERE dv.severity_score >= 5 AND
-- Only get assets tested in the last 12 months
	age(fav.date) <= '12 mons'
GROUP BY to_char(fav.date, 'Mon-YY'),
	CASE
		WHEN age(dv.date_published) < '30 days' THEN '<30 days'
		WHEN age(dv.date_published) <= '60 days' THEN '30-60 days'
		ELSE '60+ days'
	END,
	date_part('year', fav.date),
	date_part('month', fav.date)
ORDER BY date_part('year', fav.date),
	date_part('month', fav.date),
	vuln_age;
