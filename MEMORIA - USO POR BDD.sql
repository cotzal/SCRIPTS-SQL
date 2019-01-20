DECLARE @total_buffer INT;
SELECT @total_buffer = cntr_value
FROM sys.dm_os_performance_counters
WHERE RTRIM([object_name]) LIKE'%Buffer Manager'
AND counter_name = 'Total Pages';

WITH BufCount AS
(
SELECT
database_id, db_buffer_pages = COUNT_BIG(*)
FROM sys.dm_os_buffer_descriptors
WHERE database_id BETWEEN 5 AND 32766
GROUP BY database_id
)
SELECT
[Database_Name] = CASE [database_id] WHEN 32767
THEN'MSSQL System Resource DB'
ELSE DB_NAME([database_id]) END,
[Database_ID],
db_buffer_pages as [Buffer Count (8KB Pages)],
[Buffer Size (MB)] = db_buffer_pages / 128,
[Buffer Size (%)] = CONVERT(DECIMAL(6,3),
db_buffer_pages * 100.0 / @total_buffer)
FROM BufCount
ORDER BY [Buffer Size (MB)] DESC;