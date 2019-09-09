--Important Views:
1. To check all the scheduler jobs:
select * from dba_scheduler_jobs;

2. To check all the DB chains:
select * from dba_scheduler_chains; 

3. To check the Chain steps and respective programs
select * from dba_scheduler_chain_steps;

4. To check the details of step programs:
select * from dba_scheduler_programs;

5. To check the chain rules:
select * from dba_scheduler_chain_rules;

--Oracle Docs Link for all the Data Dictionary Views to check the Scheduler jobs:
https://docs.oracle.com/cd/B19306_01/server.102/b14231/schedadmin.htm
