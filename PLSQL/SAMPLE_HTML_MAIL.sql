DECLARE

	smtp_connection 		UTL_SMTP.CONNECTION;
	host_name      			VARCHAR2(20);
	l_from         			VARCHAR2(200);

BEGIN

	host_name       := SYS_CONTEXT('userenv', 'server_host');
	l_from          := 'USERNAME@'||DATABASE_NAME||'.test.com';
						   
	smtp_connection := UTL_SMTP.OPEN_CONNECTION('localhost', 25);
	UTL_SMTP.HELO(smtp_connection, host_name);
	UTL_SMTP.MAIL(smtp_connection, l_From);

	UTL_SMTP.RCPT(smtp_connection, 'email1');
	UTL_SMTP.RCPT(smtp_connection, 'email2');		
		
	--start sending the spam
	UTL_SMTP.OPEN_DATA(smtp_connection);
	UTL_SMTP.WRITE_DATA(smtp_connection,'TO: email1'||UTL_TCP.CRLF);
	UTL_SMTP.WRITE_DATA(smtp_connection,'CC: email2'||UTL_TCP.CRLF);
	UTL_SMTP.WRITE_DATA(smtp_connection,'Subject: Test Email'||UTL_TCP.CRLF);
	     
	utl_smtp.write_data(smtp_connection, 'MIME-Version: 1.0'|| utl_tcp.crlf ||    -- Use MIME mail standard
      'Content-Type: multipart/mixed;'|| utl_tcp.crlf ||
      ' boundary="-----SECBOUND"'|| utl_tcp.crlf ||
      utl_tcp.crlf ||

      '-------SECBOUND'|| utl_tcp.crlf ||
      'Content-Type: text/html;'|| utl_tcp.crlf ||
      'Content-Transfer_Encoding: 7bit'|| utl_tcp.crlf||utl_tcp.crlf);
	UTL_SMTP.WRITE_DATA(smtp_connection, '<html>
   Hello there
   <p>
   This is a <b>HTML</b> formatted e-mail.
   <ul>
           <li>item 1
           <li>item 3
   </ul>
   <p>
   regards, <br>
   PL/SQL Sample Code
   </html>'||UTL_TCP.CRLF);

	UTL_SMTP.CLOSE_DATA(smtp_connection);
	UTL_SMTP.QUIT(smtp_connection);

END;
/