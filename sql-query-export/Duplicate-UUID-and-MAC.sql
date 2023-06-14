-- Duplicate Asset with UUID and MAC
-- Copy the SQL query below
with duplicate_uids as (
    select
        unique_Id,
        count(*)
    from
        dim_asset_unique_Id
    group by
        unique_Id
    having
        count(*) > 1
),
duplicate_uids_with_asset_Id as (
    select
        distinct asset_id,
        max(unique_id) as unique_id
    from
        dim_asset_unique_id
    where
        unique_Id in (
            select
                distinct unique_id
            from
                duplicate_uids
        )
    group by
        asset_Id
),
duplicate_mac_and_uuid as (
    select
        distinct mac_address,
        unique_id,
        count(*)
    from
        dim_asset
        join duplicate_uids_with_asset_Id using (asset_id)
    group by
        mac_address,
        unique_Id
    having
        count(*) > 1
)
select
    distinct dmau.unique_id,
    da.*
from
    dim_asset da
    join duplicate_mac_and_uuid dmau using (mac_address)
order by
    unique_Id,
    asset_id,
    mac_address,
    host_name,
    ip_address