WITH a AS (
SELECT 
asset_id,
CONCAT(split_part(ip_address,'.',1),'.',split_part(ip_address,'.',2),'.',split_part(ip_address,'.',3),'.0/24') AS Network
FROM dim_asset
)

SELECT DISTINCT Network, count(asset_id)
FROM a
GROUP BY Network
ORDER BY Network ASC