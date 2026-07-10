whenever sqlerror exit sql.sqlcode

declare
    user_missing exception;
    pragma exception_init(user_missing, -1918);
begin
    execute immediate 'drop user CIRCREF cascade';
exception
    when user_missing then null;
end;
/

create user CIRCREF identified by CIRCREF;
grant create session, create table, create sequence, unlimited tablespace to CIRCREF;

exit
