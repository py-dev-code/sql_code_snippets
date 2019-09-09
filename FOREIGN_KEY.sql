--List down all the foreign key constraints details. (Very Nice)**
select a.table_name, a.column_name, a.r_owner, b.table_name r_table_name, b.column_name r_column_name, a.constraint_name 
from
(select a.table_name, b.column_name, a.constraint_name, a.r_owner, a.r_constraint_name from all_constraints a, all_cons_columns b
where 
a.owner = b.owner 
and a.table_name = upper('TABLE_NAME')
and a.constraint_name = b.constraint_name 
and a.constraint_type = 'R'
and a.table_name = b.table_name) a,
all_cons_columns b
where a.r_constraint_name = b.constraint_name
and a.r_owner = b.owner;

--List down all the tables which are referring a Given table with Foreign Key
select a.table_name, a.column_name, a.r_owner, b.table_name r_table_name, b.column_name r_column_name, a.constraint_name 
from
(select a.table_name, b.column_name, a.constraint_name, a.r_owner, a.r_constraint_name from all_constraints a, all_cons_columns b
where 
a.owner = b.owner 
and a.constraint_name = b.constraint_name 
and a.constraint_type = 'R'
and a.table_name = b.table_name) a,
all_cons_columns b
where a.r_constraint_name = b.constraint_name
and a.r_owner = b.owner
and b.table_name = 'TABLE_NAME' order by 1;
