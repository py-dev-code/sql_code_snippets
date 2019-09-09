ALTER TABLE table1
  ADD ( plc_id_fk		  NUMBER(15),
		application_type  VARCHAR2(35),
		created_dt1       DATE,
		created_by1       VARCHAR2(256), 
		updated_dt1       DATE, 
		updated_by1       VARCHAR2(256)
       );

ALTER TABLE table1 disable ALL Triggers;

DECLARE
  CURSOR c1 IS
    SELECT rowid,
           created_dt, 
		   created_by, 
		   updated_dt,
		   updated_by
      FROM table1;
BEGIN
  FOR i IN c1 LOOP
    UPDATE table1
       SET created_dt1 = i.created_dt,
	       created_by1 = i.created_by,
	       updated_dt1 = i.updated_dt,
	       updated_by1 = i.updated_by
     WHERE rowid = i.rowid;
  END LOOP; 
  COMMIT; 
END;
/

ALTER TABLE table1 
 DROP (created_dt, 
	   created_by,
	   updated_dt, 
	   updated_by);

--reverse statements
ALTER TABLE table1 RENAME COLUMN created_dt1 TO created_dt;
ALTER TABLE table1 RENAME COLUMN created_by1 TO created_by;
ALTER TABLE table1 RENAME COLUMN updated_dt1 TO updated_dt;
ALTER TABLE table1 RENAME COLUMN updated_by1 TO updated_by;

ALTER TABLE table1 enable ALL Triggers;