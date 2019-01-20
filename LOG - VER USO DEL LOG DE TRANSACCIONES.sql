SELECT count(*)
FROM fn_dblog(null,null)

DBCC SQLPERF(LOGSPACE);

kill 83 with STATUSONLY