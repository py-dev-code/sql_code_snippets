CREATE OR REPLACE Procedure MULTI_ATTACH_EMAIL (p_status varchar2) AS

  cursor cur_get_mail_recipient(
      in_mail_status in varchar2)
    is
      select   *
          from table1
         where upper(status) = upper(in_mail_status)
         and recipient_active = 'Y' and job_type = 'JOB_NAME'
      order by recipient_type;

    type recipient_array is table of cur_get_mail_recipient%rowtype
      index by binary_integer;

    l_to            VARCHAR2_ARRAY;
    l_cc            VARCHAR2_ARRAY;
    l_to_mail       varchar2(32767);
    l_cc_mail       varchar2(32767);
    smtp_connection utl_smtp.connection;
    recipients      recipient_array;
    v_mail_subject  varchar2(2000);
    host_name       varchar2(20);
    l_from          varchar2(200);
	-- recipient_index number;
    x               number;
    y               number;
    z               number;
	l_msg1			VARCHAR2_ARRAY;
	l_msg2			VARCHAR2_ARRAY;
  
  begin
    open cur_get_mail_recipient(p_status);

    fetch cur_get_mail_recipient
    bulk collect into recipients;

    close cur_get_mail_recipient;

    y:=0;

    for x in recipients.first..recipients.last
     loop

        if upper(recipients(x).recipient_type) = 'TO'
       then

       l_to(y) := recipients(x).email_address;

       y:= y+1;
       end if;

     end loop;

    z:=0;

    for x in recipients.first..recipients.last
    loop

      if upper(recipients(x).recipient_type) = 'CC'
       then l_cc(z) := recipients(x).email_address;
       z:= z+1;
       end if;

     end loop;

     host_name := Sys_Context('userenv', 'server_host');
     l_from := 'user_name'||database_name||'@directv.com';

     smtp_connection := utl_smtp.open_connection('localhost', 25);

     utl_smtp.helo(smtp_connection, host_name);

     utl_smtp.mail(smtp_connection, l_From);

     For I In 0..L_To.Count-1
     Loop
        Utl_Smtp.Rcpt(smtp_connection, L_To(I));
         If ( L_To_mail Is Null )
          Then
             L_To_mail := 'TO: ' ||L_To(I) ;
           Else
             L_To_mail := L_To_mail || ', ' ||L_To(I);
          End If;
          End Loop;


      For I In 0..l_cc.count-1
     Loop
        Utl_Smtp.Rcpt(smtp_connection, L_cc(I));
         If ( L_cc_mail Is Null )
          Then
             L_cc_mail := 'CC: ' ||L_cc(I) ;
           Else
             L_cc_mail := L_cc_mail || ', ' ||L_cc(I);
          End If;
          End Loop;

		v_mail_subject := 'file TEST1.txt has been loaded with WARNING and ERROR' ;
		
	l_msg1(0) := '111111';	
	l_msg1(1) := 'error1';		
	l_msg1(2) := '222222';	
	l_msg1(3) := 'error2';					
	
	l_msg2(0) := '333333';	
	l_msg2(1) := 'error3';
	l_msg2(2) := '444444';	
	l_msg2(3) := 'error4';		
	
	--start sending the spam
    utl_smtp.open_data(smtp_connection);

    --  utl_smtp.write_data(smtp_connection, 'From: '|| mail.mail_from|| utl_tcp.crlf);
      Utl_Smtp.Write_Data(smtp_connection,L_To_mail||Utl_Tcp.Crlf);
      Utl_Smtp.Write_Data(smtp_connection,l_Cc_mail||Utl_Tcp.Crlf);
      Utl_Smtp.Write_Data(smtp_connection,'Subject: '||v_mail_subject||Utl_Tcp.Crlf);

     
     utl_smtp.write_data(smtp_connection, 'MIME-Version: 1.0'|| utl_tcp.crlf ||    -- Use MIME mail standard
      'Content-Type: multipart/mixed;'|| utl_tcp.crlf ||
      ' boundary="-----SECBOUND"'|| utl_tcp.crlf ||
      utl_tcp.crlf ||

      '-------SECBOUND'|| utl_tcp.crlf ||
      'Content-Type: text/plain;'|| utl_tcp.crlf ||
      'Content-Transfer_Encoding: 7bit'|| utl_tcp.crlf||utl_tcp.crlf);

      utl_smtp.write_data(smtp_connection, 'This is the body.'||utl_tcp.crlf||utl_tcp.crlf);
      utl_smtp.write_data(smtp_connection, 'This is the body second line.'||utl_tcp.crlf||utl_tcp.crlf);

      utl_smtp.write_data(smtp_connection, utl_tcp.crlf||utl_tcp.crlf);

      --1st attachment
	  utl_smtp.write_data(smtp_connection,  '-------SECBOUND'|| utl_tcp.crlf ||
         'Content-Type: text/plain;'|| utl_tcp.crlf ||
      ' name="excel.csv"'|| utl_tcp.crlf ||
      'Content-Transfer_Encoding: 8bit'|| utl_tcp.crlf ||  /*8 bit for attachment*/
      'Content-Disposition: attachment;'|| utl_tcp.crlf ||
      ' filename="Error_Account_Numbers1.csv"'|| utl_tcp.crlf ||   /*attached file name*/
      utl_tcp.crlf ||
      'Acct_Num, ERROR_MESSAGE'||utl_tcp.crlf);          /*column names in excel*/

	 x:= 0;
	 
     while x < l_msg1.count
     loop
        utl_smtp.write_data(smtp_connection,l_msg1(x)||','||l_msg1(x+1)||utl_tcp.crlf); /*column values in excel*/
        x := x+2;
        /*two increments is needed as it is populating two columns simultaneously in attached excel*/
     end loop;
	 
	 --2nd Attachment
	 utl_smtp.write_data(smtp_connection,  '-------SECBOUND'|| utl_tcp.crlf ||
         'Content-Type: text/plain;'|| utl_tcp.crlf ||
      ' name="excel.csv"'|| utl_tcp.crlf ||
      'Content-Transfer_Encoding: 8bit'|| utl_tcp.crlf ||  /*8 bit for attachment*/
      'Content-Disposition: attachment;'|| utl_tcp.crlf ||
      ' filename="Error_Account_Numbers2.csv"'|| utl_tcp.crlf ||   /*attached file name*/
      utl_tcp.crlf ||
      'Acct_Num, ERROR_MESSAGE'||utl_tcp.crlf);          /*column names in excel*/

	 x:= 0;
	 
     while x < l_msg2.count
     loop
        utl_smtp.write_data(smtp_connection,l_msg2(x)||','||l_msg2(x+1)||utl_tcp.crlf); /*column values in excel*/
        x := x+2;
        /*two increments is needed as it is populating two columns simultaneously in attached excel*/
     end loop;
	 
     utl_smtp.write_data(smtp_connection, utl_tcp.crlf
     ||'-------SECBOUND--');    -- End MIME mail

      utl_smtp.close_data(smtp_connection);
      utl_smtp.quit(smtp_connection);

 end;
/