SELECT qp.query_plan, 
       CP.usecounts, 
       cp.cacheobjtype, 
       cp.size_in_bytes, 
       cp.usecounts, 
	   objtype, 
       SQLText.text
  FROM sys.dm_exec_cached_plans AS CP
  CROSS APPLY sys.dm_exec_sql_text( plan_handle)AS SQLText
  CROSS APPLY sys.dm_exec_query_plan( plan_handle)AS QP
  --WHERE objtype = 'Adhoc' and cp.cacheobjtype = 'Compiled Plan'
  order by cp.usecounts desc

