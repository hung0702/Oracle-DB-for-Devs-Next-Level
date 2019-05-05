--e.g. Use inline view to find the min/max brick_id for each color brick (eh, nty on using inline view. checked, works)

select	colour, min(brick_id), max(brick_id)
from	bricks
group	by colour

/*Can use 'in' and 'exists' interchangeably (for the most part)
	• 'Exists' is much faster when you have many results because it only uses boolean
		• use null instead of * for some performance gain
	• The inverse is true, such that the 'in' clause is much faster when you have few results
		• in will compares values directly rather than using boolean
	• 'In' cannot compare null values, while 'exists can'*/

/*Correlated vs non-correlated subqueries
	• A subquery is non-correlated when it is only executed once and the results passed to the outer query
	• A subquery is correlated when it is executed multiple times, for each row returned by the outer query
		• Commonly used for joins to a table from the parents query
		• Much slower than non-correlated
		• Should consider inner join, which would be faster*/

--e.g. Find rows in bricks table with a color and colours.minimum_bricks_needed = 2 (checked, worked)

select	* from bricks b
where	b.colour in (
	select	colour_name
	from	colours
	where	minimum_bricks_needed = 2
);

/*Scalar subqueries return a single column and zero or one row*/

--e.g. Find the min brick_id for each color (I don't like this method, but w/e; checked, worked)

select	c.colour_name, (
	select	min(brick_id)
	from	bricks
	where   colour = colour_name
	group	by colour
	) min_brick_id
from	colours c
where	c.colour_name is not null;

--A better way to accomplish the above query is below

select	colour_name, min(brick_id)
from	colours left join bricks on (colour = colour_name)
group	by colour_name
order	by min(brick_id)

/*Common Table Expressions allow you to name and reuse subqueries
	• Database can optimize queries accessing the CTE many times*/

--Syntax for CTEs

with	example_CTE as (
	select	*
	from	example_table
)