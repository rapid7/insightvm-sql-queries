-- Basic Query for Assets with more than one site lists Ip address and sites
-- Copy the SQL query below

SELECT ip_address AS "IP Address", 
    sites AS "Sites IP Address Appears"
FROM dim_asset 
   where sites like '%,%';
