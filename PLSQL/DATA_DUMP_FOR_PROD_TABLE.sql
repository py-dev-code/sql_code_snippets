DECLARE
	
	l_query					VARCHAR2(32767);
			
	PROCEDURE EXP_DATA(p_query IN VARCHAR2, p_separator IN VARCHAR2, p_dir IN VARCHAR2,  p_filename IN VARCHAR2)
	IS
		l_output 		UTL_FILE.FILE_TYPE;
		l_theCursor 	INTEGER 			DEFAULT 	DBMS_SQL.OPEN_CURSOR;
		l_columnValue 	VARCHAR2(2000);
		l_status 		INTEGER;
		l_colCnt 		NUMBER 				DEFAULT 	0;
		l_descTbl 		DBMS_SQL.DESC_TAB;

	BEGIN
		
		l_output := UTL_FILE.FOPEN( p_dir, p_filename, 'W' );
		
		UTL_FILE.PUT_LINE (l_output,'Account,Smartcard ID,Product Type,Product Code,Price Code,Action,Date Processed,Status,Retryable,Retries,Notes');
		
		DBMS_SQL.PARSE( l_theCursor, p_query, DBMS_SQL.NATIVE );
		DBMS_SQL.DESCRIBE_COLUMNS( l_theCursor, l_colCnt, l_descTbl );
	  
		FOR i IN 1 .. l_colCnt
		LOOP
			DBMS_SQL.DEFINE_COLUMN( l_theCursor, i, l_columnValue, 2000 );
		END LOOP;
	 
		l_status := DBMS_SQL.EXECUTE(l_theCursor);
	 
		LOOP 
			EXIT WHEN ( dbms_sql.fetch_rows(l_theCursor) <= 0 );
			FOR i IN 1 .. l_colCnt
			LOOP
				EXIT WHEN (i = l_colCnt);
				DBMS_SQL.COLUMN_VALUE( l_theCursor, i, l_columnValue );
				UTL_FILE.PUT( l_output, l_columnValue||p_separator);
			END LOOP;
			DBMS_SQL.COLUMN_VALUE( l_theCursor, l_colCnt, l_columnValue );
			UTL_FILE.PUT_LINE( l_output, l_columnValue);
		END LOOP;
	 
		DBMS_SQL.CLOSE_CURSOR(l_theCursor);
		UTL_FILE.FCLOSE( l_output );
	END EXP_DATA;
	
BEGIN
	
	l_query := 'SELECT FROM_ACCT_NUM, SVC_EVT_PREFIX, SVC_EVT_CD, SMRTCRD_ID, TRANS_DT_TIM, TRANS_REASON_CD, TRANS_AMT, TAX_AMT, TOT_TAX_AMT, TOT_TRANS_AMT,
				BAL_AMT, DELIVERY_METHOD, EVT_DESC, RID, RECEIVER_LOC, REPLACE(HOTEL_NAME,'','',''|'') HOTEL_NAME, CITY, STATE_PROV, STORE_NUM, CREATED_DT, TRANS_TYPE, BILL_CYCLE_DY,
				TO_ACCT_NUM, INVOICE_NUM, INVOICE_DT, FROM_DT, TO_DT, ACCT_BAL_AFT_TN, TRANS_DESC, BILL_DT  FROM TABLE_NAME';
	
	EXP_DATA(l_query, ',', 'WORK_DIR', 'NA_REPORT_DETAILS.CSV');
	
END;
/

DECLARE

	l_na_report_details	TABLE_NAME%ROWTYPE; 
	the_rows 			dtv_utl_file.file_array;
	line_num			NUMBER;

BEGIN
	
	DTV_UTL_FILE.GET_ALL_LINES ('WORK_DIR', 'NA_REPORT_DETAILS.CSV', the_rows, ',');
	
	EXECUTE IMMEDIATE 'TRUNCATE TABLE TABLE_NAME';
	
	line_num := 0;
	
	WHILE (line_num >= 0 AND line_num IS NOT NULL)
	LOOP
	
		INSERT INTO TABLE_NAME VALUES
		(the_rows(line_num)(0),the_rows(line_num)(1),the_rows(line_num)(2),
		the_rows(line_num)(3),the_rows(line_num)(4),the_rows(line_num)(5),
		the_rows(line_num)(6),the_rows(line_num)(7),the_rows(line_num)(8),
		the_rows(line_num)(9),the_rows(line_num)(10),the_rows(line_num)(11),
		the_rows(line_num)(12),the_rows(line_num)(13),the_rows(line_num)(14),
		the_rows(line_num)(15),the_rows(line_num)(16),the_rows(line_num)(17),
		the_rows(line_num)(18),the_rows(line_num)(19),the_rows(line_num)(20),
		the_rows(line_num)(21),the_rows(line_num)(22),the_rows(line_num)(23),
		the_rows(line_num)(24),the_rows(line_num)(25),the_rows(line_num)(26),
		the_rows(line_num)(27),the_rows(line_num)(28),the_rows(line_num)(29)
		);
		
		line_num := the_rows.next(line_num);
	
	END LOOP;
	
	COMMIT;

END;
/