-- script does not consider composite PKs !!!
-- thus the column names are ignored in the actual search for circular references
declare	@pathDelim nvarchar(max) = ' -> '

declare @fk_pk table (
	id int not null identity,
	PK_schema sysname not null,
	PK_table sysname not null,
	FK_schema sysname not null,
	FK_table sysname not null,
	num bigint not null
)

insert into @fk_pk(
	PK_schema,
	PK_table,
	FK_schema,
	FK_table,
	num
)
select		distinct
			PK.TABLE_SCHEMA PK_schema,
			PK.TABLE_NAME PK_table,
			FK.TABLE_SCHEMA FK_schema,
			FK.TABLE_NAME FK_table,
			row_number() over (partition by PK.TABLE_NAME order by FK.TABLE_NAME) num
from		INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK
			inner join
			INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
			on C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
			inner join
			INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK
			on C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
where		PK.CONSTRAINT_TYPE = 'PRIMARY KEY'
			and
			-- ignore self-references
			not (
				PK.TABLE_SCHEMA = FK.TABLE_SCHEMA
				and
				PK.TABLE_NAME = FK.TABLE_NAME
			)

;
with relations(
	source_table,
	PK_table,
	FK_table,
	path,
	level,
	hid
) as (
	-- anchor: more then one fk reference these pk tables
	select		fk_pk.PK_table source_table,
				fk_pk.PK_table,
				fk_pk.FK_table,
				cast(fk_pk.PK_table + @pathDelim + fk_pk.FK_table as nvarchar(max)) path,
				0 level,
				cast('/' + cast(fk_pk.num as varchar(30)) + '/' as hierarchyid) hid
	from		@fk_pk fk_pk
	where		exists(
					select		1
					from		@fk_pk fk_pk_exists
					where		fk_pk_exists.id != fk_pk.id
								and
								fk_pk_exists.PK_table = fk_pk.PK_table
				)
	
	union all

	-- recursive
	select		relations.source_table,
				fk_pk_child.PK_table,
				fk_pk_child.FK_table,
				cast(relations.path + @pathDelim + fk_pk_child.FK_table as nvarchar(max)) path,
				relations.level + 1 level,
				cast(relations.hid.ToString() + cast(fk_pk_child.Num as varchar(30)) + '/' as hierarchyid) hid
	from		@fk_pk fk_pk_child
				inner join
				relations
				on	relations.FK_table = fk_pk_child.PK_table
), problems as (
	select		relations.source_table,
				relations.PK_table,
				relations.FK_table,
				relations.level,
				relations.hid
	from		relations
	where		exists(
					select		1
					from		relations relations_exists
					where		relations_exists.PK_table != relations.PK_table
								and
								relations_exists.FK_table = relations.FK_table
								and
								relations_exists.source_table = relations.source_table
				)
), problemTree as (
	select		relations.source_table,
				problems.FK_table problemtable,
				relations.PK_table,
				relations.FK_table,
				relations.path,
				relations.level,
				relations.hid
	from		relations
				inner join
				problems
				on	problems.source_table = relations.source_table
					and
					problems.hid.IsDescendantOf(relations.hid) = 1
)

select		*,
			problemTree.hid.ToString()
from		problemTree
order by	problemTree.source_table,
			problemTree.problemtable,
			problemTree.hid