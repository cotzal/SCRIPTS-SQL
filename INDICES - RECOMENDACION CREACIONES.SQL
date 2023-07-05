/*
ECB: Saca los índices a crear en base a su ponderacion
*/

DECLARE @min_num_of_improved_queries int = 1000;

WITH    missing_indexes
          AS (
              SELECT    DB_NAME(mid.database_id) AS DatabaseName,
                        CONVERT (decimal(28,1),migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) AS improvement_measure,
                        'CREATE INDEX missing_index_' + CONVERT (nvarchar,mig.index_group_handle) + '_' + CONVERT (nvarchar,mid.index_handle) + ' ON '
                        + mid.statement + ' (' + ISNULL(mid.equality_columns,'') + CASE WHEN mid.equality_columns IS NOT NULL
                                                                                             AND mid.inequality_columns IS NOT NULL THEN ','
                                                                                        ELSE ''
                                                                                   END + ISNULL(mid.inequality_columns,'') + ')' + ISNULL(' INCLUDE ('
                                                                                                                                          + mid.included_columns
                                                                                                                                          + ')','') AS create_index_statement,
                        ISNULL(mid.equality_columns,'') + CASE WHEN mid.equality_columns IS NOT NULL
                                                                    AND mid.inequality_columns IS NOT NULL THEN ','
                                                               ELSE ''
                                                          END + ISNULL(mid.inequality_columns,'') columnas_a_indexar,
                        mig.index_group_handle,
                        mid.index_handle,
                        migs.[group_handle],
                        migs.[unique_compiles],
                        migs.[user_seeks],
                        migs.[user_scans],
                        migs.[last_user_seek],
                        migs.[last_user_scan],
                        migs.[avg_total_user_cost],
                        migs.[avg_user_impact],
                        migs.[system_seeks],
                        migs.[system_scans],
                        migs.[last_system_seek],
                        migs.[last_system_scan],
                        migs.[avg_total_system_cost],
                        migs.[avg_system_impact],
                        mid.[object_id],
                        OBJECT_NAME(object_id,database_id) object_name,
                        statement,
                        database_id
              FROM      sys.dm_db_missing_index_groups mig
                        INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
                        INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
              WHERE     CONVERT (decimal(28,1),migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 10
						AND (migs.user_seeks +migs.user_scans+migs.system_seeks+migs.system_scans) >= @min_num_of_improved_queries
                        AND object_id > 100
             ),
        query
          AS (
              SELECT    DB_NAME(us.database_id) AS database_name,
                        OBJECT_NAME(us.object_id,us.database_id) AS [object_name],
                        mi.columnas_a_indexar AS missing_index_columns,
                        (us.user_seeks + us.user_scans + us.user_lookups + us.system_seeks + us.system_scans + us.system_lookups) * 0.7 AS object_total_reads,
                        (us.user_updates + us.system_updates) AS object_total_writes,
                        CAST(CASE WHEN (us.user_seeks + us.user_scans + us.user_lookups + us.system_seeks + us.system_scans + us.system_lookups) = 0 THEN 0
                                  ELSE (us.user_updates + us.system_updates) / ((us.user_seeks + us.user_scans + us.user_lookups + us.system_seeks
                                                                                 + us.system_scans + us.system_lookups) * 0.7) * 100.0
                             END AS decimal(10,2)) AS object_writes_ratio_perc,
                        mi.improvement_measure AS missing_index_improvement_measure,
                        mi.avg_total_user_cost,
                        mi.avg_user_impact,
                        mi.avg_system_impact,
                        mi.[avg_total_system_cost],
                        mi.user_seeks + mi.system_seeks AS potential_seeks,
						mi.user_scans + mi.system_scans AS potential_scans,
                        us.user_scans,
                        us.user_lookups,
                        us.user_updates,
                        us.last_user_seek,
                        us.last_user_scan,
                        us.last_user_lookup,
                        us.last_user_update,
                        us.system_seeks,
                        us.system_scans,
                        us.system_lookups,
                        us.system_updates,
                        us.last_system_seek,
                        us.last_system_scan,
                        us.last_system_lookup,
                        us.last_system_update,
                        mi.create_index_statement
              FROM      sys.dm_db_index_usage_stats us
                        INNER JOIN missing_indexes mi ON us.database_id = mi.database_id
                                                         AND us.object_id = mi.object_id
              WHERE     us.object_id > 100
                        AND us.index_id = 1 -- CI
             )
     SELECT database_name,
            [object_name],
            missing_index_columns,
            IIF(object_writes_ratio_perc >= 100,0,100 - object_writes_ratio_perc) * potential_seeks * avg_user_impact AS missing_index_improvement_ponderado,
            object_writes_ratio_perc,
			potential_seeks + potential_scans as num_of_improved_queries,
            potential_seeks AS potential_seeks_over_new_index,
			potential_scans AS potential_scans_over_new_index,
            avg_user_impact,
            object_total_reads,
            object_total_writes,
            missing_index_improvement_measure,
            avg_total_user_cost,
            avg_system_impact,
            [avg_total_system_cost],
            create_index_statement
     FROM   query
	 -- where object_total_writes = 0
     ORDER BY missing_index_improvement_ponderado DESC;

