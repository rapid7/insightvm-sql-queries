-- Columns: Vulnerability Title, CVE ID, Number of Affected Assets, IPs Affected, Hosts Affected, Solution, Discovery Date, Publish Date, Age in Days
-- Copy the SQL query below
WITH no_solutions AS (
    SELECT
        dv.title,
        dv.nexpose_id,
        dv.date_published,
        dv.vulnerability_id,
        min(fasvi.date) :: date min_date,
        NOW() :: date present
    FROM
        dim_vulnerability dv
        LEFT JOIN dim_vulnerability_solution dvs ON dv.vulnerability_id = dvs.vulnerability_id
        JOIN fact_asset_scan_vulnerability_instance fasvi ON dv.vulnerability_id = fasvi.vulnerability_id
    WHERE
        dvs.vulnerability_id is NULL
    GROUP BY
        dv.title,
        dv.nexpose_id,
        dv.date_published,
        dv.vulnerability_id
)
SELECT
    ns.title AS "Vulnerability Title",
    ns.nexpose_id AS "CVE ID",
    count(da.asset_id) AS "Number of Affected Assets",
    STRING_AGG(da.ip_address, ', ') AS "IPs Affected",
    STRING_AGG(da.host_name, ', ') AS "Hosts Affected",
    COALESCE(
        ds.fix,
        'There is no solution for ' || ns.nexpose_id
    ) AS "Solution",
    ns.min_date AS "Discovery Date",
    ns.date_published AS "Publish Date",
    ns.present - ns.min_date AS "Age in Days"
FROM
    no_solutions ns
    JOIN fact_asset_vulnerability_instance favi ON ns.vulnerability_id = favi.vulnerability_id
    JOIN dim_asset da ON favi.asset_id = da.asset_id
    LEFT JOIN dim_solution ds ON ns.nexpose_id = ds.nexpose_id
GROUP BY
    ns.title,
    ns.nexpose_id,
    ds.fix,
    ns.min_date,
    ns.date_published,
    ns.present