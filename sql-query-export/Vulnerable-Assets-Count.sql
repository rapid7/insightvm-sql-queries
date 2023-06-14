-- Retrieve the total count of vulnerable assets
-- Copy the SQL query below
SELECT
    COUNT(*)
FROM
    fact_asset
WHERE
    vulnerabilities > 0;