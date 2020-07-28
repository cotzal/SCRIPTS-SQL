		select b.GroupName,
		[FILE_SIZE_MB] =  sum(convert(decimal(12,2),round(a.size/128.000,2))),
		[SPACE_USED_MB] = sum(convert(decimal(12,2),round(fileproperty(a.name,'SpaceUsed')/128.000,2)))
		from dbo.sysfiles as a inner join sys.sysfilegroups as b on a.groupid = b.groupid 
		group by b.groupname 