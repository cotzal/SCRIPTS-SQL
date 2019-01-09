
		select a.FILEID,
		[FILE_SIZE_MB] =  convert(decimal(12,2),round(a.size/128.000,2)),
		[SPACE_USED_MB] = convert(decimal(12,2),round(fileproperty(a.name,'SpaceUsed')/128.000,2)),
		[FREE_SPACE_MB] = convert(decimal(12,2),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,2)),
		NAME ,
		 FILENAME 
		from dbo.sysfiles a 
		
