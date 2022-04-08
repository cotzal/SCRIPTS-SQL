
		select a.FILEID,
		[FILE_SIZE_MB] =  convert(decimal(12,2),round(a.size/128.000,2)),
		[SPACE_USED_MB] = convert(decimal(12,2),round(fileproperty(a.name,'SpaceUsed')/128.000,2)),
		[FREE_SPACE_MB] = convert(decimal(12,2),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,2)),
		 FILENAME ,
		 filegroup_name(groupid ) AS FILEGROUP, b.name AS TABLA
		from dbo.sysfiles a inner join etl_particiones as b
		on filegroup_name(groupid ) = b.file_group_name 
		