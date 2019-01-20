	SELECT mg.session_id, mg.requested_memory_kb, mg.granted_memory_kb, mg.used_memory_kb, t.text, qp.query_plan
	FROM sys.dm_exec_query_memory_grants AS mg
	CROSS APPLY sys.dm_exec_sql_text(mg.sql_handle) AS t
	CROSS APPLY sys.dm_exec_query_plan(mg.plan_handle) AS qp
	ORDER BY 1 DESC OPTION (MAXDOP 1)
