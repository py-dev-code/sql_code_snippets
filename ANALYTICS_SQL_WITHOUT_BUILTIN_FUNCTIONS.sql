1. RANK(), DENSE_RANK() and ROW_NUMBER()

create table emp (
first_name varchar2(50),
last_name varchar2(50),
dept_id number,
salary number);

delete from emp;
insert into emp values ('Bob1', 'Marlay', 1, 100);
insert into emp values ('Bob2', 'Marlay', 1, 100);
insert into emp values ('Bob3', 'Marlay', 1, 102);

insert into emp values ('Bob4', 'Marlay', 2, 101);
insert into emp values ('Bob5', 'Marlay', 2, 102);

commit;

SELECT 
    first_name, last_name, dept_id, salary,
	ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS row_num,
    DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS denserank,
    RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rnk
FROM emp;

select
    first_name, last_name, dept_id, salary,
    (select count(distinct salary)
      from emp emp2
      where emp2.dept_id = emp.dept_id
        and emp2.salary <= emp.salary) dense_rnk,
    (select count(*) + 1
      from emp emp2
      where emp2.dept_id = emp.dept_id
        and emp2.salary < emp.salary) rnk,
    (select count(*)
       from emp emp2
      where emp2.dept_id = emp.dept_id
        and emp2.salary <= emp.salary and emp2.first_name <= emp.first_name) row_num        
from emp;

2. Listagg(): https://davidsgale.com/recursive-with-clauses/ [An article on recursive-with-clauses]
ORA-32044 | ORA-32040 | ORA-32039 [Some errors in Recursive With Clauses]

create table listagg_demo (
emp_id number,
emp_name varchar2(50),
department number);

delete from listagg_demo;
insert into listagg_demo values (1, 'Bob1', 1);
insert into listagg_demo values (2, 'Bob2', 1);
insert into listagg_demo values (3, 'Bob3', 1);

insert into listagg_demo values (4, 'Bob4', 2);
insert into listagg_demo values (5, 'Bob5', 2);
commit;

select department, listagg(emp_name, ',') within group (order by emp_id) emp_name
from listagg_demo group by department;

--ORACLE Syntax
WITH t (emp_name, department, rn) AS 
  (SELECT emp_name, 
		  department,
		  (SELECT COUNT(*) 
             FROM listagg_demo a
            WHERE a.department = listagg_demo.department
              AND listagg_demo.emp_name >=  a.emp_name) rn
	 FROM listagg_demo),
  c (emp_name, department, rn) AS --Below is using a Recursive With clause and it must have column definition and can only use UNION ALL.
  (SELECT emp_name, 
		  department, 
		  rn 
	 FROM t 
	WHERE rn = 1
   UNION ALL
   SELECT c1.emp_name ||', '|| t1.emp_name, 
		  t1.department, 
		  c1.rn+1
     FROM t t1 , c c1
    WHERE t1.department = c1.department
      AND c1.rn + 1 = t1.rn)
SELECT department, emp_name, rn
FROM c c1
WHERE rn = (SELECT MAX(rn)
              FROM c c2
             WHERE c1.department = c2.department)
ORDER BY 1;    
			 
--MySQL Syntax:
with recursive c (dept, emp_name, rn) as
  (select t.department,
          t.emp_name,
          t.rn
     from (select t1.department,
                  t1.emp_name,
                  ROW_NUMBER() OVER (PARTITION BY t1.department ORDER BY t1.emp_name) as rn       
             from listagg_demo t1) t
    where t.rn = 1    
   union all
   select c.dept,
          concat(c.emp_name,',',t.emp_name),
          c.rn + 1
     from c, (select t1.department as dept,
				     t1.emp_name,
				     ROW_NUMBER() OVER (PARTITION BY t1.department ORDER BY t1.emp_name) as rn       
				from listagg_demo t1) t
    where c.dept = t.dept
      and c.rn + 1 = t.rn)
select dept, 
	   emp_name 
  from c
 where rn = (select max(rn) from c c2 where c.dept = c2.dept)
 order by 1;