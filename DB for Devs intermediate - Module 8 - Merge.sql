/*Upserts insert a row if one doesn't currently exist, or updates its values if it already exist
	• Either the insert or update will go unused since only one will occur*/

--Sample upsert syntax

declare
	1_col1	varchar2(10) := '1_value';
	1_col2	varchar2(10) := '2-value';
	1_col3	number(10, 2) := 7;
begin

update	table_1	t1
set		t1.col3 = 1_col3
where	t1.col1 = 1_col1
and		t1.col2 = 1_col2;

	if sql%rowcount = 0 then

		insert into table_1
		values (1_col1, 1_col2, 1_col3);

	end if;

end;
/

select	* from table_1;

/*Merge uses one statement to update or insert as needed
	• Sort of like join syntax
	• Describe match conditions
		• Set the values to change when matched, or what to insert if not matched*/

--Sample merge syntax for new values

merge into target_table t1
using (
	select	'c1_value' col1, 'c2_value' col2, 12 col3
	from	dual	--special Oracle with 1-row DUMMY column, with value x
) tX
on	t1.col1 = tX.col1 and t1.col2 = tX.col2)
when not matched then
	insert (t1.col1, t1.col2, t1.coletc)
	values (tX.col1, tX.col2, tX.coletc)
when matched then
	update set t1.col1 = tX.col1;

--Sample merge syntax for two tables

merge	into target_table t1
using	source_table st		--
on		(t1.col1 = st.col1 and t1.col2 = st.col2)
when not matched then
	insert	(t1.col1, t1.col2, t1.coletc)
	values	(st.col1, st.col2, st.coletc)
when matched then
	update set t1.col1 = st.col1;

--e.g. Complete the merge to add the yellow cube and update the red brick price in purchased_bricks (checked, works)

merge into purchased_bricks pb
using ( 
	select 'yellow' colour, 'cube' shape, 9.99 price from dual 
	union all
	select 'red' colour, 'cube' shape, 5.55 price from dual 
) bfs
on	(pb.colour = bfs.colour and pb.shape = bfs.shape)
when not matched then
	insert	(pb.colour, pb.shape, pb.price)
	values	(bfs.colour, bfs.shape, bfs.price)
when matched then
	update set pb.price = bfs.price;
  
select	* from purchased_bricks
order	by colour, shape;

/*Merges conditions allow updating only columns absent from the join clause or only once per row
	• Cannot update columns present in the join clause
	• Cannot update columns for which multiple source rows can be mapped
	• Use a where clause to set your conditions*/

--Sample syntax for conditional merge

merge	into target_table t1
using	source_table st
on		(t1.col1 = st.col1 and t1.col2 = st.col2)
when not matched then
	insert	(t1.col1, t1.col2, t1.coletc)
	values	(st.col1, st.col2, st.coletc)
	where 	st.col1 = col1_value	--
when matched then
	update set t1.col1 = st.col1;
	where	st.col1 = col1_value;	--

--e.g. Merge to update cubes and insert green rows (checked, works)

merge into purchased_bricks pb
using	bricks_for_sale bfs
on		( pb.colour = bfs.colour and pb.shape = bfs.shape )
when not matched then
  insert	( pb.colour, pb.shape, pb.price )
  values	( bfs.colour, bfs.shape, bfs.price )
  where		bfs.colour = 'green'
when matched then
  update set pb.price = bfs.price
  where		bfs.shape = 'cube';

/*Both the update/insert (i.e. when matched/when not) clauses are optional, so you can just have one or the other (generally bad practice)
	• Where clause requires 'exists' (remember to use select null vs * for efficiency in exists)
	• Update-only merges can be more efficient than update set (multiple table accesses) if the subquery returns the relevant rows

Merge and delete requires a delete clause after the update, only in the update clause*/

--Sample merge + delete syntax

when matched then
	update set t1.col2 = st.col2
	delete where t1.col1 = 'col1_value' --

--e.g. merge then remove rows from purchased_bricks with price <9 (checked; not working!?!!?)

select	* from purchased_bricks;

merge into purchased_bricks pb
using bricks_for_sale bfs
on		( pb.colour = bfs.colour and pb.shape = bfs.shape )
when not matched then
	insert	( pb.colour, pb.shape, pb.price )
	values	( bfs.colour, bfs.shape, bfs.price )
when matched then
	update set pb.price = bfs.price
	delete where pb.price < 9;
  
select * from purchased_bricks;

rollback; WHY DOES THIS NOT WORK!!!!!!!