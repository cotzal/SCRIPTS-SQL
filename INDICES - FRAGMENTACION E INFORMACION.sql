DECLARE @db_id SMALLINT;  
DECLARE @object_id INT;  
SET @db_id = DB_ID(N'COMERCIA_AGR');  
SET @object_id = OBJECT_ID(N'COMERCIA_AGR.dbo.OPERACIONES');  
IF @object_id IS NULL   
BEGIN;  
    PRINT N'Invalid object';  
END;  
ELSE  
BEGIN;  
    SELECT * FROM sys.dm_db_index_physical_stats(@db_id, @object_id, NULL, NULL , 'DETAILED');  
END;  
GO  
