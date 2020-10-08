declare rs cursor for SELECT name FROM SYS.SYSOBJECTS WHERE XTYPE IN ('P','X','FN') AND CATEGORY <> 2
declare @name varchar(200)
declare @tabla table (stored varchar(max),texto varchar(max))
declare @tabla2 table (texto varchar(max))

open rs

fetch next from rs into @name
while @@FETCH_STATUS = 0
begin

	insert into @tabla2 
	exec sp_helptext @name

	insert into @tabla
	select @name, texto
	from @tabla2 

	delete from @tabla2

	fetch next from rs into @name
end

close rs
deallocate rs

select * from @tabla where texto like '%mae_perfiles%'

