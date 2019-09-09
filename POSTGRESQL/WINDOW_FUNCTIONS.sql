drop table products;
drop table product_groups;

create table product_groups(
group_id serial primary key,
group_name varchar(255) not null);

create table products (
product_id  serial primary key,
product_name varchar(255),
price decimal(11,2),
group_id int,
foreign key (group_id) references product_groups (group_id));

insert into product_groups (group_name)
values
('Smartphone'),
('Laptop'),
('Tablet');

select * from product_groups;

insert into products (product_name, group_id, price)
values
('Microsoft Lumia', 1, 200),
('HTC One', 1, 400),
('Nexus', 1, 500),
('iPhone', 1, 900),
('HP Elite', 2, 1200),
('Lenovo Thinkpad', 2, 700),
('Sony VAIO', 2, 700),
('Dell Vostro', 2, 800),
('iPad', 3, 700),
('Kindle Fire', 3, 150),
('Samsung Galaxy Tab', 3, 200);

select * from products;

--Windows Functions:
1. Last_value() by using range to define frame_size
select p.product_name, p.price,
b.group_name,
last_value(p.price) over (partition by b.group_name order by p.price
range between unbounded preceding and unbounded following)
from products p inner join product_groups b
on p.group_id = b.group_id;

2. sum() by using rows to define frame_size
select p.product_name, g.group_name, p.price,
sum(p.price) over (partition by g.group_name order by p.price desc
rows between 1 preceding and 1 following) output  --giving integer is only allowed with ROWS clause
--range between unbounded preceding and unbounded following) output
from products p inner join product_groups g
on p.group_id = g.group_id;

3. ROW_NUMBER()/RANK()/DENSE_RANK() over a partition:
select p.product_name, p.price, g.group_name, row_number() over (order by p.price desc) rn
  from products p inner join product_groups g
       on p.group_id = g.group_id;
	   
4. LEAD()/LAG() Functions to get the value of next/previous values:
select p.product_name, pg.group_name, p.price,
lead(p.price, 1) over (partition by pg.group_name order by p.price) next_price
from products p inner join product_groups pg on p.group_id = pg.group_id;

5. Query to find out the minimum and maximum product details for each group:
select distinct pg.group_name, 
first_value(p.price) over w grp_max_price,
first_value(p.product_id) over w grp_max_product_id,
first_value(p.product_name) over w grp_max_product_name,
last_value(p.price) over w grp_min_price,
last_value(p.product_id) over w grp_min_product_id,
last_value(p.product_name) over w grp_min_product_name
from products p inner join product_groups pg on p.group_id = pg.group_id
window w as (partition by pg.group_name order by p.price desc 
range between unbounded preceding and unbounded following);

--Data Dictionary Queries:
select * from information_schema.columns where table_schema = 'public' and table_name = 'products';
select * from information_schema.tables where table_schema = 'public';

3. Query to retrieve the foreign keys of a table.
SELECT
    tc.table_schema, 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name='products';

4. Views to store the details of constraints:
select * from information_schema.table_constraints where constraint_schema = 'public' and table_name = 'products';
select * from information_schema.key_column_usage;
select * from information_schema.constraint_column_usage;