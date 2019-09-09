--query to find out if a particular object is locked or not
select a.sid, a.serial#
from v$session a, v$locked_object b, dba_objects c
where b.object_id = c.object_id
and a.sid = b.session_id
and OBJECT_NAME='WCT_DMR_PARAMETERS'; 

--query to find out all the locked objects by all the users
select a.sid, a.serial#, c.object_name, c.object_type
from v$session a, v$locked_object b, dba_objects c
where b.object_id = c.object_id
and a.sid = b.session_id
and OBJECT_NAME in ('WCT_DMR_PARAMETERS'); 

--query to find if a procedure, function or package is locked
select 
   x.sid 
from 
   v$session x, v$sqltext y
where 
   x.sql_address = y.address
and 
   y.sql_text like upper('%cus_mdq_search_pkg%');