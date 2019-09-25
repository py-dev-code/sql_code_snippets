BEGIN
  dbms_scheduler.drop_job('OWNER.JOB_NAME');
END;
/
 
DECLARE
  v_db_inst    VARCHAR2(10);
  v_recipients VARCHAR2(200);
BEGIN
  SELECT upper(global_name)
    INTO v_db_inst
    FROM global_name;

  IF v_db_inst = 'PROD' THEN
    v_recipients := 'email1, email2';
  ELSE  
    v_recipients := 'email3, email4, email5';
  END IF;

  sys.dbms_scheduler.create_job(job_name        => 'OWNER.JOB_NAME',
                                job_type        => 'PLSQL_BLOCK',
                                job_action      => 'BEGIN user.package_name.procedure_name; END;',
                                start_date      => trunc(SYSDATE+1)+6/24,
                                repeat_interval => 'Freq=daily',
                                end_date        => NULL,
                                job_class       => 'DEFAULT_JOB_CLASS',
                                enabled         => TRUE,
                                auto_drop       => FALSE,
                                comments        => 'A DBMS Scheduler job');

  sys.dbms_scheduler.add_job_email_notification(job_name         => 'OWNER.JOB_NAME',
                                                sender           => v_db_inst || '_auto_emailer@domain',
                                                subject          => 'Oracle Scheduler Job Notification - %job_owner%.%job_name%.%job_subname% %event_type%',
                                                BODY             => 'JOB_NAME failed. Please check with DBA for further details.'||CHR(10)||
																	'Below are some error details:'||CHR(10)||
																	'Error Code: %error_code%'||CHR(10)||
																	'Error Message: %error_message%',
                                                recipients       => v_recipients,
                                                filter_condition => '',
                                                events           => 'JOB_FAILED');
END;
/

--select * from ALL_SCHEDULER_JOB_RUN_DETAILS where job_name = 'JOB_NAME';
--select * from dba_scheduler_jobs where job_name = 'JOB_NAME';
--exec sys.dbms_scheduler.drop_job('OWNER.JOB_NAME');
