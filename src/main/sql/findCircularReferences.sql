-- variables for the path output
declare	@delimList nvarchar(max) = ' > ',
		@delimDot nvarchar(max) = '.'

/* Part 1: read all fk-pk relation
does not perform well in SQL Server with a CTE, thus using a temp table */
create table #fk_pk(
	PK_schema sysname not null,
	PK_table sysname not null,
	FK_schema sysname not null,
	FK_table sysname not null
)

insert into #fk_pk(
	PK_schema,
	PK_table,
	FK_schema,
	FK_table
)
select		distinct
			PK.TABLE_SCHEMA PK_schema,
			PK.TABLE_NAME PK_table,
			FK.TABLE_SCHEMA FK_schema,
			FK.TABLE_NAME FK_table
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
with relation(
	sourceSchema,
	sourceTable,
	PK_schema,
	PK_table,
	FK_schema,
	FK_table,
	path
) as (
	/* Part 2: Find PKs that are referenced more then once (reduces workload for next step) */
	-- anchor: more then one fk reference these pk tables
	select		fk_pk.PK_schema sourceSchema,
				fk_pk.PK_table sourceTable,
				fk_pk.PK_schema,
				fk_pk.PK_table,
				fk_pk.FK_schema,
				fk_pk.FK_table,
				cast(fk_pk.PK_schema as nvarchar(max)) + @delimDot + fk_pk.PK_table + @delimList + fk_pk.FK_schema + @delimDot +  fk_pk.FK_table path
	from		#fk_pk fk_pk
	where		exists(
					select		1
					from		#fk_pk fk_pk_exists
					where		fk_pk_exists.PK_schema = fk_pk.PK_schema
								and
								fk_pk_exists.PK_table = fk_pk.PK_table
								and
								not (
									fk_pk_exists.FK_schema = fk_pk.FK_schema
									and
									fk_pk_exists.FK_table = fk_pk.FK_table
								)
				)
	
	/* Part 3: Find all possible paths from those PK tables to any other table (using recursive CTE) */
	union all

	-- recursive
	select		relation.sourceSchema,
				relation.sourceTable,
				fk_pk_child.PK_schema,
				fk_pk_child.PK_table,
				fk_pk_child.FK_schema,
				fk_pk_child.FK_table,
				/* Part 5: Display result nicely
				compose a path like: A -> B -> C */
				relation.path + @delimList + fk_pk_child.FK_schema + @delimDot + fk_pk_child.FK_table path
	from		#fk_pk fk_pk_child
				inner join
				relation
				on	relation.FK_schema = fk_pk_child.PK_schema
					and
					relation.FK_table = fk_pk_child.PK_table
)

/* Part 4: Identify problematic circles */
select		relation.sourceSchema + @delimDot + relation.sourceTable source,
			relation.FK_schema + @delimDot + relation.FK_table target,
			relation.path
from		relation
where		exists(
				select		1
				from		relation relation_exists
				where		relation_exists.sourceSchema = relation.sourceSchema
							and
							relation_exists.sourceTable = relation.sourceTable
							and
							not (
								relation_exists.PK_schema = relation.PK_schema
								and
								relation_exists.PK_table = relation.PK_table
							)
							and
							relation_exists.FK_schema = relation.FK_schema
							and
							relation_exists.FK_table = relation.FK_table
								
			)
order by	relation.sourceSchema,
			relation.sourceTable,
			relation.FK_schema,
			relation.FK_table,
			relation.path

drop table #fk_pk
go