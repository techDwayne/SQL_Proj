If exists (select * from sys.procedures where name like 'EmployeeView')
drop proc EmployeeView
go

create proc EmployeeView (@EmpNum int) as
begin
	if exists (select * from tblEmployee where EmployeeNumber = @EmpNum) 
	begin
		select EmployeeNumber, EmployeeFirstName, EmployeeLastName
		from tblEmployee as EmployeeNumber
		where EmployeeNumber = @EmpNum
	end
	 else Select 'No Employee' as EmployeeNumber
end