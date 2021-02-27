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

--StoredProc with range of arugments

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
