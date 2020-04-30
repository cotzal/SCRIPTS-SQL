EXEC sp_clean_db_free_space   
@dbname = N'COMERCIA_TMP' ;  


USE master;  
GO  
EXEC sp_clean_db_file_free_space   
@dbname = N'AdventureWorks2012', @fileid = 1 ;  