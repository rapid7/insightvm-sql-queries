-- Count of Assets in each Location based Tag
-- Copy the SQL query below

SELECT COUNT(DISTINCT da.asset_id) AS Count,
dt.tag_name AS Tag
FROM dim_tag as dt
JOIN dim_tag_asset as dta on dta.tag_id = dt.tag_id
JOIN dim_asset as da on da.asset_id = dta.asset_id
WHERE dt.tag_type = 'LOCATION'
Group by dt.tag_name
Order by Count desc
