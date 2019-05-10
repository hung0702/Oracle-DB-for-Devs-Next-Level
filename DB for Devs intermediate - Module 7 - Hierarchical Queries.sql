/*Hierarchical queries travel along parent-child relationships in data, such as directories and charts

Connect by is an Oracle-specific way to create data trees using two clauses: 'start with' and 'connect by'
	• 'start with' defines the top of the tree
	• 'connect by' defines the relationship between two rows*/

--Example syntax for 'start with' 'connect by'

select	col1, col2, col3, col4, col5
from	example_table
start	with col2 is value_in_rowX_col2
connect	by prior col1 = col2;

--e.g. Complete the query to build an inverted org chart beginning with employee 107 and going up the chain
	--(checked, works)

select	employee_id, first_name, last_name, manager_id
from	employees
start	with employee_id = '107'
connect	by prior manager_id = employee_id;

/*Recursive subquery factoring requires a base query and recursive query, and a recursive 'with' clause
	• The base query defines the root rows
	• The recursive query links the parent-child columns/values
	• The base query and recursive query can be union alled to get the desired result*/

--Sample syntax

with	table_A (
	col1, col2, col3, col4
) as (
	select	col1, col2, col3, col4 
	from	table_1
	where	col4 is null
	union	all
	select	t1.col1, t1.col2, t1.last_name, t1.col4 
	from	table_A tA
	join	table_1 t1
	on	t1.col4 = tA.col1
)
	select	* from table_A;

--Build reverse org chart like before, but use recursive with; start with employee_id 107, end with CEO
	--(checked, works)

with	org_chart (
	employee_id, first_name, last_name, manager_id
) as (
	select	employee_id, first_name, last_name, manager_id 
	from	employees
	where	employee_id = 107
	union	all
	select	e.employee_id, e.first_name, e.last_name, e.manager_id 
	from	org_chart oc
	join	employees e
	on		oc.manager_id = e.employee_id
)
	select	* from org_chart;

/*Use 'level' in the select clause to list the depth (distance from root, starting with 1)
	• use 'lpad' (LPAD) to add indentations based on level*/

--Sample level and lpad syntax

select	level, col1,
		lpad (' ', level, ' ') || col2 || ' ' || col3, col4
from	table_A
start	with col4 is null
connect	by prior col1 = col4;

/*Recursive with lacks a built-in 'level', but make a column that replicates this functionality*/

--Sample recursive with syntax to replicate 'level'

with	table_A (
	col1, col2, col3, col4, lvl		--
) as (
	select	col1, col2, col3, col4, 1 lvl		--
	from	table_1
	where	col4 is null
	union	all
	select	t1.col1, t1.col2, t1.last_name, t1.col4, tA.lvl + 1		--
	from	table_A tA
	join	table_1 t1
	on	t1.col4 = tA.col1
)
	select	* from table_A;

/*Can sort the result other than by hierarchy alone
	• add 'order siblings by' clause will order by the column, then the hierarchy*/

--Sample syntax

select	level, col1, col2, col3, col4, col5 
from	table_1
start	with col4 is null
connect	by prior col1 = col4
order	siblings by col5;

/*Can sort the result for recursive with expressions, either column-first (depth) or the hierarchy-first (breadth)
	• Requires 'search' clause, which contains the column to sort by
	• Use 'depth' to search down each child's child before going to the next column
	• Use 'breadth' to search across each column before going down a hierarchy*/

--Sample syntax for sorting recursive with, depth-first
	--Replace 'depth' with 'breadth' to sort by column-first

with	table_A (
	col1, col2, col3, col4, lvl		--
) as (
	select	col1, col2, col3, col4, 1 lvl		--
	from	table_1
	where	col4 is null
	union	all
	select	t1.col1, t1.col2, t1.col3, t1.col4, tA.lvl + 1		--
	from	table_A tA
	join	table_1 t1
	on	t1.col4 = tA.col1
)
	search	depth first by col5 set col5_order		--col5_order is like rank
	select	* from table_A

/*Result for above search would look like
	• Depth: ordered by col5, showing all childs before moving onto next highest unvisited child
	• Breadth: order strictly by hierarchy, with each hierarchy sorted by col5*/

--e.g. Order employees depth-first by manager_id (checked, works)

select	level, employee_id, first_name, last_name, hire_date, manager_id 
from	employees
start	with manager_id is null
connect	by prior employee_id = manager_id
order	siblings by manager_id, first_name;

/*Structures containing loops will lead to errors
	• Resolve this by adding nocycle to the connect by clause
	• In recursive loops, add a cycle clause
		• Will cause revisited rows to appear twice
		• Resolve by filtering out in final where clause using the defined loop column*/

--Sample connect by nocycle syntax

select	*
from	table_1
start	with col1 = 1
connect	by nocycle prior col1 = col4;	--

--Sample cycle clause syntax for recursive with queries

with	table_A (
	col1, col2, col3, col4
) as (
	select	col1, col2, col3, col4 
	from	table_1
	where	col4 is null
	union	all
	select	t1.col1, t1.col2, t1.last_name, t1.col4 
	from	table_A tA
	join	table_1 t1
	on	t1.col4 = tA.col1
)	cycle col1 set looped to 'Y' default 'N'	--'looped' names the column
	select	* from table_A;

--e.g. Define the cycle column is_repeat defaulting to N, and when accessing the job_id set to Y

with	org_chart (
	employee_id, first_name, last_name, manager_id, job_id
) as (
	select	employee_id, first_name, last_name, manager_id , job_id
	from	employees
	where	employee_id = 102
	union	all
	select	e.employee_id, e.first_name, e.last_name, e.manager_id, e.job_id
	from	org_chart oc
	join	employees e
	on		e.manager_id = oc.employee_id
) cycle		job_id set is_repeat to 'Y' default 'N'		--
	select	* from org_chart;

/*Display tree details in connect by queries using level
	• Returns information about how rows relate to each other
	• Use connect_by_root, sys_connect_by_path, and connect_by_isleaf

Connect_by_root: returns value of column from the root row
	• i.e. First value of tree, of the column defined

Sys_connect_by_path: returns the rows between the root and current row
	• Builds a string with value from first argument for the current row to the end of a list
		• Separated by the second argument
	• i.e. Follows the tree from root to the current row, returning a string
		• String is defined by the first argument, values are separated by the characters defined in second argument

Connect_by_isleaf: identifies leaf rows, which are returned as 1; otherwise 0*/

--Sample syntax containing all three operators for tree details

select col1, col2, col3, col4,
       connect_by_root col3,
       sys_connect_by_path ( col3, ', ') col_example, --name col_example something that makes sense, like chart
       connect_by_isleaf is_leaf
from   table_1
start with col4 is null
connect by prior col1 = col4;

/*Recursive with doesn't have built-in tree detail options, but that functionality can be replicated

Equivalent to connect_by_root: select the root value in the base query and return this column from the with clause name

Equivalent to sys_connect_by_path: select the root value in the base query, return the values added with a separator

Equivalent to connect_by_isleaf: add depth and sort depth-first, then check if the next row has a level >= current row*/

--Sample syntax for retrieving tree details with recursive with queries

with	table_A (
	col1, col2, col3, col4, root_value, chart, lvl
) as (
	select	col1, col2, col3 root_value, col3 chart, col4, 1 lvl
	from	table_1
	where	col4 is null
	union	all
	select	t1.col1, t1.col2, t1.col3, t1.col4, tA.root_value, tA.chart || ', ' || t1.col3, tA.lvl + 1
	from	table_A tA
	join	table_1 t1
	on	t1.col4 = tA.col1
)
	search	depth first by col1 set seq_value
	select	tA.*,
			case
				when lead (lvl, 1, 1) over (order by seq_value) <= lvl then 'LEAF'
				end is_leaf
	from	table_A tA;