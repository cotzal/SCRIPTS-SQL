
 -- CONVERSIONES IMPLICITAS
 ;WITH XMLNAMESPACES
 (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
 SELECT top 10
 DB_NAME(dbid) as DatabaseName,
 usecounts as PlanUses,
 cacheobjtype,
 objtype,
 obj.value('(@ConvertIssue)[1]', 'varchar(128)') AS Warning,
 obj.value('(@Expression)[1]', 'varchar(128)') AS Expression,
 obj.value('(../../../@StatementText)[1]', 'varchar(128)') AS SQL_Text,
 query_plan
 FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
 CROSS APPLY query_plan.nodes('//BatchSequence/Batch/Statements') AS batch(stmts)
 cross apply stmts.nodes('.//StmtSimple/QueryPlan') as batch2(StmtSimple)
 cross APPLY StmtSimple.nodes('.//Warnings/PlanAffectingConvert') AS idx(obj)
 where qp.dbid = db_id('COMERCIA_DWH')
 OPTION(MAXDOP 1, RECOMPILE);
