SELECT
    J.name AS 'Nombre del Job',
    ja.start_execution_date AS 'Inicio a las:',
    DATEDIFF(ss, ja.start_execution_date, GETDATE()) AS 'Ha corrido por: (Segundos)'
FROM msdb.dbo.sysjobactivity ja
     INNER JOIN msdb.dbo.sysjobs J ON J.job_id=ja.job_id
WHERE job_history_id IS NULL AND ja.start_execution_date IS NOT NULL
ORDER BY start_execution_date;