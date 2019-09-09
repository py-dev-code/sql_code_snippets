drop table test1; 
drop table test2;
create table test1(plc_id number, ncs_cd number, req_id number);
insert into test1 values (1, 100, 1);
insert into test1 values (1, 200, 1);
insert into test1 values (1, 100, 2);
insert into test1 values (2, 300, 1);
create table test2(plc_id number, ncs_cd number, col3 number);
insert into test2 values (1, 100, null);
insert into test2 values (1, 300, null);
commit;

select * from test1 where req_id = 1;
select * from test2;

merge into test2 tab2
using (select plc_id, ncs_cd from test1 where req_id = 1) tab1
on (tab2.plc_id = tab1.plc_id and tab2.ncs_cd = tab1.ncs_cd)
when matched then update set tab2.col3 = tab1.ncs_cd + 1
when not matched then insert values (tab1.plc_id, tab1.ncs_cd, null);