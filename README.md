# Find circular references by SQL
This is a circular reference:
![Circular Reference](https://github.com/Wuodan/sql_circular_references/blob/master/doc/img/circref_project_detail.png)
There are 2 paths from ProjectAssignment to Project, leading to potentially different results!
* ProjectAssignment -> Task -> Project
* ProjectAssignment -> ProjectTeam -> Project

## Quick steps
### For MS SQL server:
1. Run the script [SQL-Find-Circular-References/src/main/sql/findCircularReferences.sql](findCircularReferences.sql) 
1. You should get a list of circular references like this:
![Results for Project picture](https://github.com/Wuodan/SQL-Find-Circular-References/blob/master/doc/img/resultProject.png)
### Other RDBMS
1. Modify [Part 1](https://github.com/Wuodan/SQL-Find-Circular-References/wiki#part-1-list-all-pk-fk-relations) in the script. Write a query which lists all PK-FK relations in your DB.
1. Change the few SQL Server specific things like datatypes
1. Run your script
1. Send me a pull-request!!! :-)

## Further reading
* [Code explained](#code-explained): Step by step through the query
* [Circular references](#circular-references): What are they? Why does this work?
* [Test Data](#test-data): A sample database with circular references

# Circular references
## Types of Circular References
There are 3 types of circular references that come to my mind:
1. True circles, endless loop: A -> B -> C -> A

Welcome to a chicken-egg situation and good luck entering data! These will be detected soon, so let's not worry about them.

2. Self-references, parent-child

These are unproblematic. If parent=null marks root nodes, then just add a check-constraint to ensure that the parent-id is not the child-id itself.

3. Multi-table circular-references

These are the ones that we want to detect!

Here's another example:
![Example Detail Household](https://github.com/Wuodan/sql_circular_references/blob/master/doc/img/circref_household_detail.png)

## Characteristics of circular references
What identifies such circular references?
* Primary key referenced more then once

One element of such circles is a table, whose primary key is referenced by more then one other table.
* Foreign key to more then one table

On the other side of the circle is a table with FK references to more then one table.
* Several chains of PK-FK relations between those 2 tables
There is more then one path from the first to the second table.

# Code explained
So the question is: can we find such circular references by script?
Let's try ..

## Code steps
1. List all PK-FK relations
1. Find PKs that are referenced more then once (reduces workload for next step)
1. Find all possible paths from those PK tables to any other table (using recursive CTE)
1. Identify problematic circles
1. Display result nicely as paths

## Part 1: List all PK-FK relations
Query all PK-FK relations to get a result like this:

![List of PK-FK](https://github.com/Wuodan/SQL-Find-Circular-References/blob/master/doc/img/listPK-FK.png)

and store it in a temp-table named #fk_pk.
(Filter out self-references with source = target table)

For SQL Server:
```
select      distinct
            PK.TABLE_SCHEMA PK_schema,
            PK.TABLE_NAME PK_table,
            FK.TABLE_SCHEMA FK_schema,
            FK.TABLE_NAME FK_table
from        INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK
            inner join
            INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
            on C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
            inner join
            INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK
            on C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
where       PK.CONSTRAINT_TYPE = 'PRIMARY KEY'
            and
            -- ignore self-references
            not (
                PK.TABLE_SCHEMA = FK.TABLE_SCHEMA
                and
                PK.TABLE_NAME = FK.TABLE_NAME
            )
```
## Part 2: Find PKs that are referenced more then once
Straightforward:
```
select      [columns]
from        #fk_pk fk_pk
where       exists(
                select      1
                from        #fk_pk fk_pk_exists
                where       fk_pk_exists.PK_schema = fk_pk.PK_schema
                            and
                            fk_pk_exists.PK_table = fk_pk.PK_table
                            and
                            not (
                                fk_pk_exists.FK_schema = fk_pk.FK_schema
                                and
                                fk_pk_exists.FK_table = fk_pk.FK_table
                            )
            )
```
## Part 3: Find all possible paths from those PK tables to any other table (using recursive CTE)
With part 2 as anchor a recursive CTE can track all paths leading away from the anchor tables.
```
;
with relation( [columns] ) as (
    /* Part 2: anchor tables */
    select      [columns]
    from        #fk_pk fk_pk
    where        exists(
                    select      1
                    from        #fk_pk fk_pk_exists
                    where       fk_pk_exists.PK_schema = fk_pk.PK_schema
                                and
                                fk_pk_exists.PK_table = fk_pk.PK_table
                                and
                                not (
                                    fk_pk_exists.FK_schema = fk_pk.FK_schema
                                    and
                                    fk_pk_exists.FK_table = fk_pk.FK_table
                                )
                )
    
    /* Part 3: Find all possible paths from those PK tables to any other table */
    union all

    -- recursive
    select      [columns]
    from        #fk_pk fk_pk_child
                inner join
                relation
                on  relation.FK_schema = fk_pk_child.PK_schema
                    and
                    relation.FK_table = fk_pk_child.PK_table
)
```
## Part 4: Identify problematic circles
From the relations in part 3, find start-end combinations that occur more then once.
````
select      [columns]
from        relation
where        exists(
                select      1
                from        relation relation_exists
                where       relation_exists.sourceSchema = relation.sourceSchema
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
order by    [columns]
````
## Part 5: Display result nicely as paths
The recursive CTE is going through all those paths, so we can construct the paths easily in the select clauses there.
For Anchor:
```
select      [columns],
            PK_schema + '.' + PK_table + ' > ' + FK_schema + '.' +  FK_table path
```
For the recursion
```
select      [columns],
            relation.path + ' > ' + fk_pk_child.FK_schema + '.' + fk_pk_child.FK_table path
```

# Test Data
You can create a test-database with some circular references using the scripts in [src/test/sql](https://github.com/Wuodan/SQL-Find-Circular-References/tree/master/src/test/sql).


That's it. Please let me know about bugs or your version!
