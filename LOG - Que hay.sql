Select [Transaction ID], operation, COUNT(*) FROM sys.fn_dblog(NULL,NULL) group by [Transaction ID], Operation 
