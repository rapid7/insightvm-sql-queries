-- Count of assets found per /24 subnet
-- Copy the SQL query below
-- This is part 1 of 2 SQL query please see https://www.rapid7.com/blog/post/2022/09/06/5-steps-for-dealing-with-unknown-environments-in-insightvm/ for more info
WITH a AS (
    SELECT
        asset_id,
        CONCAT(
            split_part(ip_address, '.', 1),
            '.',
            split_part(ip_address, '.', 2),
            '.',
            split_part(ip_address, '.', 3),
            '.0/24'
        ) AS Network
    FROM
        dim_asset
)
SELECT
    DISTINCT Network,
    count(asset_id)
FROM
    a
GROUP BY
    Network
ORDER BY
    Network ASC -- This is part 2 of 2 of the SQL query 
    -- Count of assets per /24 subnet that have not been defined within a site based off of tag
    -- Copy the SQL query below
    WITH a AS (
        SELECT
            asset_id CONCAT(
                split_part(ip_address, '.', 1),
                '.',
                split_part(ip_address, '.', 2),
                '.',
                split_part(ip_address, '.', 3),
                '.0/24'
            ) AS Network
        FROM
            dim_asset
    )
SELECT
    DISTINCT Network,
    count(asset_id)
FROM
    a
WHERE
    a.asset_id NOT IN (
        SELECT
            DISTINCT asset_id
        FROM
            dim_asset
            LEFT JOIN dim_tag_asset USING (asset_id)
            LEFT JOIN dim_tag USING (tag_id)
        WHERE
            tag_name = 'Defined Network'
    )
GROUP BY
    Network
ORDER BY
    Network ASC