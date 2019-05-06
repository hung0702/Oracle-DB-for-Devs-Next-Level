/*(Not) exists vs set operators
	• Pick whatever works best
	• Exists doesn't recognize that nulls can be equal; requires additional filter
	• Set operators all have an implicit distinct (omits duplicates after operation)

/*Union joins two tables that have the same number of columns, so the result has tuples from both
	• Removes duplicates if not using 'union all' (implicit distinct after operation)
	• Combine with distinct to get unique values from each table
		• Combine further with 'union all' to get unique values from each table without omitting those that appear in both table*/

--Syntax for union all with distinct values from each tables, without omitting shared values

select	distinct *
from	table1
union	all
select	distinct *
from	table2;

--e.g. Return list of all colors in both tables, omit duplicates (checked, works)

select	colour
from	my_brick_collection
union	
select	colour
from	your_brick_collection
order	by colour;

--e.g. Return list of all shapes in both tables, keeping all duplicates (checked, works)

select	shape
from	my_brick_collection
union	all
select	shape
from	your_brick_collection
order	by shape;

/*Set difference is not an operator per se
	• Perform with 'not exists', but problematic with null since null != null
		• Rectify by adding a filtering condition for null*/

--Syntax for set difference using not exists

select	col1, col2
from	example_table ext
where	not exists (
	select	null from table_example tex
	where	(ext.col1 = tex.col1 or 
			(ext.col1 is null and tex.col1 is null) 
			)
	and		(ext.col2 = tex.col2 or
			(ext.col2 is null and tex.col2 is null) 
	)
);

/*Minus returns values present in the first set but not the second (order matters)
	• Implicit distinct after operation so duplicates omitted
	• Can include omitted duplicates with not exists*/

/*Intersect finds common values and correctly recognizes nulls as equal
	• Exists achieves the same thing but includes duplicates and ignores nulls*/

--e.g. Return list of all shapes in my collection not in yours (checked, works)

select	shape from my_brick_collection
minus
select	shape from your_brick_collection;

--e.g. Return list of all colours in both tables

select	colour from my_brick_collection
intersect
select	colour from your_brick_collection
order	by colour;

/*Symmetric difference: returns all rows not shared by both tables (not an operator)
	• Can just minus one way then union with minus the other way (order) 'round*/

/*Symmetric difference with group by
	• Useful to determine exact quantities of share or unshared values
		• Can return shared tuples with disparate values*/

--Sample syntax (can have many different implementations)

select	col1, col2, sum(table1), sum(table2) 
from	(
	select	col1, col2, 1 table1, 0 table2	--returns 1|0 for each column for each table, to sum later
	from	table1
	union	all
	select	col1, col2, 0 table1, 1 table2	--needs both tables for parity when unioning
	from	table2
)
group	by col1, col2
having	sum(table2) != sum(table1);