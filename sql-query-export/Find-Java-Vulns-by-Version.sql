-- List Java vulnerabilities by version
-- Copy the SQL query below

SELECT dv.vulnerability_id, dv.title, SUBSTRING(ds.applies_to, 14, 8) AS ver_min, SUBSTRING(ds.applies_to, 29) AS ver_max, applies_to
FROM dim_solution AS ds
JOIN dim_vulnerability_solution AS dvs USING (solution_id)
JOIN dim_vulnerability AS dv USING (vulnerability_id)
WHERE (applies_to LIKE '%Oracle JRE%') AND (string_to_array('1.6.0.67', '.')::int[] >= string_to_array(SUBSTRING(ds.applies_to, 14, 8), '.')::int[] AND string_to_array('1.6.0.67', '.')::int[] < string_to_array(SUBSTRING(ds.applies_to, 29), '.')::int[])
ORDER BY ds.applies_to

