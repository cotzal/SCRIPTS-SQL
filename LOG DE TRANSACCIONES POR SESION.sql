SELECT distinct spid, count(*)
FROM fn_dblog(null,null)
group by spid
