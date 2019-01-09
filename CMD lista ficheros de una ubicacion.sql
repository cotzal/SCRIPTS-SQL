    -- Lista todos los archivos en un directorio - T-SQL 
    -- Microsoft SQL Server comando shell  - xp_cmdshell

    DECLARE  @PathName  VARCHAR(256) ,
             @CMD       VARCHAR(512)

    DECLARE @CommandShell TABLE (Line VARCHAR(512))

    SET @PathName = 'C:\LocalData\OldSite\wwwroot\EDI\exp_files\'
  
    -- /B es para solo obtener los nombres de los archivos
    SET @CMD = 'DIR ' + @PathName + ' /B'

    PRINT @CMD -- test & debug

    -- MSSQL inser exec - Insertamos los valores obtenidos de la ejecución en
    -- una tabla

    INSERT INTO @CommandShell
    EXEC MASTER..xp_cmdshell   @CMD 

    SELECT *  
    FROM @CommandShell 
