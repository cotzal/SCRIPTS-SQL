SELECT tab.name AS Tablename,
       user_seeks, user_scans, user_lookups, user_updates,
       last_user_seek, last_user_scan, last_user_lookup, last_user_update,*
FROM sys.dm_db_index_usage_stats ius 
INNER JOIN sys.tables tab ON (tab.object_id = ius.object_id)
WHERE database_id = DB_ID(N'COMERCIA_USR')
  AND tab.name = 'TABLE_2'


