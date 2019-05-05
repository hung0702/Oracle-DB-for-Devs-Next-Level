/*Pivot clause requires three things
	• values to go into columns
	• column containing the values to become new columns
	• list of values to become columns*/

--General syntax for pivot clause

pivot (
	aggregate(val_each_new_col) for target_of_agreggate in (
		'new_col1', 'new_col2', 'new_coletc'
	)
)

--e.g. Show locations as columns with date of last match played at each (checked, works)

with	rws as (
	select	location, match_date from match_results
)
	select	* from rws
pivot (
	max(match_date) for location in (
		'Snowley', 'Coldgate', 'Dorwall', 'Newdell' 
	)
);

--e.g. Show team names as columns with number of home games each played (checked, works)

with	rws as (
	select	home_team_name from match_results
)
	select	* from rws
pivot (
	count (*) for home_team_name in (
		'Underrated United', 'Average Athletic', 'Terrible Town', 'Champions City'
	)
);

/*Implicit group by clause formed by input columns that specified in the pivot table
	• Can lead to more output rows than expected
	• Resolve by using inline view or CTE to select only the columns to be pivoted*/

/*Can use expressions to manipulate values to be pivoted
	• Can also use filtering in the outer query's where clause
	• Rename columns by adding the new title next to the quoted title of the pivot's in clause*/

--e.g.	Show the number of games played at each location on each day of the week
	--Use the three letter day abbr. for each column (without quotes)
	--And which locations had >=1 games on monday (checked, works)

with	rws as (	--use CTE to bulk convert match_date to a day abbr.
	select	location,
		to_char ( match_date, 'DY' ) match_day --DY converts the input match_date to a day abbreviation
	from	match_results
)
select	* 
from rws
pivot (
	count (*) for match_day in (
      'MON' mon, 'TUE' tue, 'WED' wed, 'THU' thu, 'FRI' fri, 'SAT' sat, 'SUN' sun
      --converted each day column to abbr. day and removed quotations
	)
)
where	mon >= 1	--filter only locations that had >= 1 game played in Monday column
order	by location;

--e.g. For each location show:
	--number of games played
	--total points scored by both teams
	--title columns by team name and suffix _matches and _points (checked, works)

with	rws as (
	select	location, home_team_points, away_team_points
	from	match_results
)
select	* from rws
pivot (
	count(*) matches,	--how many games played at each location, rename column to append each location name
	sum(home_team_points + away_team_points) points 	--total points scored for all games played at each location, rename column to append each location name
	for location in (
		'Snowley' snowley, 'Coldgate' coldgate, 'Dorwall' dorwall, 'Newdell' newdell
		--rename columns so the quotations are removed
	)
);

/*SQL does not allow dynamic pivoting (i.e. cannot use DML to change input columns)
	• One workaround is to export to XML and use that result to generate end user content*/

/*Unpivoting takes columns and converts them to rows
	• One approach is to union all
	• Or, use unpivot clause (req Oracle db +11g)*/

--Syntax for unpivot clause

unpivot	(
	team for pivoted_col1 in ( 
		new_col1 as 'col1', new_col2 as 'col2'
	)
)

--e.g. Unpivot the home and away points for each match (checked, works)

select	match_date, location, home_or_away, points 
from	match_results
unpivot (
	points for home_or_away in ( --points becomes the new column
		home_team_points as 'HOME', away_team_points as 'AWAY'	--pulls points for that home/away team, each a new row
	)
)
order	by match_date, location, home_or_away;

--Given example for pivot/unpivot combo

with	rws as (
	select home_team_name, away_team_name, 
 		case	--case expression to compare scores and determine if home team won/lost/draw
			when home_team_points > away_team_points then 'WON'
			when home_team_points < away_team_points then 'LOST'
			else 'DRAW'
		end home_team_result,
		case	--same as above case expression but for away team
			when home_team_points < away_team_points then 'WON'
			when home_team_points > away_team_points then 'LOST'
			else 'DRAW'
		end away_team_result
	from	match_results
)
	select	team, w, d, l	--columns later renamed in pivot clause
	from	rws
unpivot (
	(team, result) for home_or_away in ( 
		(home_team_name, home_team_result) as 'HOME',	--gets the name of home team and match result
		(away_team_name, away_team_result) as 'AWAY'	--same as above but for away team
    )
  )
pivot (
	count (*), min ( home_or_away ) dummy --dummy column used some what???
	for result in (
		'WON' W, 'DRAW' D, 'LOST' L		--Rename columns to single letter abbr.
	)
)
order  by w desc, d desc, l;