select distinct(object_name(id)) from sysindexes
where groupid=filegroup_id('primary')