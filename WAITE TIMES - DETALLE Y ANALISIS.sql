-- INICIALIZA CONTADORES
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);
GO

SELECT * FROM sys.dm_os_wait_stats order by max_wait_time_ms desc;

 SELECT TOP 10
 [Wait type] = wait_type,
 [Wait time (s)] = wait_time_ms / 1000,
 [% waiting] = CONVERT(DECIMAL(12,2), wait_time_ms * 100.0
               / SUM(wait_time_ms) OVER())
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE '%SLEEP%'
ORDER BY wait_time_ms DESC;

SELECT TOP 10
wait_type ,
wait_time_ms / 1000. AS wait_time_s ,
100. * wait_time_ms / SUM ( wait_time_ms ) OVER () AS pct ,
ROW_NUMBER () OVER ( ORDER BY wait_time_ms DESC ) AS rn
FROM sys.dm_os_wait_stats
WHERE wait_type
NOT IN
( 'CLR_SEMAPHORE' , 'LAZYWRITER_SLEEP' , 'RESOURCE_QUEUE' ,
'SLEEP_TASK' , 'SLEEP_SYSTEMTASK' , 'SQLTRACE_BUFFER_FLUSH' , 'WAITFOR' ,
'CLR_AUTO_EVENT' , 'CLR_MANUAL_EVENT' )
ORDER BY wait_time_ms DESC;


select
            case
                        when ws.wait_type like N'LCK_M_%' then N'Lock'
                        when ws.wait_type like N'LATCH_%' then N'Latch'
                        when ws.wait_type like N'PAGELATCH_%' then N'Buffer Latch'
                        when ws.wait_type like N'PAGEIOLATCH_%' then N'Buffer IO'
                        when ws.wait_type like N'RESOURCE_SEMAPHORE_%' then N'Compilation'
                        when ws.wait_type = N'SOS_SCHEDULER_YIELD' then N'Scheduler Yield'
                        when ws.wait_type in (N'LOGMGR', N'LOGBUFFER', N'LOGMGR_RESERVE_APPEND', N'LOGMGR_FLUSH', N'WRITELOG') then N'Logging'
                        when ws.wait_type in (N'ASYNC_NETWORK_IO', N'NET_WAITFOR_PACKET') then N'Network IO'
                        when ws.wait_type in (N'CXPACKET', N'EXCHANGE') then N'Parallelism'
                        when ws.wait_type in (N'RESOURCE_SEMAPHORE', N'CMEMTHREAD', N'SOS_RESERVEDMEMBLOCKLIST') then N'Memory'
                        when ws.wait_type like N'CLR_%' or ws.wait_type like N'SQLCLR%' then N'CLR'
                        when ws.wait_type like N'DBMIRROR%' or ws.wait_type = N'MIRROR_SEND_MESSAGE' then N'Mirroring'
                        when ws.wait_type like N'XACT%' or ws.wait_type like N'DTC_%' or ws.wait_type like N'TRAN_MARKLATCH_%' or ws.wait_type like N'MSQL_XACT_%' or ws.wait_type = N'TRANSACTION_MUTEX' then N'Transaction'
                        when ws.wait_type like N'SLEEP_%' or ws.wait_type in(N'LAZYWRITER_SLEEP', N'SQLTRACE_BUFFER_FLUSH', N'WAITFOR', N'WAIT_FOR_RESULTS') then N'Sleep'
                        else N'Other'
                  end as category, 
         ws.wait_type,
         ws.waiting_tasks_count,
         case when ws.waiting_tasks_count = 0 then 0 else ws.wait_time_ms / ws.waiting_tasks_count end as average_wait_time_ms,
         ws.wait_time_ms as total_wait_time_ms,
         convert(decimal(12,2), ws.wait_time_ms * 100.0 / sum(ws.wait_time_ms) over()) as wait_time_proportion,
         ws.wait_time_ms - signal_wait_time_ms as total_wait_ex_signal_time_ms,
         ws.max_wait_time_ms,
         ws.signal_wait_time_ms as total_signal_wait_time_ms
        -- @tstamp as tstamp
      from
         sys.dm_os_wait_stats ws
      where 
         ws.waiting_tasks_count > 0 -- Restrict results to requests that have actually occured.
      order by
         ws.wait_time_ms desc


WITH Waits AS 
( 
SELECT 
wait_type , 
wait_time_ms / 1000. AS wait_time_s , 
100. * wait_time_ms / SUM ( wait_time_ms ) OVER () AS pct , 
ROW_NUMBER () OVER ( ORDER BY wait_time_ms DESC ) AS rn 
FROM sys.dm_os_wait_stats 
WHERE wait_type 
NOT IN 
( 'CLR_SEMAPHORE' , 'LAZYWRITER_SLEEP' , 'RESOURCE_QUEUE' , 
'SLEEP_TASK' , 'SLEEP_SYSTEMTASK' , 'SQLTRACE_BUFFER_FLUSH' , 'WAITFOR' , 
'CLR_AUTO_EVENT' , 'CLR_MANUAL_EVENT' ) 
) 

SELECT W1.wait_type , 
CAST ( W1.wait_time_s AS DECIMAL ( 12 , 2 )) AS wait_time_s , 
CAST ( W1.pct AS DECIMAL ( 12 , 2 )) AS pct , 
CAST ( SUM ( W2.pct ) AS DECIMAL ( 12 , 2 )) AS running_pct 
FROM Waits AS W1 
INNER JOIN Waits AS W2 ON W2.rn <= W1.rn 
GROUP BY W1.rn , 
W1.wait_type , 
W1.wait_time_s , 
W1.pct 
HAVING SUM ( W2.pct ) - W1.pct < 95 ;