SELECT  *,   
	--x.event_data.value('(event/action[@name="database_name"])[1]', 'nvarchar(max)') AS database_name,
	x.event_data.value('(event/action[@name="username"])[1]', 'nvarchar(max)') AS usuario,
	x.event_data.value('(event/data[@name="object_name"])[1]', 'nvarchar(max)') AS objeto,
	DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP), x.event_data.value('(event/@timestamp)[1]', 'datetime2')) AS event_time
FROM    sys.fn_xe_file_target_read_file ('C:\FICHEROS\*.xel', null, null, null) -- 'C:\temp\XEventSessions\query_performance*.xem', null, null)
           CROSS APPLY (SELECT CAST(event_data AS XML) AS event_data) as x ;
