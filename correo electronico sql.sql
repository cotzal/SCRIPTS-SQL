SELECT TOP 20 *
FROM [msdb].[dbo].[sysmail_sentitems]
ORDER BY [send_request_date] DESC


SELECT TOP 20 *
FROM [msdb].[dbo].[sysmail_faileditems]
ORDER BY [send_request_date] DESC

SELECT TOP 20 *
FROM [msdb].[dbo].[sysmail_allitems]
ORDER BY [send_request_date] DESC


SELECT items.subject,  
    items.last_mod_date  
    ,l.description FROM dbo.sysmail_faileditems as items  
INNER JOIN dbo.sysmail_event_log AS l  
    ON items.mailitem_id = l.mailitem_id  
WHERE items.recipients LIKE '%danw%'    
    OR items.copy_recipients LIKE '%danw%'   
    OR items.blind_copy_recipients LIKE '%danw%'  