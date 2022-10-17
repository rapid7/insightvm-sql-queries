-- List of all unused Tags
-- Copy the SQL query below

select tag_id, tag_name
from (select dt.tag_id, dt.tag_name, count(dta.asset_id) c
from dim_tag dt
left join dim_tag_asset dta using (tag_id)
group by dt.tag_id, dt.tag_name) as t
where c = 0
