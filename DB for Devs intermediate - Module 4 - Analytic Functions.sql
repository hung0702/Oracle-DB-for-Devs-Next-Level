/*List of analytic functions:
	• lag: 1 row preceeding current row
	• lead: 1 row following current row
	• row_number: each row has a new value/number
	• rank: same-value rows have the same rank
	• dense_rank: same as rank, but must be ranked sequentially (no gaps in numbering)
	• first_value: first value in the column
	• last_value: last value up to the current row (usually equal to current row); need to change window clause ending to unbound to get later rows

Analytic functions can only be used in select clause (not where clause), so use subqueries where needed*/

--Syntax and result comparison

select	count(*)
from	example_table;

--returns: Count(*): 6

select	count(*) over ()
from	example_table;

--returns: Count(*): 6, 6, 6, 6, 6, 6

select	ext.*,
		count(*) over () total_count
from	example_table ext;

--returns the whole table with an additional column named total_count and values of 6

/*A partition by clause works like the group by clause
	• Maintains the same number of rows
	• Adds columns with the aggregate values*/

select	ext.*,
		count(*) over (
			partition by col1
		) count_value
		sum (col2) over (
			partition by col1
		) sum_value
from	example_table ext;

--e.g. Return the count and average weight of bricks for each shape (checked; works)

select	b.*, 
		count(*) over (
			partition by shape
		) bricks_per_shape, 
		median ( weight ) over (
			partition by shape
		) median_weight_per_shape
from	bricks b
order	by shape, weight, brick_id;

--Syntax to calculate running totals

select	*,
		count(*) over (
			order by col1
		) running_total
		sum (col2) over (
			order by col1
		) running_col2
from	col2

--e.g. Calculate running average weight, ordered by brick_id

select	b.brick_id, b.weight,
      	round(avg(weight) over (
        	order by brick_id
		), 2 ) running_average_weight
from	bricks b
order	by brick_id;

--Syntax for partition by + order by

select	ext.*,
		count(*) over (
			partition by col1
			order by col2
		) running_total,
		sum(col3) over (
			partition by col1
			order by col2
		) running_col3
from	example_table ext

/*The above example adds 2 columns
	• One for the running total for each group with the same value col1
	• Another for the running total of the entire table*/

/*The windowing clause is automatically added by the database whenever 'order by' is used
	• 'range between unbounded preceding and current row'
	• This means each running total includes all rows with a value less than or equal to the current row
		• This idiosyncrasy can lead to issues when subsequent rows have the same value
		• e.g. same values for col1 - col4, so running total for col1 includes col2, col3, col4*/

--Specify the windowing clause to avoid this situation, so instead of

order	by col1
range	between unbounded preceding and current row

--include this after the order by clause (just change first word)

order	by col1, col2
rows	between unbounded preceding and current row

--This new windowing clause will require additional order by parameters (add another column)

/*Sliding Windows are used to create a subset of previous rows (selective running total)
	• range specifies the actual value range
	• rows only refers to the rows numerical position based on the order*/

--General syntax for sliding window

order	by col1
range	between 1 preceding and 1 following

--Syntax for sliding window that excludes current row

order	col1
range	between between 2 preceding and 1 preceding
--...
order	by col1
range	between 1 following and 2 following

--e.g. Return the min color of the two rows before (but not) the current row,
--		and count of rows with the same weight as the current and one value following

select	b.*, 
		min ( colour ) over (
			order by brick_id
			rows between 2 preceding and 1 preceding
		) first_colour_two_prev, 
		count (*) over (
			order by weight
			range between current row and 1 following
		) count_values_this_and_next
from	bricks b
order	by weight;

/*Filtering analytic functions can by done with partition and/or subqueries
	• Remember that you can't use analytic functions in the where clause*/

--e.g. Query the rows where both the total weight for each shape and the running weight by brick_id are >4 (checked, worked)

with	totals as (
			select b.*,
				sum (weight) over ( 
					order by shape	
				) weight_per_shape,
				sum (weight) over ( 
					order by brick_id
				) running_weight_by_id
			from	bricks b
)
	select	* from totals
	where	weight_per_shape > 4
		and	running_weight_by_id > 4
	order	by brick_id