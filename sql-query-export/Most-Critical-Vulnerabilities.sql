-- List of most critical vulnerabilities, in descending order by CVSS and Age
-- Copy the SQL query below
SELECT
        da.asset_id,
        lastScan(da.asset_id) AS last_scan,
        scan_id,
        da.ip_address,
        da.host_name,
        dv.nexpose_id,
        dv.title,
        dv.severity,
        dv.cvss_score,
        dv.exploits,
        dv.malware_kits,
        TO_CHAR(fava.first_discovered, 'MM-DD-YYYY') AS first_discovered_date,
        TO_CHAR(max_date, 'MM-DD-YYYY') AS last_discovered_date,
        fava.age_in_days
FROM
        dim_asset AS da
        JOIN dim_asset_vulnerability_solution AS davs USING (asset_id)
        JOIN (
                SELECT
                        vulnerability_id,
                        nexpose_id,
                        title,
                        severity,
                        cvss_score,
                        exploits,
                        malware_kits
                FROM
                        dim_vulnerability
                WHERE
                        (severity = 'Critical')
                        AND (
                                exploits >= 1
                                OR malware_kits >= 1
                        )
        ) AS dv ON dv.vulnerability_id = davs.vulnerability_id
        JOIN fact_asset_vulnerability_instance AS favi USING (asset_id)
        INNER JOIN (
                SELECT
                        asset_id,
                        vulnerability_id,
                        first_discovered,
                        MAX(most_recently_discovered) AS max_date,
                        age_in_days
                FROM
                        fact_asset_vulnerability_age AS fava
                GROUP BY
                        asset_id,
                        first_discovered,
                        vulnerability_id,
                        age_in_days
        ) AS fava ON fava.asset_id = da.asset_id
WHERE
        lastScan(da.asset_id) = favi.scan_id
GROUP BY
        da.asset_id,
        favi.scan_id,
        da.ip_address,
        da.host_name,
        dv.nexpose_id,
        dv.title,
        dv.severity,
        dv.cvss_score,
        dv.exploits,
        dv.malware_kits,
        fava.first_discovered,
        fava.max_date,
        fava.age_in_days
ORDER BY
        da.asset_id,
        dv.cvss_score DESC,
        fava.age_in_days DESC