-- Sample showing:
-- case statement
-- several counts
-- truncate date to day
-- Copy the SQL query below
SELECT
    dos.description AS "OS",
    COUNT(
        CASE
            when upper(dvc.category_name) like '%ADOBE%' then 1
            else null
        end
    ) as "Adobe",
    COUNT(
        CASE
            when upper(dvc.category_name) like '%JAVA%' then 1
            else null
        end
    ) as "Java",
    COUNT(
        CASE
            when upper(dvc.category_name) NOT like '%ADOBE%'
            OR upper(dvc.category_name) NOT like '%JAVA%' then 1
            else null
        end
    ) as "Other",
    to_char(
        da.last_assessed_for_vulnerabilities,
        'yyyy-mm-dd'
    ) AS "Last_scanned",
    COUNT(DISTINCT da.asset_id) as "Asset_count"
FROM
    dim_asset da
    JOIN dim_asset_vulnerability_solution davs ON davs.asset_id = da.asset_id
    JOIN dim_vulnerability_category dvc ON dvc.vulnerability_id = davs.vulnerability_id
    JOIN dim_operating_system dos ON dos.operating_system_id = da.operating_system_id
Where
    da.sites like '%someIPs%'
GROUP by
    dos.description,
    CASE
        when upper(dvc.category_name) like '%ADOBE%' then 1
        else null
    end,
    CASE
        when upper(dvc.category_name) like '%JAVA%' then 1
        else null
    end,
    CASE
        when upper(dvc.category_name) NOT like '%ADOBE%'
        OR upper(dvc.category_name) NOT like '%ORACLE%' then 1
        else null
    end,
    to_char(
        da.last_assessed_for_vulnerabilities,
        'yyyy-mm-dd'
    )