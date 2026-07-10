create temporary table fk_pk(
    pk_schema text not null,
    pk_table text not null,
    fk_schema text not null,
    fk_table text not null
);

insert into fk_pk(
    pk_schema,
    pk_table,
    fk_schema,
    fk_table
)
select distinct
       pk.table_schema as pk_schema,
       pk.table_name as pk_table,
       fk.table_schema as fk_schema,
       fk.table_name as fk_table
from information_schema.table_constraints pk
join information_schema.referential_constraints rc
  on rc.unique_constraint_catalog = pk.constraint_catalog
 and rc.unique_constraint_schema = pk.constraint_schema
 and rc.unique_constraint_name = pk.constraint_name
join information_schema.table_constraints fk
  on rc.constraint_catalog = fk.constraint_catalog
 and rc.constraint_schema = fk.constraint_schema
 and rc.constraint_name = fk.constraint_name
where pk.constraint_type = 'PRIMARY KEY'
  and fk.constraint_type = 'FOREIGN KEY'
  and not (
      pk.table_schema = fk.table_schema
      and pk.table_name = fk.table_name
  );

with recursive relation(
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
           array[fk_pk.pk_schema || '.' || fk_pk.pk_table, fk_pk.fk_schema || '.' || fk_pk.fk_table]::text[] as visited_tables
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
           relation.visited_tables || (fk_pk_child.fk_schema || '.' || fk_pk_child.fk_table)
    from fk_pk fk_pk_child
    join relation
      on relation.fk_schema = fk_pk_child.pk_schema
     and relation.fk_table = fk_pk_child.pk_table
    where not ((fk_pk_child.fk_schema || '.' || fk_pk_child.fk_table) = any(relation.visited_tables))
)
select relation.source_schema || '.' || relation.source_table as source,
       relation.fk_schema || '.' || relation.fk_table as target,
       relation.path
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
order by relation.source_schema,
         relation.source_table,
         relation.fk_schema,
         relation.fk_table,
         relation.path;
