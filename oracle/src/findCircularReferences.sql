set pagesize 500
set linesize 240
set trimspool on
set feedback off
set sqlblanklines on
set verify off
set echo off
set colsep '|'

column source format a30
column target format a30
column path format a140

with fk_pk as (
    select distinct
           pk.owner as pk_schema,
           pk.table_name as pk_table,
           fk.owner as fk_schema,
           fk.table_name as fk_table
    from all_constraints fk
    join all_constraints pk
      on pk.owner = fk.r_owner
     and pk.constraint_name = fk.r_constraint_name
    where fk.constraint_type = 'R'
      and pk.constraint_type in ('P', 'U')
      and fk.owner = user
      and pk.owner = user
      and not (
          pk.owner = fk.owner
          and pk.table_name = fk.table_name
      )
),
relation(
    source_schema,
    source_table,
    pk_schema,
    pk_table,
    fk_schema,
    fk_table,
    path,
    visited_tables
) as (
    select fk_pk.pk_schema as source_schema,
           fk_pk.pk_table as source_table,
           fk_pk.pk_schema,
           fk_pk.pk_table,
           fk_pk.fk_schema,
           fk_pk.fk_table,
           fk_pk.pk_schema || '.' || fk_pk.pk_table || ' > ' || fk_pk.fk_schema || '.' || fk_pk.fk_table as path,
           '|' || fk_pk.pk_schema || '.' || fk_pk.pk_table || '|' || fk_pk.fk_schema || '.' || fk_pk.fk_table || '|' as visited_tables
    from fk_pk
    where exists(
        select 1
        from fk_pk fk_pk_exists
        where fk_pk_exists.pk_schema = fk_pk.pk_schema
          and fk_pk_exists.pk_table = fk_pk.pk_table
          and not (
              fk_pk_exists.fk_schema = fk_pk.fk_schema
              and fk_pk_exists.fk_table = fk_pk.fk_table
          )
    )

    union all

    select relation.source_schema,
           relation.source_table,
           fk_pk_child.pk_schema,
           fk_pk_child.pk_table,
           fk_pk_child.fk_schema,
           fk_pk_child.fk_table,
           relation.path || ' > ' || fk_pk_child.fk_schema || '.' || fk_pk_child.fk_table as path,
           relation.visited_tables || fk_pk_child.fk_schema || '.' || fk_pk_child.fk_table || '|'
    from fk_pk fk_pk_child
    join relation
      on relation.fk_schema = fk_pk_child.pk_schema
     and relation.fk_table = fk_pk_child.pk_table
    where relation.visited_tables not like '%|' || fk_pk_child.fk_schema || '.' || fk_pk_child.fk_table || '|%'
)
select source_schema || '.' || source_table as source,
       fk_schema || '.' || fk_table as target,
       path
from relation
where exists(
    select 1
    from relation relation_exists
    where relation_exists.source_schema = relation.source_schema
      and relation_exists.source_table = relation.source_table
      and not (
          relation_exists.pk_schema = relation.pk_schema
          and relation_exists.pk_table = relation.pk_table
      )
      and relation_exists.fk_schema = relation.fk_schema
      and relation_exists.fk_table = relation.fk_table
)
order by source_schema,
         source_table,
         fk_schema,
         fk_table,
         path;

exit
