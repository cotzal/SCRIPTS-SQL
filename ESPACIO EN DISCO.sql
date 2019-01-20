exec  sp_spaceused

SELECT file_id, name, type_desc, physical_name, size, max_size
FROM sys.database_files ;

exec sp_spaceused 'DBO.DAT_OPERACIONES_CONTABLES_NW'

SELECT * FROM sys.database_files