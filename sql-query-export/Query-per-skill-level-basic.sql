-- All assets that are exploitable at a Noivce level
-- Copy the SQL query below

SELECT *
FROM dim_asset JOIN fact_asset_scan_vulnerability_finding ON fact_asset_scan_vulnerability_finding.asset_id = dim_asset.asset_id
WHERE fact_asset_scan_vulnerability_finding.vulnerability_id IN
(SELECT dim_vulnerability_exploit.vulnerability_id
 FROM dim_vulnerability_exploit JOIN fact_asset_scan_vulnerability_finding ON dim_vulnerability_exploit.vulnerability_id = fact_asset_scan_vulnerability_finding.vulnerability_id
 WHERE dim_vulnerability_exploit.skill_level like 'Novice')
