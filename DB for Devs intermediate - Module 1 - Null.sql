/*Null is always unknown and is not equal to anything to not equal to anything
	• 'example_attribute = null' and 'example_table != null' do not return null
	• Must use 'is null' to return a null value, or 'is not null' for non-null values
	• Null is not in any ranges (e.g. 'attribute < 0' or 'attribute > 0' do not return null*/

--e.g. Return the tuples for which times_lost is null (checked, works)

select	*
from	toys
where	times_lost is null;

/*Oracles db null functions: NVL & coalesce
	• NVM: takess two argument and returns the first non-null
	• Coalesce: like NVL but takes any number of arguments*/

--Syntax for NVL; returns either a non-null value of example_attribute, or 'NA' if the value is null

select  nvl(example_attribute, 0) "Example Attribute"
from   	example_table;

--Syntax for coalesce

select	egt.*,
		coalesce(example_attr1, 0) coalesce_two,
		coalesce(example_attr2, example_attr3, example_attr4, "NA") coalesce_many
from	example_table egt;

--e.g. Return tuples where times_lost < 5 or null (checked, worked)

select	*
from	toys
where	nvl (times_lost, 0) < 5;

/*Avoid using 'magic values' (e.g. volume = -1) because it causes problems elsewhere
	• You'd have to check for values > 0*/