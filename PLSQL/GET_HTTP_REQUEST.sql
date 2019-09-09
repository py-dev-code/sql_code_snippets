/*
  See:
    http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_networkacl_adm.htm
    http://www.oracleflash.com/36/Oracle-11g-Access-Control-List-for-External-Network-Services.html
    http://docs.oracle.com/cd/E16338_01/appdev.112/b56262/d_networkacl_adm.htm (ja)
	http://www.dba-oracle.com/t_advanced_utl_http_package.htm
	*/

1.  cd C:\oraclexe\app\oracle\product\11.2.0\server\rdbms\admin
    $ sqlplus username/password@DB_NAME AS SYSDBA @utlhttp.sql

2. --ACLs to do a GET Request URL:
BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'www.xml', 
    description  => 'WWW ACL',
    principal    => 'SYSTEM',
    is_grant     => TRUE, 
    privilege    => 'connect',
    start_date   => SYSTIMESTAMP,
    end_date     => NULL);

  COMMIT;

  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl => 'www.xml',
    host => 'localhost', 
    lower_port => 25,
    upper_port => 25); 
  COMMIT;
  
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
    acl => 'www.xml', 
    principal => 'SYSTEM', 
    is_grant => TRUE, 
    privilege => 'connect');

  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
    acl => 'www.xml', 
    principal => 'SYSTEM', 
    is_grant => TRUE, 
    privilege => 'connect');

  COMMIT;
END;
/

3. --Create the Table and procedure
CREATE TABLE WWW_DATA (num NUMBER, dat CLOB);

CREATE OR REPLACE PROCEDURE WWW_GET(url VARCHAR2)
IS
    request UTL_HTTP.REQ;
    response UTL_HTTP.RESP;
    n NUMBER;
    buff VARCHAR2(4000);
    clob_buff CLOB;
BEGIN
    UTL_HTTP.SET_RESPONSE_ERROR_CHECK(FALSE);
    request := UTL_HTTP.BEGIN_REQUEST(url, 'GET');
    UTL_HTTP.SET_HEADER(request, 'User-Agent', 'Mozilla/4.0');
    response := UTL_HTTP.GET_RESPONSE(request);
    DBMS_OUTPUT.PUT_LINE('HTTP response status code: ' || response.status_code);

    IF response.status_code = 200 THEN
        BEGIN
            clob_buff := EMPTY_CLOB;
            LOOP
                UTL_HTTP.READ_TEXT(response, buff, LENGTH(buff));
				clob_buff := clob_buff || buff;
            END LOOP;
			UTL_HTTP.END_RESPONSE(response);
			COMMIT;
		EXCEPTION
			WHEN UTL_HTTP.END_OF_BODY THEN
                UTL_HTTP.END_RESPONSE(response);
			WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
                DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
                UTL_HTTP.END_RESPONSE(response);
        END;

		SELECT COUNT(*) + 1 INTO n FROM WWW_DATA;
        INSERT INTO WWW_DATA VALUES (n, clob_buff);
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('ERROR');
        UTL_HTTP.END_RESPONSE(response);
    END IF;
  
END;
/

-- Get GIS Lat Long by passing the Address 
EXEC SYSTEM.WWW_GET('web_service_url');


