SELECT     
    d.name AS [Database], 
    f.physical_name AS [File], 
    (fs.num_of_bytes_read / 1024.0 / 1024.0) [Total MB Read], 
    (fs.num_of_bytes_written / 1024.0 / 1024.0) AS [Total MB Written], 
    (fs.num_of_reads + fs.num_of_writes) AS [Total I/O Count], 
    fs.io_stall AS [Total I/O Wait Time (ms)], 
    fs.size_on_disk_bytes / 1024 / 1024 AS [Size (MB)],
    fs.io_stall_read_ms
FROM sys.dm_io_virtual_file_stats(default, default) AS fs
INNER JOIN sys.master_files f ON fs.database_id = f.database_id AND fs.file_id = f.file_id
INNER JOIN sys.databases d ON d.database_id = fs.database_id
order by fs.io_stall desc; 