
DECLARE c1 CURSOR 
     FOR SELECT name 
        FROM sys.databases 
        WHERE database_id > 4
            AND state_desc = 'ONLINE'
            -- AND is_read_only = 0
        ORDER BY name

SET NOCOUNT ON ; SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT 
     SCHEMA_NAME(o.schema_id)    AS [schema]
      ,o.name                                        AS [table]
        --,'UPDATE STATISTICS [' + SCHEMA_NAME(o.schema_id) + '].[' + o.name + '] [' + s.name + '] WITH FULLSCAN;'
        --,'DROP INDEX [' + s.name + '] ON [' + o.name + ']'
        ,colums
        --,sc.stats_column_id
        --,s.stats_id
    ,s.name                                        AS statistic
    --,s.auto_created                
    --,s.user_created                
    --,s.has_filter                
    --,s.filter_definition        
    --,s.is_temporary                
    ,sp.last_updated            
        ,DATEDIFF(DAY, sp.last_updated, CURRENT_TIMESTAMP) AS diff_dd
        ,s.auto_created
    ,sp.rows        
        ,p.total_rows
    ,sp.rows_sampled 
        ,100 * sp.rows / sp.rows_sampled AS percent_rows_sampled
        ,sp.modification_counter
    ,100 * sp.modification_counter / sp.rows                AS percent_change
        ,100 * (ABS(sp.rows - p.total_rows)) / sp.rows  AS rows_increased_percent
        ,sp.steps    
        --,sp.unfiltered_rows 
FROM sys.stats s 
INNER JOIN sys.objects o ON s.object_id = o.object_id
INNER JOIN (SELECT object_id, SUM(rows) AS total_rows FROM sys.partitions WHERE index_id IN (0,1) GROUP BY object_id) p ON p.object_id = o.object_id

--OUTER APPLY sys.dm_db_stats_properties (o.object_id, s.stats_id) sp
OUTER APPLY sys.dm_db_stats_properties_internal (o.object_id, s.stats_id) sp

OUTER APPLY (SELECT REPLACE(REPLACE((SELECT c.name AS a FROM sys.columns c INNER JOIN sys.stats_columns sc ON sc.column_id = c.column_id AND c.object_id=sc.object_id WHERE c.object_id= o.object_id AND s.stats_id = sc.stats_id FOR XML PATH('')), '<a>', ''), '</a>', ' | ')) sclm (colums)
WHERE o.type IN ( 'U', 'V' )
--AND p.total_rows > 50000
--AND cols_list LIKE '%%'
--AND (100 * sp.modification_counter / sp.rows) > 10  /* percent_change */
--AND 100 * sp.rows / sp.rows_sampled <> 100 /* percent_rows_sampled */
--AND o.name LIKE '%%'
-- AND auto_created = 0
ORDER BY colums;



-- Para todas las bases de datos de la instancia
use tempdb

-- drop table [tempdb].[dbo].[tmp_stats]

SET NOCOUNT ON ; SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;




CREATE TABLE [tempdb].[dbo].[tmp_stats] (
	[DatabaseName] [nvarchar](128) NULL,
	[schema] [nvarchar](128) NULL,
	[table] [sysname] NOT NULL,
	[colums] [nvarchar](max) NULL,
	[statistic] [nvarchar](128) NULL,
	[last_updated] [datetime2](7) NULL,
	[diff_dd] [int] NULL,
	[auto_created] [bit] NULL,
	[rows] [bigint] NULL,
	[total_rows] [bigint] NULL,
	[rows_sampled] [bigint] NULL,
	[percent_rows_sampled] [bigint] NULL,
	[modification_counter] [bigint] NULL,
	[percent_change] [bigint] NULL,
	[rows_increased_percent] [bigint] NULL,
	[steps] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

DECLARE @query NVARCHAR(MAX)
DECLARE @database_name SYSNAME

DECLARE c1 CURSOR 
     FOR SELECT name 
        FROM sys.databases 
        WHERE database_id > 4
            AND state_desc = 'ONLINE'
            -- AND is_read_only = 0
			AND name <> 'DS42_IPS_AUDIT'
        ORDER BY name

OPEN c1 
FETCH NEXT FROM c1 INTO @database_name
-- start the loop 
WHILE (@@FETCH_STATUS = 0) 
BEGIN 
    
    SET @query = N'USE ' + QUOTENAME(@database_name) + N';
        
	INSERT INTO [tempdb].[dbo].[tmp_stats]			
	SELECT '''+ QUOTENAME(@database_name) + N''' AS [DatabaseName], SCHEMA_NAME(o.schema_id) AS [schema] ,o.name AS [table] ,colums, s.name AS statistic, sp.last_updated, DATEDIFF(DAY, sp.last_updated, CURRENT_TIMESTAMP) AS diff_dd, s.auto_created, sp.rows, p.total_rows, sp.rows_sampled, 100 * sp.rows / sp.rows_sampled AS percent_rows_sampled
    ,sp.modification_counter
    ,100 * sp.modification_counter / sp.rows                AS percent_change
    ,100 * (ABS(sp.rows - p.total_rows)) / sp.rows  AS rows_increased_percent
    ,sp.steps    
FROM ' + QUOTENAME(@database_name) + N'.sys.stats s 
INNER JOIN '+ QUOTENAME(@database_name) + N'.sys.objects o ON s.object_id = o.object_id
INNER JOIN (SELECT object_id, SUM(rows) AS total_rows FROM ' + QUOTENAME(@database_name) + N'.sys.partitions WHERE index_id IN (0,1) GROUP BY object_id) p ON p.object_id = o.object_id

--OUTER APPLY sys.dm_db_stats_properties (o.object_id, s.stats_id) sp
OUTER APPLY ' + QUOTENAME(@database_name) + N'.sys.dm_db_stats_properties_internal (o.object_id, s.stats_id) sp

OUTER APPLY (SELECT REPLACE(REPLACE((SELECT c.name AS a FROM '+ QUOTENAME(@database_name) + '.sys.columns c INNER JOIN ' + QUOTENAME(@database_name) + '.sys.stats_columns sc ON sc.column_id = c.column_id AND c.object_id=sc.object_id WHERE c.object_id= o.object_id AND s.stats_id = sc.stats_id FOR  XML PATH('''')), ''<a>'', ''''), ''</a>'', '' | '')) sclm (colums)
WHERE o.type IN ( ''U'', ''V'' )
--AND p.total_rows > 50000
--AND cols_list LIKE ''%%''
--AND (100 * sp.modification_counter / sp.rows) > 10  /* percent_change */
--AND 100 * sp.rows / sp.rows_sampled <> 100 /* percent_rows_sampled */
--AND o.name LIKE ''%%''
-- AND auto_created = 0

'
	-- print @query

	EXEC (@query)

    FETCH NEXT FROM c1 INTO @database_name
END 
CLOSE c1 
DEALLOCATE c1

select * from tmp_stats
--

select databasename, statistic, diff_dd, rows, total_rows, rows-total_rows, percent_change, rows_increased_percent, * 
from tmp_stats
where databasename = '[scoop]'
order by 5 desc
--
