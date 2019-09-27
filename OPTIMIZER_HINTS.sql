--1. Index Hint
--Syntax: Just specify Table Alias with Column name for which Index needs to be used.
--Here table1 has a Combinational Unique index defined on both col1 and col2. In hint, we just need to specify its alias and 1 of the index for which index should be --used.

SELECT /*+ INDEX(mas (col1)) */
	   mas.col1, 
	   mas.col2
  FROM table1 	mas
 WHERE mas.col1 = val;
 
