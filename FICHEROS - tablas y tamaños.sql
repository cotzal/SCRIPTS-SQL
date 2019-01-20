SELECT 
    X.[name], 
    REPLACE(CONVERT(varchar, CONVERT(money, X.[rows]), 1), '.00', '') 
        AS [rows], 
    REPLACE(CONVERT(varchar, CONVERT(money, X.[reserved]), 1), '.00', '') 
        AS [reserved], 
    REPLACE(CONVERT(varchar, CONVERT(money, X.[data]), 1), '.00', '') 
        AS [data], 
    REPLACE(CONVERT(varchar, CONVERT(money, X.[index_size]), 1), '.00', '') 
        AS [index_size], 
    REPLACE(CONVERT(varchar, CONVERT(money, X.[unused]), 1), '.00', '') 
        AS [unused] 
FROM 
(SELECT 
    CAST(object_name(id) AS varchar(50)) 
        AS [name], 
    SUM(CASE WHEN indid < 2 THEN CONVERT(bigint, [rows]) END) 
        AS [rows],
    SUM(CONVERT(bigint, reserved)) * 8 
        AS reserved, 
    SUM(CONVERT(bigint, dpages)) * 8 
        AS data, 
    SUM(CONVERT(bigint, used) - CONVERT(bigint, dpages)) * 8 
        AS index_size, 
    SUM(CONVERT(bigint, reserved) - CONVERT(bigint, used)) * 8 
        AS unused 
    FROM sysindexes WITH (NOLOCK) 
    WHERE sysindexes.indid IN (0, 1, 255) 
        AND sysindexes.id > 100 
        AND object_name(sysindexes.id) <> 'dtproperties' 
    GROUP BY sysindexes.id WITH ROLLUP
) AS X
WHERE X.[name] in (select distinct 
t.[name] as [fg_name]
from
sys.tables as t
inner join
sys.indexes as i
on t.[object_id] = i.[object_id]
inner join
sys.filegroups as fg
on i.data_space_id = fg.data_space_id
inner join
sys.database_files as f
on f.data_space_id = fg.data_space_id
where
i.index_id in (0, 1)
and fg.name = 'PRIMARY' and f.name = 'COMERCIA_DWH'
)
ORDER BY X.[rows] DESC