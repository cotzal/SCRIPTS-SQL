USE msdb ;  
GO  

EXEC dbo.sp_help_jobhistory   
    @job_name = N'COMDWH_BONIFICACIONES' ;  
GO  