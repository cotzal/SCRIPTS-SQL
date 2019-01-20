-- informes cacheados
select cx.reportId, cx.ExecutionCacheId, rp.path, rp.name, cx.expirationFlags, cx.AbsoluteExpiration, cx.LastUsedTime, cx.paramsHash from reportServerTempDb.dbo.ExecutionCache as cx inner join reportServer.dbo.Catalog as rp
on cx.ReportId = rp.ItemId

-- schedule de reports
select rs.*, rp.* from reportServer.dbo.ReportSchedule as rs inner join reportServer.dbo.Catalog as rp on rp.itemid = rs.reportid

-- revision ejecucion de un reporting
SELECT * FROM reportServer.dbo.ExecutionLogStorage WHERE ReportID = '62E0804F-4D36-433C-BD8E-E0699ACFAB27' ORDER BY TimeStart DESC


--exec [ReportServer].dbo.AddEvent @EventType='RefreshCache', @EventData='d26fafd4-6b85-424e-a0f0-5362cbd31a27'

EXEC FlushReportFromCache '/Negoci SSCC/Control devoluciones'

-- informacion de reports
Select C.Name,C.Path,U.UserName,C.CreationDate,C.ModifiedDate from Catalog C
INNER Join Users U ON C.CreatedByID=U.UserID
