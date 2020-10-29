DECLARE @tableHTML NVARCHAR(MAX) ;


   SET @tableHTML = N'<table border="1">' +
                    N'<tr>'+
                    N'<th>Id</th><th>Descripcion</th><th>Estado</th>' +
                    N'</tr>' +
                    CAST ( (
                            SELECT td = fj.bpr_id, '',
                                   td = fj.bpr_descripcion, '',
                                   td = fj.bpr_estado, ''
                              FROM bch_procesos fj
                              --Groups all the jobs with the same job name together into one email
                              --WHERE
                              ORDER BY fj.bpr_descripcion DESC
                              FOR XML PATH('tr'), TYPE
                                ) AS NVARCHAR(MAX) ) +
 	                          N'</table>' ;
   EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'COMDWH_Correo',
            @recipients = 'durgell@minsait.com',
            @subject = 'test',
            @body = @tableHTML,
            @body_format = 'HTML' ;