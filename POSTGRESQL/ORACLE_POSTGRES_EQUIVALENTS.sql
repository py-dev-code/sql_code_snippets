1. SYSDATE:
select 'now'::timestamp;

2. DUAL: 
select 'HELLO' || ' WORLD';

3. ROWNUM: ROW_NUMBER() WINDOW FUNCTION
4. ROWID: CTID

5. SEQUENCE: nextval('sequence_name')
6. NVL: coalesce(expr1, expr2, ...)
7. SUBQUERY: same but postgres needs an alias.
8. NULLS: null is null is true in pgres.

9. DATE and NUMBER FORMATTING:
	select id, createddate, to_char(createddate, 'MM/DD/YYYY HH12:MI:SS') MY_DATE from accounts;
	select product_name, to_char(price, '000999.999') from products;
	
10. UNION/INTERSET/UNION ALL: SAME

11. String Manipulations: String index starts with 1.
	select substring('test string' from 1 for 3);  --test
	select substring('test string' from '...$');  --ing
	select position('om' in 'thomas');  --3
	select substring('test string' from position('om' in 'thomas') for position('as' in 'thomas'));  --ing
	select char_length('abc'); --3
	select char_length(trim(' abc '));
	select rpad('12', 5, '0');  --12000
	