SELECT
    sysobjects.name AS table_name,
    syscolumns.name AS column_name,
    systypes.name AS datatype,
    syscolumns.LENGTH AS LENGTH
FROM
    sysobjects
    INNER JOIN syscolumns ON sysobjects.id = syscolumns.id
    INNER JOIN systypes ON syscolumns.xtype = systypes.xtype
WHERE
    (sysobjects.xtype = 'U')
    and (
        UPPER(syscolumns.name) like upper('%OPE_RUTA_TASA%')
    )
ORDER BY
    sysobjects.name,
    syscolumns.colid