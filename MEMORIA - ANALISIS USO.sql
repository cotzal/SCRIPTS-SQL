SELECT
(Physical_memory_in_use_kb / 1024) as Memory_usedby_Sqlserver_MB,
(Locked_page_allocations_kb / 1024) as Locked_pages_used_Sqlserver_MB,
(Total_virtual_address_space_kb / 1024) as Total_VAS_in_MB,
process_physical_memory_low,
process_virtual_memory_low
from sys.dm_os_process_memory;


SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Buffer Manager%'
AND [counter_name] = 'Page life expectancy'

SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Buffer Manager%'
AND [counter_name] = 'Buffer cache hit ratio'
