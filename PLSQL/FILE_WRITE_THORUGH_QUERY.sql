CREATE OR REPLACE PROCEDURE exp_data(
	p_query IN VARCHAR2, p_separator IN VARCHAR2, p_dir IN VARCHAR2,  p_filename IN VARCHAR2 )
 IS
 l_output utl_file.file_type;
 l_theCursor INTEGER DEFAULT dbms_sql.open_cursor;
 l_columnValue VARCHAR2(2000);
 l_status INTEGER;
 l_colCnt NUMBER DEFAULT 0;
 l_descTbl dbms_sql.desc_tab;
 BEGIN
  l_output := utl_file.fopen( p_dir, p_filename, 'W' );
  dbms_sql.parse( l_theCursor, p_query, dbms_sql.native );
  dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );
  
 FOR i IN 1 .. l_colCnt
 LOOP
 dbms_sql.define_column( l_theCursor, i, l_columnValue, 2000 );
 END LOOP;
 
l_status := dbms_sql.execute(l_theCursor);
 
 LOOP 
 EXIT WHEN ( dbms_sql.fetch_rows(l_theCursor) <= 0 );
 FOR i IN 1 .. l_colCnt
 LOOP
 EXIT WHEN (i = l_colCnt);
 dbms_sql.column_value( l_theCursor, i, l_columnValue );
 utl_file.put( l_output, l_columnValue||p_separator);
 END LOOP;
 dbms_sql.column_value( l_theCursor, l_colCnt, l_columnValue );
 utl_file.put_line( l_output, l_columnValue);
 END LOOP;
 
 dbms_sql.close_cursor(l_theCursor);
 utl_file.fclose( l_output );
END exp_data;
/

