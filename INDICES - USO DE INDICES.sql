-- Uso de índices
;WITH XMLNAMESPACES
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT top 10
StmtSimple.value('(@StatementText)[1]', 'varchar(max)') AS SQL_Text,
obj.value('(./Object/@Database)[1]', 'varchar(128)') AS DatabaseName,
obj.value('(./Object/@Schema)[1]', 'varchar(128)') AS SchemaName,
obj.value('(./Object/@Table)[1]', 'varchar(128)') AS TableName,
obj.value('(./Object/@Index)[1]', 'varchar(128)') AS IndexName,
obj.value('(./Object/@IndexKind)[1]', 'varchar(128)') AS IndexKind,
obj.value('(../@PhysicalOp)[1]', 'varchar(128)') AS [Operación Física],
obj.value('(../@LogicalOp)[1]', 'varchar(128)') AS [Operación Lógica],
query_plan
FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
CROSS APPLY query_plan.nodes('//BatchSequence/Batch/Statements') AS batch(stmts)
cross apply stmts.nodes('.//StmtSimple') as batch2(StmtSimple)
cross APPLY StmtSimple.nodes('.//IndexScan') AS idx(obj)
-- Filtramos por la base de datos que nos interesa que en nuestro caso es tpcc
where qp.dbid = db_id('PI2004')
OPTION(MAXDOP 1, RECOMPILE);
