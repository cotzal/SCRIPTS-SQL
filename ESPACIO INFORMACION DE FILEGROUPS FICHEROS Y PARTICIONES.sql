SELECT 
    mf.name AS FileName,
    mf.physical_name AS FilePath,
    CAST(mf.size * 8 / 1024 AS int) AS ReservedSizeMB, -- Tamaño reservado en MB
    CAST(FILEPROPERTY(mf.name, 'SpaceUsed') * 8 / 1024 AS int) AS UsedSizeMB, -- Espacio ocupado en MB
    fg.name AS FileGroupName,
	ETL.partition_funcion,
	ETL.patition_schema 
FROM 
    sys.master_files mf
JOIN 
    sys.filegroups fg ON mf.data_space_id = fg.data_space_id
JOIN
    (SELECT DISTINCT FILE_GROUP_NAME, PARTITION_FUNCION, PATITION_SCHEMA FROM ETL_PARTICIONES ) AS ETL ON ETL.file_group_name = FG.NAME 
WHERE 
    mf.database_id = DB_ID() -- Filtra para la base de datos actual
ORDER BY 
    mf.name;


