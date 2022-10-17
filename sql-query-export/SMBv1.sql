-- Looks for SMBv1
-- copy query below

SELECT ds.name AS site_name, da.ip_address, da.host_name, dos.asset_type, dasc.port,
split_part(dasc.name, '.', 1) protocol_version,
unnest(string_to_array(dasc.value, ',')) cipher_suite
FROM dim_asset da
JOIN dim_operating_system dos USING (operating_system_id)
JOIN dim_host_type dht USING (host_type_id)
JOIN dim_asset_service_configuration dasc USING (asset_id)
JOIN dim_site_asset dsa USING (asset_id)
JOIN dim_site ds USING (site_id)
WHERE dasc.name ILIKE 'smb1-enabled'
