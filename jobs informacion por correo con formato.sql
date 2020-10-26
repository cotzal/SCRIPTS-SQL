-- Get the job ID for the job this is running in.
-- Note, will only run inside the job, not in an SSMS query
DECLARE @JobID UNIQUEIDENTIFIER;
SET @JobID = (SELECT CONVERT(uniqueidentifier, $(ESCAPE_NONE(JOBID))));
--Get the last time this job ran
DECLARE @LastRunTime DATETIME;
SET @LastRunTime = (SELECT MAX([msdb].[dbo].agent_datetime(jh.[run_date], jh.[run_time]))
                    FROM [msdb].[dbo].[sysjobhistory] jh
                    WHERE jh.[job_id] = @JobID);
--Get all the failed jobs into a temp table, and give each individual job an ID
SELECT
   RANK() OVER(ORDER BY j.[name] ASC) AS FailedJobsID,
   j.[name] AS JobName,
   jh.[step_name] AS StepName,
   [msdb].[dbo].agent_datetime(jh.[run_date], jh.[run_time]) AS RunDateTime,
   SUBSTRING(jh2.[message], PATINDEX('%The Job was invoked by User%', jh2.[message]) + 28, PATINDEX('%The last step to run was%', jh2.[message]) -PATINDEX('%The Job was invoked by User%', jh2.[message])-28) AS ExecutedBy,
   REPLACE(SUBSTRING(jh.[message], 1, PATINDEX('%. %', jh.[message])) , 'Executed as user: ','') AS ExecutionContext,
   REPLACE(SUBSTRING(jh.[message], PATINDEX('%. %', jh.[message]) + 2, LEN(jh.[message]) - PATINDEX('%. %', jh.[message])-1), ' The step failed.','') AS FailureMessage,
   0 AS Emailed
 INTO #FailedJobs
 FROM [msdb].[dbo].[sysjobs] j
   INNER JOIN [msdb].[dbo].[sysjobhistory] jh ON jh.[job_id] = j.[job_id]
   INNER JOIN [msdb].[dbo].[sysjobsteps] js ON js.[job_id] = j.[job_id] AND js.[step_id] = jh.[step_id]
   INNER JOIN [msdb].[dbo].[sysjobhistory] jh2 ON jh2.[job_id] = jh.[job_id]
 --Job isn't currently running
 WHERE jh.[run_status] = 0
  --Only get jobs that ran since we last checked for failed jobs
  AND [msdb].[dbo].agent_datetime(jh.[run_date], jh.[run_time]) > DATEADD(SECOND,-1,@LastRunTime)
  --Join back to sysjobhistory again to get step_id 0 for the failed job, to find who executed it
  AND jh.[sql_severity] > 0
  AND jh2.[step_id] = 0
  AND [msdb].[dbo].agent_datetime(jh2.[run_date], jh2.[run_time]) <= [msdb].[dbo].agent_datetime(jh.[run_date], jh.[run_time])
  AND NOT EXISTS (SELECT 1 FROM [msdb].[dbo].[sysjobhistory] jh3
                  WHERE [msdb].[dbo].agent_datetime(jh3.[run_date], jh3.[run_time]) > [msdb].[dbo].agent_datetime(jh2.[run_date], jh2.[run_time])
  AND jh3.[job_id] = jh2.job_id)
  --Add any exclusions here, for example:
  --Any SSIS steps, as the job history doesn't show SSIS catalogue error messages.
  --Checks for running SQL on either node of an Always On Availability Group
  AND js.[subsystem] <> 'SSIS'
  AND jh.[message] NOT LIKE ('%Unable to execute job on secondary node%')
  AND jh.[message] NOT LIKE ('%Request to run job%refused because the job is already running from a request by User%');
--Variable to store the current job being dealt with
DECLARE @CurrentFailedJobID INT;
WHILE EXISTS (SELECT 1 FROM #FailedJobs)
--Loop through all the failed jobs
 BEGIN
   SET @CurrentFailedJobID = (SELECT TOP 1 fj.[FailedJobsID] FROM #FailedJobs fj);
   --Set the email subject
   DECLARE @MailSubject VARCHAR(255);
   SET @MailSubject = (SELECT @@SERVERNAME + ': ' + fj.[JobName] + ' steps have failed'
     FROM #FailedJobs fj
     WHERE fj.[FailedJobsID] = @CurrentFailedJobID
     GROUP BY fj.[JobName]);
   --Set the output as an HTML table to make it clear to read
   DECLARE @tableHTML NVARCHAR(MAX) ;
   SET @tableHTML = N'<table border="1">' +
                    N'<tr>'+
                    N'<th>Job Name</th><th>Job Step</th><th>Run Time</th><th>Run By</th><th>Execution Context</th><th>Error Message</th>' +
                    N'</tr>' +
                    CAST ( (
                            SELECT td = fj.[JobName], '',
                                        td = fj.[StepName], '',
                                   td = fj.[RunDateTime], '',
                                   td = fj.[ExecutedBy], '',
                                   td = fj.[ExecutionContext], '',
                                   td = fj.[FailureMessage], ''
                              FROM #FailedJobs fj
                              --Groups all the jobs with the same job name together into one email
                              WHERE fj.[FailedJobsID] = @CurrentFailedJobID
                              ORDER BY fj.[RunDateTime] DESC
                              FOR XML PATH('tr'), TYPE
                                ) AS NVARCHAR(MAX) ) +
 	                          N'</table>' ;
   EXEC msdb.dbo.sp_send_dbmail
            @recipients = 'support@mycompany.net',
            @subject = @MailSubject,
            @body = @tableHTML,
            @body_format = 'HTML' ;
  --Delete the currently emailed job from the failed jobs list
  DELETE fj
    FROM #FailedJobs fj
    WHERE fj.[FailedJobsID] = @CurrentFailedJobID;
 END