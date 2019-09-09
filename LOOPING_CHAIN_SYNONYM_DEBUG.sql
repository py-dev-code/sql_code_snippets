--This query will list down the Objects that has a Valid Public Synonym but underlying object has issues and Package will be Invalid due to that.
select B.* from dba_dependencies A, DBA_OBJECTS B where A.name = 'PACKAGE_NAME' AND A.REFERENCED_TYPE IN ('SYNONYM', 'TABLE')
AND A.REFERENCED_NAME NOT IN ('DUAL','PLITBLM','DBMS_OUTPUT','DBMS_UTILITY')
AND A.REFERENCED_NAME = B.OBJECT_NAME
AND B.OBJECT_NAME IN
(
SELECT S.SYNONYM_NAME     
FROM DBA_SYNONYMS S
    LEFT JOIN DBA_OBJECTS O ON S.TABLE_OWNER = O.OWNER AND S.TABLE_NAME = O.OBJECT_NAME
WHERE O.OWNER is null
    OR O.STATUS != 'VALID');