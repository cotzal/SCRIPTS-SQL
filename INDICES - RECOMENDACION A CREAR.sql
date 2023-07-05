
 -- INDICES RECOMENDADOS
 ;WITH XMLNAMESPACES
 (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
 SELECT top 100
 missingindex.value('(.//MissingIndexGroup/@Impact)[1]', 'varchar(128)') AS Impact,
 DB_NAME(dbid) as DatabaseName,
 missingindex.value('(.//MissingIndexGroup/MissingIndex/@Table)[1]', 'varchar(128)') AS TableName,
 usecounts as PlanUses,
 cacheobjtype,
 objtype,
 query_plan, 
 missingindex.value('(../../@StatementText)[1]', 'varchar(128)') AS SQL_Text
 FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
 CROSS APPLY query_plan.nodes('//BatchSequence/Batch/Statements') AS batch(stmts)
 cross apply stmts.nodes('.//StmtSimple/QueryPlan/MissingIndexes') as batch2(missingindex)
 cross apply stmts.nodes('.//MissingIndex') as batch3(MissingindexInfo)
 where  DB_NAME(dbid) = 'COMERCIA_DWH'
 OPTION(MAXDOP 1, RECOMPILE);