	SELECT qt.text, qp.query_plan, qs.last_execution_time 
	FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	--WHERE 
	-- last_execution_time >= CONVERT (char(10), getdate(), 103) and
	--qt.text like '%comana%'
	ORDER BY  qs.last_execution_time DESC -- CPU time





