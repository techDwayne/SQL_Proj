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
order by EmployeeNumber --must be in tblTransaction, and NOT 126-129, 
--equivalent to Left Join

select * 
from tblTransaction as T
Where EmployeeNumber in
    (Select EmployeeNumber from tblEmployee where EmployeeLastName  not like 'y%')
order by EmployeeNumber --must be in tblEmployee and tblTransaction, and NOT 126-129	
--equivalent to Inner Join

select * 
from tblTransaction as T
Where EmployeeNumber <> all --gives all BUT what is in the subquery below
    (Select EmployeeNumber from tblEmployee where EmployeeLastName like 'y%')
order by EmployeeNumber

--any/some == OR
--all == AND

/* using RANK() in  Subqueries

*/

select * from
(select D.Department, EmployeeNumber, EmployeeFirstName, EmployeeLastName,
       rank() over(partition by D.Department order by E.EmployeeNumber) as TheRank
 from tblDepartment as D 
 join tblEmployee as E on D.Department = E.Department) as MyTable
where TheRank <= 5
order by Department, EmployeeNumber

/* WITH STATEMENT_ID (CTE Table)
Specifies a temporary named result set, known as a common table expression (CTE). This is derived from a simple 
query and defined within the execution scope of a single SELECT, INSERT, UPDATE, DELETE or MERGE statement. 
This clause can also be used in a CREATE VIEW statement as part of its defining SELECT statement. A common table 
expression can include references to itself. This is referred to as a recursive common table expression.

*/

with tblWithRanking as
(select D.Department, EmployeeNumber, EmployeeFirstName, EmployeeLastName,
	rank() over(partition by D.Department order by E.EmployeeNumber) as TheRank
from tblDepartment as D 
	join tblEmployee as E on D.Department = E.Department), --CTE 1
Transaction2014 as 
	(select * from tblTransaction where DateofTransaction < '2015-01-01') --CTE2
select * from tblWithRanking left join Transaction2014 on tblWithRanking.EmployeeNumber =Transaction2014.EmployeeNumber
where TheRank <= 5
order by Department, tblWithRanking.EmployeeNumber


/* example generating dynamic max unused employee number 

*/

with Numbers as (
select top(select max(EmployeeNumber)AS maxEmpID from tblTransaction) ROW_NUMBER() over(order by (select null)) as RowNumber
from tblTransaction AS U)
select U.RowNumber from Numbers as U
left join tblTransaction as T
on U.RowNumber = T.EmployeeNumber
where T.EmployeeNumber is null
order by U.RowNumber 

/* Grouping Numbers
example generating a list of employee numbers who did not perform transactions during specified year 2014
grouped by employee numbers and showing a total of employees per group who did not perform transactions 
*/
with Numbers as (
select top(select max(EmployeeNumber)AS maxEmpID from tblTransaction) ROW_NUMBER() over(order by (select null)) as RowNumber
from tblTransaction AS U),
Transactions2014 as (
	select * from tblTransaction where DateofTransaction >='2014-01-01' and DateofTransaction<='2015-01-01'),
tblGap as (
select U.RowNumber,
	RowNumber - LAG(RowNumber) over(order by RowNumber) as PreviousRowNumber,
	LEAD(RowNumber) over(order by RowNumber) - RowNumber as NextRowNumber,
	case  when RowNumber - LAG(RowNumber) over(order by RowNumber) = 1 then 0 else 1 end as GroupGap
from Numbers as U
left join Transactions2014 as T
on U.RowNumber = T.EmployeeNumber
where T.EmployeeNumber is null), 
tblGroup as (
select *, sum(GroupGap) over(Order By RowNumber) as TheGroup
from tblGap)
select  min(RowNumber) as StartingEmpNumber, max(RowNumber) as EndingEmpNumber,
	max(RowNumber) - Min(RowNumber) +1 as NumberEmployees
from tblGroup
group by TheGroup
order by TheGroup 

/* Pivot command
same as a pivot table in Excel
PIVOT rotates a table-valued expression by turning the unique values from one column in the expression into multiple columns in the output. And PIVOT runs aggregations where they're required on any remaining column values that are wanted in the final output.


syntax: 

SELECT <non-pivoted column>,  
    [first pivoted column] AS <column name>,  
    [second pivoted column] AS <column name>,  
    ...  
    [last pivoted column] AS <column name>  
FROM  
    (<SELECT query that produces the data>)   
    AS <alias for the source query>  
PIVOT  
(  
    <aggregation function>(<column being aggregated>)  
FOR   
[<column that contains the values that will become column headers>]   
    IN ( [first pivoted column], [second pivoted column],  
    ... [last pivoted column])  *NOTE* Must use [] around column names that are do start with an alpha character.
) AS <alias for the pivot table>  
<optional ORDER BY clause>;

*/

with myTable as 
	(select year(DateofTransaction) as TheYear, month(DateofTransaction) as TheMonth, Amount from tblTransaction)
select * from myTable
PIVOT (sum(Amount) for TheMonth in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) as myPvt
ORDER BY TheYear 

/* Unpivot

UNPIVOT carries out almost the reverse operation of PIVOT, by rotating columns into rows.

*/
SELECT *
  FROM [tblPivot]
UNPIVOT (Amount FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS tblUnPivot
where Amount <> 0
order by TheYear

/*

Self Join: 
You can join a table to itself even if the table does not have a reflexive relationship in the database.

*/

begin tran
alter table tblEmployee
add Manager int
go
update tblEmployee
set Manager = ((EmployeeNumber-123)/10)+123
where EmployeeNumber>123
select E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName, E.Manager, 
		M.EmployeeNumber as ManagerNumber, M.EmployeeFirstName as ManagerFirstName, M.EmployeeLastName as ManagerLastName
from tblEmployee as E
left Join tblEmployee as M
on E.Manager = M.EmployeeNumber

rollback tran

/* Recursion
Uses a WITH (CTE) to perform recursive operation

syntax: 

WITH X AS <BASE QUERY> --BASE (ANCHOR) MEMBER
UNION ALL
<RECURSIVE_QUERY INVOLVING x> --RECURSIVE MEMBER; REFERENCES x
<QUERY INVOLVING x>

*/

begin tran
alter table tblEmployee
add Manager int
go
update tblEmployee
set Manager = ((EmployeeNumber-123)/10)+123
where EmployeeNumber>123;
with myTable as
(select EmployeeNumber, EmployeeFirstName, EmployeeLastName, 0 as BossLevel --Anchor
from tblEmployee
where Manager is null
UNION ALL --UNION ALL!!
select E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName, myTable.BossLevel + 1 --Recursive
from tblEmployee as E
join myTable on E.Manager = myTable.EmployeeNumber
) --recursive CTE

select * from myTable

rollback tran

/* FUNCTIONS
Scaler
In Line Table
Multi Line Table

Can be used in select or where statements 
Can be joined with tables using 'apply' 
*/
SELECT * 
from dbo.TransList(123) --Function
GO

select *, (select count(*) from dbo.TransList(E.EmployeeNumber)) as NumTransactions
from tblEmployee as E

select *
from tblEmployee as E
outer apply TransList(E.EmployeeNumber) as T --apply takes the place of a join when using Functions 

select *
from tblEmployee as E
cross apply TransList(E.EmployeeNumber) as T

--outer apply = LEFT JOIN
--cross apply = INNER JOIN

/* GUID
Use NONSEQUENTIALID() to create random IDENDITY
Unique 128 bit NUMBER
Can be used as IDENDITY in a table
16 BYTE

*/

begin tran
Create table tblEmployee4
(UniqueID uniqueidentifier CONSTRAINT df_tblEmployee4_UniqueID DEFAULT NEWSEQUENTIALID(),
EmployeeNumber int CONSTRAINT uq_tblEmployee4_EmployeeNumber UNIQUE)
Insert into tblEmployee4(EmployeeNumber)
VALUES (1), (2), (3)
select * from tblEmployee4
rollback tran

/* XML
SQL can export the results of a query as XML

*/
--For XML RAW  exports attributes
select E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName
	,E.DateOfBirth, T.Amount, T.DateOfTransaction
from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber between 200 and 202
for xml raw ('MyRow'), elements --elements will output as individual elements, well formed XML

/* Sample output: 
*/
<MyRow>
  <EmployeeNumber>200</EmployeeNumber>
  <EmployeeFirstName>Michiko</EmployeeFirstName>
  <EmployeeLastName>Robinett</EmployeeLastName>
  <DateOfBirth>1981-12-23</DateOfBirth>
  <Amount>958.9400</Amount>
  <DateOfTransaction>2015-02-25T00:00:00</DateOfTransaction>
</MyRow>

/* For XML Auto
Exports as nested attributes 
*/

select E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName
	,E.DateOfBirth, T.Amount, T.DateOfTransaction
from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber between 200 and 202
for xml auto

/*Sample Output
*/
<E EmployeeNumber="200" EmployeeFirstName="Michiko" EmployeeLastName="Robinett" DateOfBirth="1981-12-23">
  <T Amount="958.9400" DateOfTransaction="2015-02-25T00:00:00" />
  <T Amount="-5.0900" DateOfTransaction="2015-08-31T00:00:00" />
</E>

/* add , elements to For XML Auto to output as elements 

Sample Ouput
*/

<E>
  <EmployeeNumber>200</EmployeeNumber>
  <EmployeeFirstName>Michiko</EmployeeFirstName>
  <EmployeeLastName>Robinett</EmployeeLastName>
  <DateOfBirth>1981-12-23</DateOfBirth>
  <T>
    <Amount>958.9400</Amount>
    <DateOfTransaction>2015-02-25T00:00:00</DateOfTransaction>
  </T>
  <T>
    <Amount>-5.0900</Amount>
    <DateOfTransaction>2015-08-31T00:00:00</DateOfTransaction>
  </T>
</E>

/* For XML Path
*/

select E.EmployeeFirstName as '@EmployeeFirstName'
	   , E.EmployeeLastName as '@EmployeeLastName'
	   , E.EmployeeNumber
       , E.DateOfBirth
	   , T.Amount as 'Transaction/Amount'
	   , T.DateOfTransaction as 'Transaction/DateOfTransaction'
from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber between 200 and 201
for xml path('Employees'), ROOT('MyXML')

--Sample Output (Well Formed XML)
<MyXML>
  <Employees EmployeeFirstName="Michiko" EmployeeLastName="Robinett">
    <EmployeeNumber>200</EmployeeNumber>
    <DateOfBirth>1981-12-23</DateOfBirth>
    <Transaction>
      <Amount>958.9400</Amount>
      <DateOfTransaction>2015-02-25T00:00:00</DateOfTransaction>
    </Transaction>
  </Employees>
  <Employees EmployeeFirstName="Michiko" EmployeeLastName="Robinett">
    <EmployeeNumber>200</EmployeeNumber>
    <DateOfBirth>1981-12-23</DateOfBirth>
    <Transaction>
      <Amount>-5.0900</Amount>
      <DateOfTransaction>2015-08-31T00:00:00</DateOfTransaction>
    </Transaction>
  </Employees>
  <Employees EmployeeFirstName="Carol" EmployeeLastName="Roberts">
    <EmployeeNumber>201</EmployeeNumber>
    <DateOfBirth>1991-06-25</DateOfBirth>
    <Transaction>
      <Amount>-351.4100</Amount>
      <DateOfTransaction>2014-04-14T00:00:00</DateOfTransaction>
    </Transaction>
  </Employees>
  <Employees EmployeeFirstName="Carol" EmployeeLastName="Roberts">
    <EmployeeNumber>201</EmployeeNumber>
    <DateOfBirth>1991-06-25</DateOfBirth>
    <Transaction>
      <Amount>-893.2300</Amount>
      <DateOfTransaction>2014-09-18T00:00:00</DateOfTransaction>
    </Transaction>
  </Employees>
  <Employees EmployeeFirstName="Carol" EmployeeLastName="Roberts">
    <EmployeeNumber>201</EmployeeNumber>
    <DateOfBirth>1991-06-25</DateOfBirth>
    <Transaction>
      <Amount>-893.2300</Amount>
      <DateOfTransaction>2014-09-19T00:00:00</DateOfTransaction>
    </Transaction>
  </Employees>
</MyXML>

/* Temp TABLES
Temp Tables can be used to store data you need to re-use for calculations. 

Example below from SQLAnalystTraining Database */

Drop Table if Exists #Temp_Employee2 --drops the table if it was already created. 
Create table #Temp_Employee2 (
JobTitle varchar (50),
EmployeesPerJob int, 
AvgAge int,
AvgSalary int)

Insert into #Temp_Employee2
Select JobTitle, Count(JobTitle), Avg(Age), Avg(Salary)
from EmployeeDemographics emp
join EmployeeSalary sal
	on emp.EmployeeID = sal.EmployeeID
group by JobTitle

Select * from #Temp_Employee2
















