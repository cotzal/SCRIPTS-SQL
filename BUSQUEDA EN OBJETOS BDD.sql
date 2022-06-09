SELECT
  Object_name(so .parent_object_id) Parent_Name,
  so .name [Objeto],
  so .type_desc [Tipo],
  so .create_date [Creado],
  sm.definition [Texto]
FROM sys .objects so
INNER JOIN sys. sql_modules sm ON so.object_id = sm.object_id
WHERE  
    --so .type = 'P' AND
    CONVERT(VARCHAR(8000),sm.definition) LIKE '%TAB_IND_SALDOS%'