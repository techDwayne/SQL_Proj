--Udemy 70-461 SQL Training 
/* script to change DB Owner in MS-SQL
*/


USE <DatabaseName>
GO
sp_changedbowner 'domain\username'


--Stored Procedure with IF condition

if OBJECT_ID('EmployeeView', 'P') is not null
drop proc EmployeeView
go

create proc EmployeeView (@EmpNum int) as
begin
	if exists (select * from tblEmployee where EmployeeNumber = @EmpNum) 
	begin	
	if @EmpNum < 300
	begin
		select EmployeeNumber, EmployeeFirstName, EmployeeLastName
		from tblEmployee
		where EmployeeNumber = @EmpNum
	end
	else 
		begin
			select EmployeeNumber, EmployeeFirstName, EmployeeLastName
			from tblEmployee 
			where EmployeeNumber = @EmpNum
			select * from tblTransaction where EmployeeNumber = @EmpNum 
		end
	end 
end

--StoredProc with range of arguments

if OBJECT_ID('EmployeeView', 'P') is not null
drop proc EmployeeView2
go

create proc EmployeeView2 (@EmpNumFrom int, @EmpNumTo int) as
begin
	if exists (select * from tblEmployee where EmployeeNumber between @EmpNumFrom and @EmpNumTo) 
		begin
			select EmployeeNumber, EmployeeFirstName, EmployeeLastName
			from tblEmployee
			where EmployeeNumber between @EmpNumFrom and @EmpNumTo
		end
end

--StoredProc with WHILE loop

if OBJECT_ID('EmployeeView3', 'P') is not null
drop proc EmployeeView3
go

create proc EmployeeView3 (@EmpNumFrom int, @EmpNumTo int) as
begin
	if exists (select * from tblEmployee where EmployeeNumber between @EmpNumFrom and @EmpNumTo) 
		begin
			declare @EmpNum int = @EmpNumFrom
			while @EmpNum <= @EmpNumTo
				Begin
					select EmployeeNumber, EmployeeFirstName, EmployeeLastName
					from tblEmployee
					where EmployeeNumber = @EmpNum
					SET @EmpNum = @EmpNum + 1
				end
		end
end

--Over(), PARTITION BY, and ORDER BY clause

--Over() 
select A.EmployeeNumber, year(A.AttendanceMonth) as AttendanceYear, 
sum(A.NumberAttendance) over() as TotalAttendance,
convert(decimal (18,7),A.NumberAttendance) /sum(A.NumberAttendance) over() * 100 as PercentageAttendance --shows percentage of annual attendance per month over a given year
from tblEmployee as E join tblAttendance as A
on e.EmployeeNumber = A.EmployeeNumber
--group by A.EmployeeNumber, year(A.AttendanceMonth) 
--order by A.EmployeeNumber, year(A.AttendanceMonth) 
where A.AttendanceMonth < '20150101'

--Over(partition by)
select A.EmployeeNumber, year(A.AttendanceMonth) as AttendanceYear, 
sum(A.NumberAttendance) over(partition by A.EmployeeNumber) as TotalAttendance,
convert(decimal (18,7),A.NumberAttendance) /sum(A.NumberAttendance) over(partition by A.EmployeeNumber) * 100 as PercentageAttendance --shows percentage of attendance for a given year, per Employee
from tblEmployee as E join tblAttendance as A
on e.EmployeeNumber = A.EmployeeNumber
--group by A.EmployeeNumber, year(A.AttendanceMonth) 
--order by A.EmployeeNumber, year(A.AttendanceMonth) 
where A.AttendanceMonth < '20150101'

--over(partition by order by)
select A.EmployeeNumber, year(A.AttendanceMonth) as AttendanceYear, 
sum(A.NumberAttendance) over(partition by A.EmployeeNumber order by A.AttendanceMonth) as RunningTotal --keeps running total for the attendance year
--convert(decimal (18,7),A.NumberAttendance) /sum(A.NumberAttendance) over(partition by A.EmployeeNumber order by A.AttendanceMonth) * 100 as PercentageAttendance
from tblEmployee as E join tblAttendance as A
on e.EmployeeNumber = A.EmployeeNumber
--group by A.EmployeeNumber, year(A.AttendanceMonth) 
--order by A.EmployeeNumber, year(A.AttendanceMonth) 
where A.AttendanceMonth < '20150101'

--over() with rows between keywords preceding and following
select A.EmployeeNumber, year(A.AttendanceMonth) as AttendanceYear, 
sum(A.NumberAttendance) 
over(partition by A.EmployeeNumber 
	order by A.AttendanceMonth
	rows between 1 preceding and 1 following) as RunningTotal
from tblEmployee as E join tblAttendance as A
on e.EmployeeNumber = A.EmployeeNumber
where A.AttendanceMonth < '20150101'

--over() with range between
	--range can only use the following keywords: 
		--unbounded preceding and current row following
		--current row preceding and unbounded following
		--unbounded preceding and unbounded following (note: this combination may also be used with rows between
	
select A.EmployeeNumber, year(A.AttendanceMonth) as AttendanceYear
,sum(A.NumberAttendance) 
over(partition by A.EmployeeNumber, year(A.AttendanceMonth)
	order by A.AttendanceMonth
	rows between unbounded preceding and current row) as RowsTotal
,sum(A.NumberAttendance) 
over(partition by A.EmployeeNumber, year(A.AttendanceMonth)
	order by A.AttendanceMonth
	range between unbounded preceding and current row) as RangeTotal
from tblEmployee as E join tblAttendance as A
on e.EmployeeNumber = A.EmployeeNumber

--over() default usage
select A.EmployeeNumber, year(A.AttendanceMonth) as AttendanceYear, 
sum(A.NumberAttendance) over() as TotalAttendance,
convert(decimal (18,7),A.NumberAttendance) /sum(A.NumberAttendance) over() * 100 as PercentageAttendance --shows percentage of annual attendance per month over a given year
from tblEmployee as E join tblAttendance as A
on e.EmployeeNumber = A.EmployeeNumber
where A.AttendanceMonth < '20150101'

--should use one of the following when using over() 
	--range between unbounded preceding and unbounded following **DEFAULT when there is no Order BY
	--rows between unbounded preceding and unbounded following ** MUST be used with an Order By 

--over() with Order By and unspecified rows between 
select A.EmployeeNumber, year(A.AttendanceMonth) as AttendanceYear
,sum(A.NumberAttendance) 
over(partition by A.EmployeeNumber, year(A.AttendanceMonth)
	order by A.AttendanceMonth) as SumAttendance
from tblEmployee as E join tblAttendance as A
on e.EmployeeNumber = A.EmployeeNumber
order by A.EmployeeNumber, A.AttendanceMonth

/*range between unbounded preceding and current row **this is DEFAULT where there IS an Order By*/

--FIRST_VALUE() and LAST_VALUE()
select A.EmployeeNumber,A.AttendanceMonth, A.NumberAttendance, 
FIRST_VALUE(NumberAttendance)
over(partition by E.EmployeeNumber order by A.AttendanceMonth
	rows between 2 preceding and current row) as FirstMonth,
LAST_VALUE(NumberAttendance)
over(partition by E.EmployeeNumber order by A.AttendanceMonth
	rows between unbounded preceding and unbounded following) as LastMonth
from tblEmployee as E join tblAttendance as A 
on E.EmployeeNumber = A.EmployeeNumber

/* Syntax: 
FIRST_VALUE ( [scalar_expression ] )  [ IGNORE NULLS | RESPECT NULLS ]
    OVER ( [ partition_by_clause ] order_by_clause [ rows_range_clause ] )
LAST_VALUE ( [ scalar_expression ] )  [ IGNORE NULLS | RESPECT NULLS ]
    OVER ( [ partition_by_clause ] order_by_clause rows_range_clause )  
 partition_by_clause is optional in both instances. 
for LAST_VALUE, range_rows_clause is optional, but should never be omitted, as it can skew returned data. */

/* LAG and LEAD() */
select A.EmployeeNumber,A.AttendanceMonth, A.NumberAttendance, 
lag(NumberAttendance)
over(partition by E.EmployeeNumber order by A.AttendanceMonth) as myLag,
lead(NumberAttendance)
over(partition by E.EmployeeNumber order by A.AttendanceMonth) as myLead
from tblEmployee as E join tblAttendance as A 
on E.EmployeeNumber = A.EmployeeNumber

/*
LAG() and LEAD() will generate NULL values unless you  place a value in the default location
syntax: 
LAG (scalar_expression [,offset] [,default])  
    OVER ( [ partition_by_clause ] order_by_clause ) 
LEAD ( scalar_expression [ ,offset ] , [ default ] )   
    OVER ( [ partition_by_clause ] order_by_clause )  
*/

/* LAG() and LEAD() can be used to show a difference */

select A.EmployeeNumber,A.AttendanceMonth, A.NumberAttendance, 
/*lag(NumberAttendance)
over(partition by E.EmployeeNumber order by A.AttendanceMonth) as myLag,
lead(NumberAttendance)
over(partition by E.EmployeeNumber order by A.AttendanceMonth) as myLead,*/
NumberAttendance - lag(NumberAttendance)
over(partition by E.EmployeeNumber order by A.AttendanceMonth) as myDifference
from tblEmployee as E join tblAttendance as A 
on E.EmployeeNumber = A.EmployeeNumber

 /* CUME_DIST() and PERCENT_RANK() */
 
select A.EmployeeNumber,A.AttendanceMonth, A.NumberAttendance, 
CUME_DIST()		over(partition by E.EmployeeNumber 
				order by A.AttendanceMonth) as CumeDist, /* gets the cumulative distribution between a value withing a group of values*/
PERCENT_RANK()	over(partition by E.EmployeeNumber 
				order by A.AttendanceMonth) as PercentRank /* calculates the relative rank of a row within a group of rows */
from tblEmployee as E join tblAttendance as A 
on E.EmployeeNumber = A.EmployeeNumber

/* Syntax: 
CUME_DIST( )  
    OVER ( [ partition_by_clause ] order_by_clause )  
PERCENT_RANK( )  
    OVER ( [ partition_by_clause ] order_by_clause )  */  


/* Percentile_Cont() and Percentile_Disc */

select Distinct EmployeeNumber,
PERCENTILE_CONT (0.5) Within Group (Order By NumberAttendance) over (Partition By EmployeeNumber) as AverageCont,
PERCENTILE_DISC (0.5) Within Group (Order By NumberAttendance) Over (Partition By EmployeeNumber) as AverageDisc
from tblAttendance

/* Syntax: 
PERCENTILE_CONT ( numeric_literal )   
    WITHIN GROUP ( ORDER BY order_by_expression [ ASC | DESC ] )  
    OVER ( [ <partition_by_clause> ] )
PERCENTILE_DISC ( numeric_literal ) WITHIN GROUP ( ORDER BY order_by_expression [ ASC | DESC ] )  
    OVER ( [ <partition_by_clause> ] )
*/

/* Group By rolloup: 
Creates a group for each combination of column expressions. In addition, it "rolls up" the results into subtotals and grand totals. To do this, it moves from right to left decreasing the number of column expressions over which it creates groups and the aggregation(s).

To remove nulls, use GROUPING and GROUPING_ID
GROUPING--Indicates whether a specified column expression in a GROUP BY list is aggregated or not. GROUPING returns 1 for aggregated or 0 for not aggregated in the result set. GROUPING can be used only in the SELECT <select> list, HAVING, and ORDER BY clauses when GROUP BY is specified. GROUPING is used to distinguish the null values that are returned by ROLLUP, CUBE or GROUPING SETS from standard null values. The NULL returned as the result of a ROLLUP, CUBE or GROUPING SETS operation is a special use of NULL. This acts as a column placeholder in the result set and means all.

GROUPING_ID--Is a function that computes the level of grouping. GROUPING_ID can be used only in the SELECT <select> list, HAVING, or ORDER BY clauses when GROUP BY is specified. The GROUPING_ID <column_expression> must exactly match the expression in the GROUP BY list. For example, if you are grouping by DATEPART (yyyy, <column name>), use GROUPING_ID (DATEPART (yyyy, <column name>)); or if you are grouping by <column name>, use GROUPING_ID (<column name>).
*/
select E.Department, E.EmployeeNumber, A.AttendanceMonth as AttendanceMonth, Sum(A.NumberAttendance) as NumberAttendance,
GROUPING (E.EmployeeNumber) as EmployeeNumberGroupedBy, 
GROUPING_ID (E.Department, E.EmployeeNumber, A.AttendanceMonth) as EmployeeNumberGroupedID
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
group by rollup (E.Department, E.EmployeeNumber, A.AttendanceMonth)
Order by Department, EmployeeNumber, AttendanceMonth


/*CUBE
GROUP BY CUBE creates groups for all possible combinations of columns. 
For GROUP BY CUBE (a, b) the results has groups for unique values of (a, b), (NULL, b), (a, NULL), and (NULL, NULL).

*/
select E.Department, E.EmployeeNumber, A.AttendanceMonth as AttendanceMonth, Sum(A.NumberAttendance) as NumberAttendance,
GROUPING (E.EmployeeNumber) as EmployeeNumberGroupedBy, 
GROUPING_ID (E.Department, E.EmployeeNumber, A.AttendanceMonth) as EmployeeNumberGroupedID
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
group by cube (E.Department, E.EmployeeNumber, A.AttendanceMonth)
Order by Department, EmployeeNumber, AttendanceMonth

	
/* GROUPING SET
The GROUPING SETS option gives you the ability to combine multiple GROUP BY clauses into one GROUP BY clause. The results are the equivalent of UNION ALL of the specified groups.

For example, GROUP BY ROLLUP (Country, Region) and GROUP BY GROUPING SETS ( ROLLUP (Country, Region) ) return the same results.

When GROUPING SETS has two or more elements, the results are a union of the elements
 
*/

/* SubQuery
A subquery is a SQL query within a query.
They are nested queries that provide data to the enclosing query.

Subqueries can return individual values or a list of records.
Note that subquery statements are enclosed between parenthesis. 
*/
select * 
from tblTransaction as T
Where EmployeeNumber in
    (Select EmployeeNumber from tblEmployee where EmployeeLastName like 'y%')
order by EmployeeNumber

select * 
from tblTransaction as T
Where EmployeeNumber not in
    (Select EmployeeNumber from tblEmployee where EmployeeLastName like 'y%')
order by EmployeeNumber --must be in tblTransaction, and NOT 126-129

select * 
from tblTransaction as T
Where EmployeeNumber in
    (Select EmployeeNumber from tblEmployee where EmployeeLastName  not like 'y%')
order by EmployeeNumber --must be in tblEmployee and tblTransaction, and NOT 126-129	


