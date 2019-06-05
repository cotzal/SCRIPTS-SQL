SELECT request_session_id, COUNT (*) num_locks FROM sys.dm_tran_locks GROUP BY request_session_id  ORDER BY count (*) DESC
