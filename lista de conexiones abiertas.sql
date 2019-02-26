SELECT *
FROM sys.dm_os_performance_counters
WHERE counter_name = 'User Connections';


SELECT *
FROM sys.dm_exec_connections
