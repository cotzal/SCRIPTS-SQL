select session_id, command, text, start_time, percent_complete, dateadd(second,estimated_completion_time/1000,getdate()) as estimado
from sys.dm_exec_requests r cross apply sys.dm_exec_sql_text(r.sql_handle) a
