### SQL Quiz

1.Employees all over the world. Can you tell me the top three cities that we have employees?

```MySQL
select city,
		count(distinct employeenumber) as emp_num
from employees e
inner join offices o on e.officecode=o.officecode
group by o.city
order by emp_num desc
limit 3;
```
2.For company products, each product has inventory and buy price, msrp. Assume that every product is sold on msrp price. 

- Can you write a query to tell company executives: profit margin on each productlines
- Profit margin= sum(profit if all sold) - sum(cost of each=buyPrice) / sum (buyPrice)
- Product line = each product belongs to a product line. You need group by product line. 

```MySQL
select productline,
		round(100*(sum(msrp)-sum(buyprice))/sum(buyprice),2) as prof_margin
from products
group by productline
order by 2 desc;
```
3.company wants to award the top 3 sales rep They look at who produces the most sales revenue.
A.can you write a query to help find the employees.

```MySQL 
select e.employeenumber,
		e.lastname,
		e.firstname,
round(sum(od.quantityOrdered*od.priceEach),2) ord_tot_amt
from employees e
inner join customers c on e.employeenumber=c.salesRepEmployeeNumber
inner join orders o on c.customerNumber=o.customerNumber
inner join orderdetails od on o.orderNumber=od.orderNumber
where o.status='shipped'
group by 1
order by 4 desc
limit 3;
```
B. if we want to promote the employee to a manager, what do you think are the tables to be updated. 

```MySQL
with top_3_emp as 
(select e.employeenumber,
		e.lastname,
		e.firstname,
		sum(od.quantityOrdered*od.priceEach) tot_amt,
		e.reportsTo
from employees e
inner join customers c on e.employeenumber=c.salesRepEmployeeNumber
inner join orders o on c.customerNumber=o.customerNumber
inner join orderdetails od on o.orderNumber=od.orderNumber
where o.status='shipped'
group by 1
order by 4 desc
limit 3)

select distinct m.employeenumber as manager_id,
		concat(m.lastname,' ',m.firstname) as manager_name,
		round(t.ord_tot_amt,2) as tot_sales
from top_3_emp t
inner join employees m on top_3_emp.reportsTo=m.employeeNumber
group by 1
order by 3 desc;
```
C. An employee is leaving the company, write a stored procedure to handle the case. 

 1). Make the current employee inactive, 
 
 2). Replaced with its manager employeenumber in order table. (I changed salesRepEmployeeNumber to the accordance manager employeeNumber in customer table)

```MySQL
alter table employees
add start_date datetime not null,
add term_date datetime,
add active_or_not boolean not null default 1;

insert into employees (start_date,term_date,active_or_not)
values ('','',''),
	('','',''),
	('','',''),
	('','',''),
	....;

delimiter $$
drop procedure if exists GetEmployeeStatusChanged $$
create procedure GetEmployeeStatusChanged(in employeeid_leaving int)
begin
	update employee
	set active_or_not=0
	where employeeNumber=employeeid_leaving;
    
    update customers
    set salesRepEmployeeNumber=
				(select reportsTo
				from employees
				where employeeNumber=employeeid_leaving);
end $$
delimiter;

call GetEmployeeStatusChanged();
```
4.Employee Salary Change Times 
Ask to provide a table to show for each employee in a certain department how many times their Salary changes 

```MySQL
create table employee_salary(
employeenumber int not null,
lastName varchar(50) not null,
firstName varchar(50) not null,
update_date datetime not null,
salary decimal(10,2) not null);

insert into employee_salary (employeeNumber,lastName,firstName,update_date,salary)
values ('','','','',''),
	('','','','',''),
	('','','','',''),
	('','','','',''),
	...;

delimiter $$
drop procedure if exists GetSalaryChangedTimes $$
create procedure GetSalaryChangedTimes(in department_num int)
begin
select employeeNumber,
	lastName,
	firstName,
	count(update_date)-1 as salary_change_times
from employee_salary
where officeCode=department_num
group by 1;
end $$
delimiter;

call GetSalaryChangedTimes(1);
```
5.Top 3 salary
Ask to provide a table to show for each department the top 3 salary with employee name and employee has not left the company.

```MySQL
select tt.officeCode,
		tt.employeenumber,
		tt.lastname,
		tt.firstname,
        tt.salary
from(select e.officeCode,
		e.employeenumber,
		e.lastname,
		e.firstname,
        t.salary,
        dense_rank()over(partition by e.officeCode order by t.salary desc) as ranks
	from employees e
	inner join (select employeeNumber,
				salary 
				from employee_salary 
				group by employeeNumber 
				order by update_date desc
				limit 1) t on e.employeeNumber=t.employeeNumber
	where e.active_or_not=1) tt
where tt.ranks<=3
order by 1, 5 desc;
```
