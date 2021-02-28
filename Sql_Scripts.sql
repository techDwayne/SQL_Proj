--Udemy 70-461 SQL Training 
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

