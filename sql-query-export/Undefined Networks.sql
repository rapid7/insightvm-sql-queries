WITH a AS (
SELECT 
asset_id
CONCAT(split_part(ip_address,'.',1),'.',split_part(ip_address,'.',2),'.',split_part(ip_address,'.',3),'.0/24') AS Network
FROM dim_asset
)

SELECT DISTINCT Network, count(asset_id)
FROM a

WHERE a.asset_id NOT IN (
SELECT DISTINCT asset_id
FROM dim_asset
LEFT JOIN dim_tag_asset USING (asset_id)
LEFT JOIN dim_tag USING (tag_id)
WHERE tag_name = 'Defined Network'
)

GROUP BY Network
ORDER BY Network ASC