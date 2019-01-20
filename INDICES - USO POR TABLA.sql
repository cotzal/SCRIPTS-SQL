SELECT o.name Object_Name,
       i.name Index_name,
       i.Type_Desc,
	   s.user_seeks,
	   s.user_scans,
	   s.user_lookups
 FROM sys.objects AS o
     JOIN sys.indexes AS i
 ON o.object_id = i.object_id
  LEFT OUTER JOIN
  sys.dm_db_index_usage_stats AS s  
 ON i.object_id = s.object_id 
  AND i.index_id = s.index_id
 WHERE  o.type = 'u'
    AND i.type IN (1, 2) 
  --AND (s.index_id IS NULL) OR
 --     (s.user_seeks = 0 AND s.user_scans = 0 AND s.user_lookups = 0 )
 and o.name = 'DAT_OPERACIONES_CONTABLES'