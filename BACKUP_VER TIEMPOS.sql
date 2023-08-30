select backup_start_date, backup_finish_date, 
LAG(backup_start_date, 1) OVER (PARTITION BY database_name ORDER BY backup_start_date) as previous_start_date, 
CASE datediff(mi,(LAG(backup_start_date, 1) OVER (PARTITION BY database_name ORDER BY backup_start_date)),backup_start_date) WHEN 0 THEN 'OVERLAPPING' ELSE '-' END as [Status] , 
datediff(mi,backup_start_date,backup_finish_date) as backup_time_mins, type 
from msdb..backupset 
where database_name = 'COMERCIA_WEB' -- Replace with appropriate database name 
and type <> 'L' 
order by backup_start_date