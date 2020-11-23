select distinct(object_name(id)), reserved , rows  from sysindexes
where groupid=filegroup_id('PRIMARY')

