SELECT *
FROM sys.dm_os_performance_counters
WHERE counter_name = 'User Connections';

SELECT *
FROM sys.dm_exec_connections where client_net_address not in('172.25.43.12','<local machine>','172.25.43.11')

select a.session_id, a.login_time, a.host_name, a.login_name, a.login_time,a.session_id,b.connection_id from sys.dm_exec_sessions a , sys.dm_exec_connections b where a.session_id=b.session_id

