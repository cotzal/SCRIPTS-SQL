SELECT spid 
FROM fn_dblog(null,null)
where spid is not null
