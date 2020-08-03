SELECT CAST(QCE_FECHA as date), QCE_RESULT, COUNT(*) 
FROM DAT_ESTADISTICAS_QC_ENTRY 
where CAST(QCE_FECHA as date) = '25/07/2020'  
and QCE_OPERACION = 'Venta'
group by CAST(QCE_FECHA as date), QCE_RESULT order by CAST(QCE_FECHA as date)

select cast(RTS_FECHA_TRANSACCION as date) ,  COUNT(*), OPE_SUBTIPO_MOVIMIENTO 
from DAT_OPERACIONES_CONTABLES_NW as t1 inner join COMERCIA_AGR.[dbo].[Q2_ASIGNACION_TERMINALES] as t2 
		on t1.TER_NUMERO_SERIE = t2.TER_NUMERO_SERIE 
		   and t2.indicador_origen = 'C'
where t1.ope_fecha_movimiento > '20/07/2020'
group by cast(RTS_FECHA_TRANSACCION as date) , OPE_SUBTIPO_MOVIMIENTO
order by cast(RTS_FECHA_TRANSACCION as date)