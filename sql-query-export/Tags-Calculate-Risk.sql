-- Shows all tags with the tag type and the sum of the riskscore for all of the assets that have that tag
-- Copy the SQL query below

SELECT dt.tag_name AS "Tag Name", dt.tag_type AS "Tag Type", cast(sum(fa.riskscore) AS BIGINT) AS "Risk Score"

FROM dim_tag dt

JOIN dim_tag_asset dta USING(tag_id)
JOIN fact_asset fa USING(asset_id)

GROUP BY dt.tag_name, dt.tag_type
ORDER BY "Risk Score" DESC