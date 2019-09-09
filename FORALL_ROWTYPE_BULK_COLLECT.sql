CREATE TABLE test1 (col1 NUMBER);
CREATE TABLE test2 (col1 NUMBER);

DECLARE
    CURSOR test_c IS
    SELECT 1 col1 FROM dual 
    UNION 
    SELECT 2 FROM dual;    
    TYPE test_coll IS TABLE OF test_c%ROWTYPE INDEX BY PLS_INTEGER;
    tab1 test_coll;    
BEGIN
    OPEN test_c;
    FETCH test_c BULK COLLECT INTO tab1;
    dbms_output.put_line(tab1.COUNT);
    
    FORALL i IN 1 .. tab1.COUNT
        INSERT INTO test1 VALUES(tab1(i).col1);
    FORALL i IN 1 .. tab1.COUNT
        INSERT INTO test2 
        SELECT tab1(i).col1 FROM dual
        WHERE tab1(i).col1 = 1;        
END;
/

DROP TABLE test1;
DROP TABLE test2;