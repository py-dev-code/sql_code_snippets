SELECT SQL_TEXT FROM V$sqltext_with_newlines A, V$SESSION B
WHERE A.ADDRESS = B.SQL_ADDRESS 
AND B.SID = 772 ORDER BY PIECE;	

--Estimating the %completion of a query if it is using a Full Scan
SELECT
opname,
target,
ROUND( ( sofar/totalwork ), 4 ) * 100 Percentage_Complete,
start_time,
CEIL( time_remaining / 60 ) Max_Time_Remaining_In_Min,
FLOOR( elapsed_seconds / 60 ) Time_Spent_In_Min
FROM v$session_longops
WHERE sofar != totalwork;

SELECT * FROM V$SESSION_LONGOPS WHERE SID = 630;

SELECT 
opname
target,
ROUND( ( sofar / totalwork ), 4 ) * 100 Percentage_Complete,
start_time,
CEIL( time_remaining / 60 ) Max_Time_Remaining_In_Min,
FLOOR( elapsed_seconds / 60 ) Time_Spent_In_Min,
AR.sql_fulltext,
AR.parsing_schema_name,
AR.module Client_Tool
FROM v$session_longops L, v$sqlarea AR
WHERE L.sql_id = AR.sql_id
AND totalwork > 0
AND AR.users_executing > 0
AND sofar != totalwork;