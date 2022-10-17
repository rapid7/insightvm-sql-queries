-- List of assets that have not been scanned in last 30 days
-- Copy the SQL query below


select fact_asset.scan_finished,
   dim_asset_host_name.host_name,
   dim_asset_ip_address.ip_address
from fact_asset 
INNER JOIN dim_asset_host_name ON dim_asset_host_name.asset_id =
fact_asset.asset_id
INNER JOIN dim_asset_ip_address ON dim_asset_ip_address.asset_id =
dim_asset_host_name.asset_id
where scan_finished NOT BETWEEN now()::timestamp - interval '30d' AND
now()::timestamp;
