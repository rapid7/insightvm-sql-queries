-- This query will provide you with the following:
-- IP Address
-- Host Name
-- Operating System
-- CVE
-- Copy the SQL query below
WITH vulnerability_id AS (
   SELECT
      vulnerability_id
   FROM
      dim_vulnerability
   WHERE
      nexpose_id IN (
         'gnu-bash-cve-2014-6271',
         'gnu-bash-cve-2014-7169',
         'gnu-bash-cve-2014-6278',
         'gnu-bash-cve-2014-7186',
         'gnu-bash-cve-2014-7187',
         'sunpatch-149079',
         'sunpatch-149080',
         'freebsd-vid-71ad81da-4414-11e4-a33e-3c970e169bc2',
         'suse-su-2014-1214-1',
         'suse-su-2014-1214-1',
         'amazon-linux-ami-alas-2014-418',
         'amazon-linux-ami-alas-2014-419',
         'linuxrpm-rhsa-2014-1293',
         'linuxrpm-rhsa-2014-1294',
         'linuxrpm-rhsa-2014-1306',
         'linuxrpm-elsa-2014-1293',
         'linuxrpm-elsa-2014-1294',
         'linuxrpm-elsa-2014-3075',
         'linuxrpm-elsa-2014-3076',
         'linuxrpm-elsa-2014-3077',
         'linuxrpm-elsa-2014-3078',
         'linuxrpm-cesa-2014-1293',
         'linuxrpm-cesa-2014-1294',
         'linuxrpm-cesa-2014-1306',
         'debian-dsa-3032',
         'debian-dsa-3035',
         'ubuntu-usn-2362-1',
         'ubuntu-usn-2363-1',
         'ubuntu-usn-2363-2',
         'cisco-san-os-cisco-sa-20140926-bash',
         'cisco-nx-os-cisco-sa-20140926-bash'
      )
)
SELECT
   DISTINCT ON (asset_id, da.ip_address, da.host_name, CVE) asset_id,
   da.ip_address,
   da.host_name,
   dos.description AS operating_system,
   dvr.reference AS CVE
FROM
   fact_asset_vulnerability_instance
   JOIN vulnerability_id USING (vulnerability_id)
   JOIN dim_vulnerability_reference dvr USING (vulnerability_id)
   JOIN dim_asset da USING (asset_id)
   JOIN dim_operating_system dos USING (operating_system_id)
WHERE
   dvr.source = 'CVE'
ORDER BY
   asset_id,
   da.ip_address,
   da.host_name,
   CVE