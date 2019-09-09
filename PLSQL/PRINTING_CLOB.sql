SET SERVEROUTPUT ON SIZE 100000
SET LINESIZE 500

VARIABLE v_buffer CLOB

DECLARE
	--v_buffer CLOB;
	l_line 	VARCHAR2(32767);
BEGIN
	SELECT RESPONSE_XML INTO :v_buffer FROM TABLE_NAME WHERE ID = 876;
	
	while TRUE 
		loop
			IF (DBMS_LOB.INSTR(:v_buffer, CHR(10)) = 0)
			THEN
				EXIT;
			END IF;
			
			l_line:=substr(:v_buffer, 1, instr(:v_buffer, chr(10))-1);
			:v_buffer:=substr(:v_buffer, instr(:v_buffer, chr(10))+1);
			DBMS_OUTPUT.PUT_LINE (l_line);	 
		end loop;
	
		l_line := dbms_lob.substr(:v_buffer, 32767, 1);
		DBMS_OUTPUT.PUT_LINE (l_line); 
END;
/
