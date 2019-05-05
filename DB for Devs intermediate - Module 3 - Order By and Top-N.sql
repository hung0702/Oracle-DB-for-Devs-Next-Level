/*I have a good foundation for ordering*/

/*Typically nulls are sorted last
	• Can place them first by appending order by clause with 'nulls first'*/

/*Custom sorting requires a case expression in order by clause*/

--Syntax for custom sort

select	*
from	example_table
order	by col1
	when col2 = 'Anything' then 1
	else 2
end, col2;

--Syntax for positional notation (easy with smaller tables but not best practices)

select	ext.*,
		case
			when col1 = 'Anything' then 1
			else 2
		end
from	example_table ext
order	by 6, 1;			--orders by the col6, then by col1

/*Better practice to use aliases, which you append to the end of the case expression*/

--Syntax for alias

select	ext.*,
		case
			when col1 = 'Anything' then 1
			else 2
		end custom_sort
from	example_table ext
order	by custom_sort, col1;

--e.g. Sort such that Kangaroo 1st, Blue Dinosaur is second, and everything else price asc

select t.toy_name, t.price,
       case
         when toy_name = 'Kangaroo' then 1
         when toy_name = 'Blue Dinosaur' then 2
         else 3
       end custom_sort
from   toys t
order  by custom_sort, price asc;

/*Rownum is Oracle-specific, assigning ascending numbers to each row, then returning the row numbers
	• If used with order by, you need a subquery for rownum to act as expected

Row_number is an analytic function used like rownum, but requires an over clause*/

--Syntax for rownum

select	*
from	(
	select	*
	from	example_table
	order	by col1
)
where rownum >= 2;

--Syntax for row_number

select	*
from	(
	select ext.*, row_number() over (order by col1) rn
	from	example_table ext
)
where	rn >= 2
order	by rn;

/*Fetch first was introduced in Oracle db 12c, but is ANSI compliant
	• Goes after order by clause but doesn't require a subquery*/

--Syntax for fetch first

select	*
from	example_table
order	by col1
fetch	first 2 rows only;

--Note: can replace 'rows only' with 'with ties' to return at least the specified number of rows that match the conditions

/*Dense_rank is like fetch first with ties*/

--Syntax for dense_rank

select	*
from	(
	select	ext.*, 
    	dense_rank() over (order by price desc) rn
	from	example_table ext
)
where	rn <= 3
order	by rn;

--e.g. Query for the first 3 toys, ordered by toy_name (used fetch first; checked, worked)

select	toy_name
from	toys
order	by toy_name
fetch	first 3 rows only;

--alternative way to achieve above query (used rownum; checked, worked)

select	toy_name
from	(
	select	*
	from	toys
	order	by toy_name
)
where rownum <= 3;

--alternative way to achieve above query (used row_number; checked, worked)

select	toy_name
from	(
	select t.*, row_number() over (order by toy_name) rn
	from	toys t
)
where	rn <= 3
order	by rn;

--Other ways: custom sort, positional notation, alias