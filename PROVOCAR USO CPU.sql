DECLARE @T DATETIME, @F BIGINT;
SET @T = GETDATE();
WHILE DATEADD(SECOND,3060,@T)>GETDATE()
SET @F=POWER(2,30);