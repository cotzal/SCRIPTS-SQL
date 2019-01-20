select
t.[name] as [fg_name],
f.[name] as [file_name],
fg.[name] as [table_name]
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
GO