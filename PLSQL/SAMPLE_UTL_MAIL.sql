begin
    execute immediate 'alter session set smtp_out_server=''127.0.0.1''';
    utl_mail.send(
      sender=>	'from_email', 
      recipients=>'email1, email2',
      subject=>'Test Email',
      message=>'Email Message',
      mime_type=>'text; charset=us-ascii'
    );
end;
/