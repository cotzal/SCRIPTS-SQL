declare @funcion_particionado varchar(100) = 'F_OPERACIONES_DESNORMALIZADAS'
declare @fechai datetime = '01/01/2018'

/*
select file_group_name, sum(free_space) as espacio_MB, disco
from
(
select file_group_name, 
	   convert(decimal(12,2),round((b.size-fileproperty(b.name,'SpaceUsed'))/128.000,2)) as free_space,
	   substring(filename,16,14) as disco
  from etl_particiones as ep inner join dbo.sysfiles as b on ep.file_group_name = FILEGROUP_NAME(b.groupid)
 where patition_schema = @funcion_particionado 
   and cast(isnull(left_boundary,'01/01/1900') as datetime) >= @fechai 
) as t
group by file_group_name, disco

select file_group_name, sum(free_space) as espacio
from
(
select file_group_name, 
	   convert(decimal(12,2),round((b.size-fileproperty(b.name,'SpaceUsed'))/128.000,2)) as free_space,
	   substring(filename,16,14) as disco
  from etl_particiones as ep inner join dbo.sysfiles as b on ep.file_group_name = FILEGROUP_NAME(b.groupid)
 where patition_schema = @funcion_particionado 
   and cast(isnull(left_boundary,'01/01/1900') as datetime) >= @fechai 
) as t
group by file_group_name
order by file_group_name 

*/
select *
from
(
select file_group_name, sum(free_space) as espacio_MB, disco
from
(
select file_group_name, 
	   convert(decimal(12,2),round((b.size-fileproperty(b.name,'SpaceUsed'))/128.000,2)) as free_space,
	   substring(filename,16,14) as disco
  from etl_particiones as ep inner join dbo.sysfiles as b on ep.file_group_name = FILEGROUP_NAME(b.groupid)
 where patition_schema = @funcion_particionado 
   and cast(isnull(left_boundary,'01/01/1900') as datetime) >= @fechai 
) as t
group by file_group_name, disco
) as t2 where espacio_MB < 2000 
order by disco 