set define off

spool C:\log_file.log

prompt conn as schema_name

prompt executing sqlplus command

--host "dir"
--host "cd C:\Users\dir_name  && dir"
--host "dir"
--host command will execute only 1 command and then returns back to its own directory thats why use && to execute more than 1 command.

host "cd C:\Users\dir_name  && sqlldr username/password@DB_NAME CONTROL=control_file.ctl"

set define on  --use this to prompt the password for SQLLDR

host "sqlldr username/&PASSWORD@DB_NAME CONTROL=full_path_to_control_file\control_file_name.ctl DATA=full_path_to_data_file\data_file_name.csv bad= path\bad_file_name.bad LOG= log_path\log_file_name.log errors=2000 BINDSIZE=10000000 rows=20000 readsize=10000000"

--important: Full SQLLDR command should be in 1 line. If you press enter in between then command will fail.

spool off

exit;