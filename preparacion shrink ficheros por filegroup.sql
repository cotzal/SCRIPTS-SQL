		select b.GroupName, a.name,
		[FILE_SIZE_MB] =  convert(decimal(12,2),round(a.size/128.000,2)),
		[SPACE_USED_MB] = convert(decimal(12,2),round(fileproperty(a.name,'SpaceUsed')/128.000,2)),
		'DBCC SHRINKFILE (N''' + A.NAME + ''' , 0, TRUNCATEONLY)'
		from dbo.sysfiles as a inner join sys.sysfilegroups as b on a.groupid = b.groupid 
		where groupname like '%SCV%'
		AND convert(decimal(12,2),round(a.size/128.000,2)) > 200

