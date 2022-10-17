-- list assets with fingerprint source and fingerprint certainity
-- Copy the SQL query below

SELECT dfsource.fps as fingerprint_source, fprint.certainty as fingerprint_certainty, dos.description as operating_system, da.ip_address, da.host_name, da.asset_id
FROM dim_asset AS da
        JOIN (
                SELECT asset_id, operating_system_id, certainty, fingerprint_source_id as fpsid
                FROM fact_asset_scan_operating_system
                GROUP BY asset_id, operating_system_id, certainty, fpsid
         ) fprint ON da.asset_id = fprint.asset_id
         JOIN (
                SELECT operating_system_id, description
                FROM dim_operating_system
                GROUP BY operating_system_id, description
         ) dos ON dos.operating_system_id = fprint.operating_system_id
        JOIN (
                SELECT source as fps, fingerprint_source_id as fpsid
                FROM dim_fingerprint_source
                GROUP BY fps, fpsid
        ) dfsource ON dfsource.fpsid = fprint.fpsid
GROUP BY da.asset_id, fprint.certainty, dos.description, da.ip_address, da.host_name, dfsource.fps
--ORDER BY fprint.certainty -- Use this line to sort by certainty
--ORDER BY dos.description -- Use this line to sort by operating system name
ORDER BY dfsource.fps -- Use this line to sort by fingerprint source
