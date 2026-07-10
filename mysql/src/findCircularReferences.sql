with recursive
fk_pk as (
    select distinct
           kcu.referenced_table_schema as pk_schema,
           kcu.referenced_table_name as pk_table,
           kcu.table_schema as fk_schema,
           kcu.table_name as fk_table
    from information_schema.key_column_usage kcu
    where kcu.referenced_table_schema = database()
      and kcu.table_schema = database()
      and not (
          kcu.referenced_table_schema = kcu.table_schema
          and kcu.referenced_table_name = kcu.table_name
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
           cast(concat(fk_pk.pk_schema, '.', fk_pk.pk_table, ' > ', fk_pk.fk_schema, '.', fk_pk.fk_table) as char(4000)) as path,
           cast(concat('|', fk_pk.pk_schema, '.', fk_pk.pk_table, '|', fk_pk.fk_schema, '.', fk_pk.fk_table, '|') as char(4000)) as visited_tables
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
           cast(concat(relation.path, ' > ', fk_pk_child.fk_schema, '.', fk_pk_child.fk_table) as char(4000)) as path,
           cast(concat(relation.visited_tables, fk_pk_child.fk_schema, '.', fk_pk_child.fk_table, '|') as char(4000)) as visited_tables
    from fk_pk fk_pk_child
    join relation
      on relation.fk_schema = fk_pk_child.pk_schema
     and relation.fk_table = fk_pk_child.pk_table
    where relation.visited_tables not like concat('%|', fk_pk_child.fk_schema, '.', fk_pk_child.fk_table, '|%')
)
select concat(relation.source_schema, '.', relation.source_table) as source,
       concat(relation.fk_schema, '.', relation.fk_table) as target,
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
