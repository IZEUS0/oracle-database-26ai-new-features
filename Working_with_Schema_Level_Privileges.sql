/* ===============================================================
   Author:      Ollear Mena 
   Company:     ELITEDATA 
   Script:      Working_with_Schema_Level_Privileges.sql  
   Lab Title:   Working with Schema-Level Privileges in Oracle Database 26ai  
   Description: Demonstrates how to grant, revoke, and manage schema-level 
                privileges in Oracle 26ai, including user creation, 
                privilege verification, and security testing.  
   References:  https://docs.oracle.com/en/database/oracle/oracle-database/26/dbseg/
   Version:     1.0  
   Date:        SYSDATE  
   =============================================================== */

drop user if exists bob cascade;
drop user if exists sally cascade;
create user bob identified by Oracle123long;
create user sally identified by Oracle123long;

-- tables, views, and materialized views
grant select any table on schema sally to bob;
grant insert any table on schema sally to bob;
grant update any table on schema sally to bob;
grant delete any table on schema sally to bob;

-- procedures, functions, packages, and sequences
grant execute any procedure on schema sally to bob;
grant select any sequence on schema sally to bob;

SELECT * FROM DBA_SCHEMA_PRIVS WHERE GRANTEE = 'BOB';

-- tables, views, and materialized views
revoke select any table on schema sally from bob;
revoke insert any table on schema sally from bob;
revoke update any table on schema sally from bob;
revoke delete any table on schema sally from bob;

-- procedures, functions, packages, and sequences
revoke execute any procedure on schema sally from bob;
revoke select any sequence on schema sally from bob;

drop user if exists bob cascade;
drop user if exists sally cascade;

--Granting the Developer Role
--To check all of the system privileges, object privileges, and roles granted by the Developer Role, run the following PL/SQL script
set serveroutput on format wrapped;
DECLARE
    procedure printRolePrivileges(
      p_role             in varchar2,
      p_spaces_to_indent in number) IS
      v_child_roles   DBMS_SQL.VARCHAR2_TABLE;
      v_system_privs  DBMS_SQL.VARCHAR2_TABLE;
      v_table_privs   DBMS_SQL.VARCHAR2_TABLE;
      v_indent_spaces varchar2(2048);
    BEGIN
      -- Indentation for nested privileges via granted roles.
      for space in 1..p_spaces_to_indent LOOP
        v_indent_spaces := v_indent_spaces || ' ';
      end LOOP;
      -- Get the system privileges granted to p_role
      select PRIVILEGE bulk collect into v_system_privs
      from DBA_SYS_PRIVS
      where GRANTEE = p_role
      order by PRIVILEGE;

      -- Print the system privileges granted to p_role
      for privind in 1..v_system_privs.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
          v_indent_spaces || 'System priv: ' || v_system_privs(privind));
      END LOOP;

      -- Get the object privileges granted to p_role
      select PRIVILEGE || ' ' || OWNER || '.' || TABLE_NAME
        bulk collect into v_table_privs
      from DBA_TAB_PRIVS
      where GRANTEE = p_role
      order by TABLE_NAME asc;

      -- Print the object privileges granted to p_role
      for tabprivind in 1..v_table_privs.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
          v_indent_spaces || 'Object priv: ' || v_table_privs(tabprivind));
      END LOOP;

      -- get all roles granted to p_role
      select GRANTED_ROLE bulk collect into v_child_roles
      from DBA_ROLE_PRIVS
      where GRANTEE = p_role
      order by GRANTED_ROLE asc;

      -- Print all roles granted to p_role and handle child roles recursively.
      for roleind in 1..v_child_roles.COUNT LOOP
        -- Print child role
        DBMS_OUTPUT.PUT_LINE(
         v_indent_spaces || 'Role priv: ' || v_child_roles(roleind));

        -- Print privileges for the child role recursively. Pass 2 additional
        -- spaces to illustrate these privileges belong to a child role.
        printRolePrivileges(v_child_roles(roleind), p_spaces_to_indent + 2);
      END LOOP;

      EXCEPTION
        when OTHERS then
          DBMS_OUTPUT.PUT_LINE('Got exception: ' || SQLERRM );

    END printRolePrivileges;

BEGIN
    printRolePrivileges('DB_DEVELOPER_ROLE', 0);
END;
/

DROP USER IF EXISTS OLLEAR CASCADE;
CREATE USER OLLEAR IDENTIFIED BY Oracle123_long;
SELECT GRANTED_ROLE FROM DBA_ROLE_PRIVS WHERE GRANTEE='OLLEAR';

GRANT DB_DEVELOPER_ROLE TO ollear;
SELECT GRANTED_ROLE FROM DBA_ROLE_PRIVS WHERE GRANTEE='OLLEAR';

REVOKE DB_DEVELOPER_ROLE FROM OLLEAR;
SELECT GRANTED_ROLE FROM DBA_ROLE_PRIVS WHERE GRANTEE='OLLEAR';

drop user IF EXISTS ollear CASCADE;



