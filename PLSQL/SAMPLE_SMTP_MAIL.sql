declare

	smtp_connection 		UTL_SMTP.CONNECTION;
	host_name      			VARCHAR2(20);
	l_from         			VARCHAR2(200);

BEGIN

	host_name       := SYS_CONTEXT('userenv', 'server_host');
	l_from          := 'from_email';
						   
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
	UTL_SMTP.WRITE_DATA(smtp_connection, 'Mail Body'||UTL_TCP.CRLF);

	UTL_SMTP.CLOSE_DATA(smtp_connection);
	UTL_SMTP.QUIT(smtp_connection);

END;
/