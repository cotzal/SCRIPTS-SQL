select DISTINCT partition_funcion from etl_particiones group by name,partition_funcion having count(*) > 2
