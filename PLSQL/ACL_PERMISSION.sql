SELECT * FROM DBA_NETWORK_ACLS;
SELECT * FROM USER_NETWORK_ACL_PRIVILEGES;

BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'localhost_mail.xml', 
    description  => 'ACL for email functionality',
    principal    => 'SCHEMA_NAME',
    is_grant     => TRUE, 
    privilege    => 'connect',
    start_date   => SYSTIMESTAMP,
    end_date     => NULL);

  COMMIT;

  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl => 'localhost_mail.xml',
    host => 'localhost', 
    lower_port => 25,
    upper_port => 25); 
  COMMIT;
  
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
    acl => '/sys/acls/localhost_mail.xml', 
    principal => 'SCHEMA_NAME', 
    is_grant => TRUE, 
    privilege => 'connect');

  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
    acl => '/sys/acls/localhost_mail.xml', 
    principal => 'SCHEMA_NAME', 
    is_grant => TRUE, 
    privilege => 'connect');

  COMMIT;
END;
/

--ACLs to do a GET Request URL:
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