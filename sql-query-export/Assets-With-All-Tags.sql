-- Console query to list all assets by IP and Host Name with the corresponding tags for each tag category
-- Copy the SQL query below

WITH 
custom_tags AS (
SELECT dta.asset_id, string_agg(dt.tag_name, ', ') as custom_tags
FROM dim_tag dt
JOIN dim_tag_asset dta ON dt.tag_id=dta.tag_id
WHERE dt.tag_type = 'CUSTOM'
GROUP BY dta.asset_id
),
location_tags AS (
SELECT dta.asset_id, string_agg(dt.tag_name, ', ') as location_tags
FROM dim_tag dt
JOIN dim_tag_asset dta ON dt.tag_id=dta.tag_id
WHERE dt.tag_type = 'LOCATION'
GROUP BY dta.asset_id
),
owner_tags AS (
SELECT dta.asset_id, string_agg(dt.tag_name, ', ') as owner_tags
FROM dim_tag dt
JOIN dim_tag_asset dta ON dt.tag_id=dta.tag_id
WHERE dt.tag_type = 'OWNER'
GROUP BY dta.asset_id
),
criticality_tags AS (
SELECT dta.asset_id, string_agg(dt.tag_name, ', ') as criticality_tags
FROM dim_tag dt
JOIN dim_tag_asset dta ON dt.tag_id=dta.tag_id
WHERE dt.tag_type = 'CRITICALITY'
GROUP BY dta.asset_id
)



SELECT da.ip_address, da.host_name, ct.custom_tags, lt.location_tags, ot.owner_tags, crit.criticality_tags

FROM dim_asset da

LEFT JOIN custom_tags ct USING (asset_id)
LEFT JOIN location_tags lt USING (asset_id)
LEFT JOIN owner_tags ot USING (asset_id)
LEFT JOIN criticality_tags crit USING (asset_id)