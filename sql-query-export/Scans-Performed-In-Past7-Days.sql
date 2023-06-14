-- Scans performed in past X Days
-- (in this example scans in past 7 days will be reported)
-- Copy the SQL query below
select
    scan.scan_id AS "Scan ID",
    scan.scan_name AS "Scan Name",
    scan.started AS "Time Scan Started",
    scan.finished AS "Time Scan Finished",
    status.description AS "Scan Completion Status",
    type.description AS "Scan Description"
from
    dim_scan scan
    join dim_scan_status status on status.status_id = scan.status_Id
    join dim_scan_type type on type.type_id = scan.type_id
where
    started > current_date -7