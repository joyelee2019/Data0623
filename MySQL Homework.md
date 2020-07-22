## MySQL Homework - [Additional SQL queries](https://www.richardtwatson.com/dm6e/Reader/ClassicModels.html)

ClassicModels is a fictitious company. Use the **ClassicModels database** to answer the following requests ([SQL to create the database](https://www.richardtwatson.com/dm6e/Reader/sql/ClassicModels.sql)). Your instructor has the answers to all queries.

The latitude and longitude are specified for office and customer locations in the Offices and Customers tables, respectively. The SRID is set to 4326 to indicate the Spacial Reference System (SRS) is geographic (see Chapter 11 for more details on SRID and SRS).

---

### Single entity

<details>
<summary>Single entity questions 1-15</summary>

1.Prepare a list of offices sorted by country, state, city.

```MySQL
select *
from offices
order by country, state, city;
```
2.How many employees are there in the company? 

```MySQL
select count(distinct employeenumber) as employee_total
from employees;
```
3.What is the total of payments received?

```MySQL
select sum(amount) as amount_total
from payments;
```
4.List the product lines that contain 'Cars'.

```MySQL
select *
from productlines
where productline like '%Cars%';
```
5.Report total payments for October 28, 2004.

```MySQL
select sum(amount) as payment_on_a_day
from payments
where paymentdate='2004-10-28';
```
6.Report those payments greater than $100,000.

```MySQL
select *
from payments
where amount>100000;
```
7.List the products in each product line.

```MySQL
select *
from products
group by productline, productname
order by productline, productname;
```
8.How many products in each product line?

```MySQL
select productline, count(distinct productcode) as product_cnt
from products
group by productline;
```
9.What is the minimum payment received?

```MySQL
select *
from payments
order by amount
limit 1;
```
10.List all payments greater than twice the average payment.

```MySQL
select *
from payments
where amount > (select 2*avg(amount) from payments);
```
11.What is the average percentage markup of the MSRP on buyPrice?

```MySQL
select round(100*avg(msrp/buyprice-1),2) as avg_percent_markup
from products;
```
12.How many distinct products does ClassicModels sell?

```MySQL
select count(distinct productname) as prod_num
from products
where productvendor='Classicmodels';
```
13.Report the name and city of customers who don't have sales representatives?

```MySQL
select customername,
		city
from customers
where salesrepemployeenumber is null;
```
14.What are the names of executives with VP or Manager in their title? Use the CONCAT function to
combine the employee's first name and last name into a single field for reporting.

```MySQL
select concat(firstname, ' ', lastname) as excutives_name,
		jobtitle
from employees
where jobtitle like '%VP%' or
	jobtitle like '%manager%';
```
15.Which orders have a value greater than $5,000?

```MySQL
select ordernumber,
		sum(quantityordered*priceeach) as order_amt
from orderdetails
group by ordernumber
having order_amt>5000;
```
</p>
</details>

### One to many relationship
<details>
<summary>One to many relationship questions 1-10</summary>

1.Report the account representative for each customer.

```MySQL
select concat(e.firstname,' ', e.lastname) as rep_for_cust, 
		c.*
from employees e
join customers c on e.employeenumber=c.salesrepemployeenumber;
```
2.Report total payments for Atelier graphique.

```MySQL
select sum(amount) as tot_amt
from payments p
inner join customers c on c.customernumber=p.customernumber
where c.customername= 'Atelier graphique';
```
3.Report the total payments by date.

```MySQL
select paymentdate,
		sum(amount) as tot_amt_by_date
from payments
group by paymentdate
order by 1;
```
4.Report the products that have not been sold.

```MySQL
select *
from products
where productcode not in
(select productcode
from orderdetails);
```
5.List the amount paid by each customer.

```MySQL
select o.customernumber, 
		c.customername, 
        sum(od.quantityordered*od.priceeach) as ord_amt
from customers c
inner join orders o on c.customernumber=o.customernumber
inner join orderdetails od on o.ordernumber=od.ordernumber
group by o.customernumber, o.ordernumber
```
6.How many orders have been placed by Herkku Gifts?

```MySQL
select c.customername, 
		count(distinct ordernumber) as ord_num
from customers c
inner join orders o on c.customernumber=o.customernumber
where c.customername='Herkku Gifts'
group by 1;
```
7.Who are the employees in Boston?

```MySQL
select e.*
from employees e
where officecode =
	(select officecode
	from offices
	where city='Boston')
```    
8.Report those payments greater than $100,000. 
Sort the report so the customer who made the highest payment appears first.

```MySQL
select c.customername, 
		p.*
from customers c
inner join payments p on c.customernumber=p.customernumber
where amount>100000
order by amount desc;
```
9.List the value of 'On Hold' orders.

```MySQL
select od.ordernumber, 
		sum(od.quantityordered*od.priceeach) as ord_value
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
where o.status='On Hold'
group by 1;
```
10.Report the number of orders 'On Hold' for each customer.

```MySQL
select c.customernumber, 
		c.customername, 
		count(distinct ordernumber) as ord_num_on_hold
from customers c
inner join orders o on c.customernumber=o.customernumber
where status='On Hold'
group by 1;
```
</p>
</details>

### Many to many relationship
<details>
<summary>**Many to many relationship question 1-8**</summary>

1.List products sold by order date.

```MySQL
select p.productcode, 
		p.productname, 
		o.orderdate
from products p
inner join orderdetails od on p.productcode=od.productcode
inner join orders o on od.ordernumber=o.ordernumber
order by 3,1;
```
2.List the order dates in descending order for orders for the 1940 Ford Pickup Truck.

```MySQL
select o.*
from products p
inner join orderdetails od on p.productcode=od.productcode
inner join orders o on od.ordernumber=o.ordernumber
where productname='1940 Ford Pickup Truck'
order by 3 desc;
```
3.List the names of customers and their corresponding order number where a particular order from that customer has a value greater than $25,000?

```MySQL
select c.customernumber,
		c.customername,
		o.ordernumber,
		sum(od.quantityordered*od.priceeach) as ord_amt
from customers c
inner join orders o on c.customernumber=o.customernumber
inner join orderdetails od on o.ordernumber=od.ordernumber
group by od.ordernumber
having ord_amt>25000
order by ord_amt desc;
```
4.Are there any products that appear on all orders?

```MySQL
select productcode, 
		count(distinct ordernumber) as ord_num
from orderdetails
group by productcode
having ord_num=( select count(distinct ordernumber)
					from orders);
```
5.Reports those products that have been sold with a markup of 100% or more (i.e.,  the priceEach is at least twice the buyPrice)

```MySQL
select p.*
from products p
left join orderdetails od on p.productcode=od.productcode
group by od.productcode
having (avg(od.priceeach)-p.buyprice)/p.buyprice>1;
```
6.List the products ordered on a Monday.

```MySQL
select p.*,
		o.orderdate
from products p
inner join orderdetails od on p.productcode=od.productcode
inner join orders o on od.ordernumber=o.ordernumber
where weekday(orderdate)='Monday';
```
7.What is the quantity on hand for products listed on 'On Hold' orders?

```MySQL
select p.productcode,
		p.productname,
		p.quantityinstock
from products p
inner join orderdetails od on p.productcode=od.productcode
inner join orders o on od.ordernumber=o.ordernumber
where o.status='On Hold'
order by 1;
```
</p>
</details>

### Regular expressions

<details>
<summary>Regular expressions questions 1-11</summary>

1.Find products containing the name 'Ford'.

```MySQL
select *
from products
where productname like '%ford%';  /* case insensitive for character search*/
```
```MySQL
select *
from products
where productname regexp 'ford';
```
2.List products ending in 'ship'.

```MySQL
select *
from products
where productname like '%ship';
```
```MySQL
select *
from products
where productname regexp 'ship$';
```
3.Report the number of customers in Denmark, Norway, and Sweden.

```MySQL
select country,
		count(distinct customernumber) as cust_num
from customers
where country in ('Denmark', 'Norway', 'Sweden')
group by 1
order by 1;
```
4.What are the products with a product code in the range S700_1000 to S700_1499?

```MySQL
select *
from products
where productcode between 'S700_1000' and 'S700_1499';
```
5.Which customers have a digit in their name?

```MySQL
-- select *
-- from customers
-- where customername like '[0-9]';
```
```MySQL
select *
from customers
where customername regexp '[0-9]';
```
6.List the names of employees called Dianne or Diane.

```MySQL
select lastname,
		firstname
from employees
where lastname regexp 'Dian{1,2}e'
or firstname regexp 'Dian{1,2}e';
```
7.List the products containing ship or boat in their product name.

```MySQL
select productname
from products
where productname regexp 'ship|boat';
```
8.List the products with a product code beginning with S700.

```MySQL
select productcode
from products
where productcode like 'S700%';
```
```MySQL
select productcode
from products
where productcode regexp '^S700';
```
9.List the names of employees called Larry or Barry.

```MySQL
select lastname,
		firstname
from employees
where lastname regexp 'l|barry'
or firstname regexp 'l|barry';
```
10.List the names of employees with non-alphabetic characters in their names.

```MySQL
select lastname,
		firstname
from employees
where lastname regexp '[^a-z]'
or firstname regexp '[^a-z]';
```
11.List the vendors whose name ends in Diecast

```MySQL
select productvendor
from products
where productvendor regexp 'Diecast$';
```
</p>
</details>

### General queries

<details>
<summary>General queries questions 1-28</summary>

1.Who is at the top of the organization (i.e.,  reports to no one).

```MySQL
select *
from employees
where reportsto is null
```
2.Who reports to William Patterson?

```MySQL
select e.*
from employees e
inner join employees m on e.reportsto=m.employeenumber
and concat(m.firstname, ' ', m.lastname)='William Patterson';
```
3.List all the products purchased by Herkku Gifts.

```MySQL
select p.*
from products p
inner join orderdetails od on p.productCode=od.productCode
inner join orders o on od.ordernumber=o.ordernumber
inner join customers c on o.customernumber=c.customernumber
where c.customername='Herkku Gifts';
```
4.Compute the commission for each sales representative, assuming the commission is 5% of the value of an order. Sort by employee last name and first name.

```MySQL
select e.employeenumber,
		e.lastname,
		e.firstname,
		round(0.05*sum(od.quantityOrdered*od.priceEach),2) as comm
from employees e
left join customers c on e.employeenumber=c.salesRepEmployeeNumber
inner join orders o on c.customerNumber=o.customerNumber
inner join orderdetails od on o.orderNumber=od.orderNumber
where o.status='shipped'
group by 1
order by 4 desc;
```
5.What is the difference in days between the most recent and oldest order date in the Orders file?

```MySQL
select t.latest_date-oldest_date as diff_day
from
(select (select orderdate from orders order by 1 desc limit 1) as latest_date,
		(select orderdate from orders order by 1 limit 1) as oldest_date
        ) t;
```
6.Compute the average time between order date and ship date for each customer ordered by the largest difference.

```MySQL
select customernumber,
		round(avg(shippeddate-orderdate),2) as diff
from orders
where status='shipped'
group by 1
order by 2 desc;
```
7.What is the value of orders shipped in August 2004? (Hint).

```MySQL
select od.ordernumber,
		sum(od.quantityordered*od.priceeach) as ord_amt
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
where month(o.shippeddate)='8'
and o.status='shipped'
group by od.ordernumber
order by 2 desc;
```
8.Compute the total value ordered, total amount paid, and their difference for each customer for orders placed in 2004 and payments received in 2004 
-- (Hint; Create views for the total paid and total ordered).

```MySQL
select o.customernumber,
		sum(od.quantityordered*od.priceeach)-sum(p.amount) as payable_amt
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
inner join payments p on o.customernumber=p.customernumber
where year(o.orderdate)='2004'
and year(p.paymentdate)='2004'
and o.status!='cancelled'
group by o.customerNumber;
```
9.List the employees who report to those employees who report to Diane Murphy. Use the CONCAT function to combine 
-- the employee's first name and last name into a single field for reporting.

```MySQL
select e.*
from employees e
inner join
(select m.employeenumber,
		concat(m.firstname,' ', m.lastname) as manager_name
from employees m
inner join employees ceo on m.reportsto=ceo.employeenumber 
						and concat(ceo.firstname,' ', ceo.lastname)='Diane Murphy'
) t
on e.reportsto=t.employeenumber;
```
10.What is the percentage value of each product in inventory sorted by the highest percentage first (Hint: Create a view first).

```MySQL
create view InventoryPercentage_View
as
select *,
round(100*sum(quantityinstock)/ (select sum(quantityinstock) from products),2) as percent_invt
from products
group by productCode
order by 10 desc;

select * from InventoryPercentage_View;
```
11.Write a function to convert miles per gallon to liters per 100 kilometers.

```MySQL
delimiter $$
create function OilConsumption(
measurement float
)
returns float
deterministic
begin
	declare oilconsumption float;
	if (measurement is not null) and (measurement >=0) then
		set oilconsumption=235.24/measurement;
    else 
		set oilconsumption='null';
    end if;
    return (OilConsumption);
end $$
delimiter;
```
12.Write a procedure to increase the price of a specified product category by a given percentage. 
-- You will need to create a product table with appropriate data to test your procedure. 
-- Alternatively, load the ClassicModels database on your personal machine so you have complete access. 
-- You have to change the DELIMITER prior to creating the procedure.

```MySQL
delimiter $$
drop procedure if exists GetPriceIncreased $$
create procedure GetPriceIncreased(
	in product_category char(25),
	increment decimal(10,2) )
begin
	update products
	set buyprice=(1+increment)*buyprice
	where productline=product_category;
end $$
delimiter ;

call GetPriceIncreased('ships', 0.5);
```
13.What is the value of orders shipped in August 2004? (Hint).

```MySQL
select od.ordernumber,
		sum(od.quantityordered*od.priceeach) as ord_amt
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
where left(o.shippeddate,7)='2004-08'
and o.status='shipped'
group by od.ordernumber
order by 2 desc;
```
14.What is the ratio the value of payments made to orders received for each month of 2004. (i.e., divide the value of payments made by the orders received)?

```MySQL
select left(o.orderDate,7) as months,
		round(100*sum(p.amount)/sum(od.quantityordered*od.priceeach),2) as payment_ratio
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber and year(o.orderdate)='2004'
inner join payments p on o.customernumber=p.customernumber and year(p.paymentdate)='2004'
where o.status!='cancelled'
group by 1
order by 1;
```
15.What is the difference in the amount received for each month of 2004 compared to 2003?

```MySQL
with year_2004 as (
select month(paymentDate) as months_2004,
		sum(amount) as payment_amt_2004
from payments
where year(paymentdate)='2004'
group by 1),

year_2003 as (
select month(paymentDate) as months_2003,
		sum(amount) as payment_amt_2003
from payments
where year(paymentdate)='2003'
group by 1 )

select y4.months_2004 as months,
		y4.payment_amt_2004 - y3.payment_amt_2003 as payment_diff
from year_2004 y4
inner join year_2003 y3 on y4.months_2004=y3.months_2003
order by 1;
```
16.Write a procedure to report the amount ordered in a specific month and year for customers containing a specified character string in their name.

```MySQL
delimiter $$
drop procedure if exists GetAmountOrdered $$
create procedure GetAmountOrdered(
	in name_char varchar(25),
	in given_month_year varchar(25) )
begin
	select c.customernumber,
			c.customername,
			sum(od.quantityordered*od.priceeach) as amt_ordered
	from orderdetails od
	inner join orders o on od.ordernumber=o.ordernumber
	inner join customers c on o.customernumber=c.customernumber
	where left(o.orderdate,7)='given_month_year'
	and c.customername like '%name_char%'
	and o.status!='cancelled'
	group by o.customerNumber;
end $$
delimiter ; 

call GetAmountOrdered('M', '2003-05');
```
17.Write a procedure to change the credit limit of all customers in a specified country by a specified percentage.

```MySQL
delimiter $$
drop procedure if exists ChangeCreditLimit $$
create procedure ChangeCreditLimit(
	in country_name char(25),
	out increment decimal)
begin
	update customers
	set creditLimit=(1+increment)*creditLimit
	where country=country_name;
end $$
delimiter ;

call ChangeCreditLimit('germany', 0.5);
```
18.Basket of goods analysis: A common retail analytics task is to analyze each basket or order to learn what products are often purchased together. 
-- Report the names of products that appear in the same order ten or more times.

```MySQL
select comb,
count(distinct t.ordernumber) as freq
from (
select concat(od1.productcode,' & ', od2.productcode) as comb,
od1.ordernumber
from orderdetails od1
inner join orderdetails od2 
	on od1.productcode<od2.productcode and od1.ordernumber=od2.ordernumber
    ) t
group by 1
having freq>=10
order by 2 desc;
```
19.ABC reporting: Compute the revenue generated by each customer based on their orders. Also, show each customer's revenue as a percentage of total revenue. Sort by customer name.

```MySQL
with rev_cust as (
	select c.customernumber,
			c.customername,
			sum(od.quantityordered*od.priceeach) as revenue_by_customer
	from orderdetails od
	inner join orders o on od.ordernumber=o.ordernumber
	inner join customers c on o.customernumber=c.customernumber
	where o.status!='cancelled'
	group by o.customerNumber ),
    
rev_tot as (
	select sum(od.quantityordered*od.priceeach) as revenue_total
	from orderdetails od
	inner join orders o on od.ordernumber=o.ordernumber
	where o.status!='cancelled' )
    
select customernumber,
		customername,
		round(100*revenue_by_customer/(select revenue_total from rev_tot),2) as percent_revenue
from rev_cust
order by 3 desc;
```
20.Compute the profit generated by each customer based on their orders. Also, show each customer's profit as a percentage of total profit. Sort by profit descending.

```MySQL
with profit_cust as (
	select c.customernumber,
			c.customername,
			sum(od.quantityordered*od.priceeach)-sum(od.quantityOrdered*p.buyprice) as profit_by_customer
	from orderdetails od
	inner join orders o on od.ordernumber=o.ordernumber
	inner join customers c on o.customernumber=c.customernumber
    inner join products p on p.productCode=od.productCode
	where o.status!='cancelled'
	group by o.customerNumber ),

profit_tot as (
	select sum(od.quantityordered*od.priceeach)-sum(od.quantityOrdered*p.buyprice) as profit_total
	from orderdetails od
	inner join orders o on od.ordernumber=o.ordernumber
    inner join products p on p.productCode=od.productCode
	where o.status!='cancelled' )
    
select customernumber,
		customername,
		round(100*profit_by_customer/(select profit_total from profit_tot),2) as percent_profit
from profit_cust
order by 3 desc;
```    
21.Compute the revenue generated by each sales representative based on the orders from the customers they serve.

```MySQL
select e.employeeNumber,
		e.firstName,
		e.lastName,
		sum(od.quantityordered*od.priceeach)-sum(od.quantityOrdered*p.buyprice) as profit_by_sr
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
inner join customers c on o.customerNumber=c.customerNumber
inner join employees e on c.salesRepEmployeeNumber=e.employeeNumber
inner join products p on p.productCode=od.productCode
where o.status!='cancelled'
group by e.employeeNumber
order by 4 desc;
```    
22.Compute the profit generated by each sales representative based on the orders from the customers they serve. Sort by profit generated descending.

```MySQL
with profit_sr as (
	select e.employeeNumber,
			e.firstName,
            e.lastName,
			sum(od.quantityordered*od.priceeach)-sum(od.quantityOrdered*p.buyprice) as profit_by_sr
	from orderdetails od
	inner join orders o on od.ordernumber=o.ordernumber
    inner join customers c on o.customerNumber=c.customerNumber
    inner join employees e on c.salesRepEmployeeNumber=e.employeeNumber
    inner join products p on p.productCode=od.productCode
	where o.status!='cancelled'
	group by e.employeeNumber ),
    
profit_tot as (
	select sum(od.quantityordered*od.priceeach)-sum(od.quantityOrdered*p.buyprice) as profit_total 
	from orderdetails od
	inner join orders o on od.ordernumber=o.ordernumber
    inner join products p on p.productCode=od.productCode
	where o.status!='cancelled')
    
select employeeNumber,
		lastName,
        firstName,
		round(100*profit_by_sr/(select profit_total from profit_tot),2) as percent_profit
from profit_sr
order by 4 desc;
```
23.Compute the revenue generated by each product, sorted by product name.

```MySQL
select p.productCode,
		p.productName,
		sum(od.quantityordered*od.priceeach) as revenue_by_prod
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
inner join products p on p.productCode=od.productCode
where o.status!='cancelled'
group by od.productCode
order by 2;
```
24.Compute the profit generated by each product line, sorted by profit descending.

```MySQL
select p.productCode,
		p.productName,
		sum(od.quantityordered*od.priceeach)-sum(od.quantityOrdered*p.buyprice) as profit_by_prod
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
inner join products p on p.productCode=od.productCode
where o.status!='cancelled'
group by p.productCode
order by 3 desc;
```
25.Same as Last Year (SALY) analysis: Compute the ratio for each product of sales for 2003 versus 2004.

```MySQL
with sales_2004 as (
select p.productCode,
		p.productName,
		sum(od.quantityordered*od.priceeach) as sales_by_prod_2004
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
inner join products p on p.productCode=od.productCode
where year(o.orderDate)='2004'
and o.status!='cancelled'
group by od.productCode ),

sales_2003 as (
select p.productCode,
		p.productName,
		sum(od.quantityordered*od.priceeach) as sales_by_prod_2003
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
inner join products p on p.productCode=od.productCode
where year(o.orderDate)='2003'
and o.status!='cancelled'
group by od.productCode )

select s4.productCode,
		s4.productName,
		round(s4.sales_by_prod_2004/s3.sales_by_prod_2003,2) as '2004_vs_2003'
from sales_2004 s4
inner join sales_2003 s3 on s4.productcode=s3.productcode
order by 1;
```
26.Compute the ratio of payments for each customer for 2003 versus 2004.

```MySQL
with paym_2004 as (
select c.customerNumber,
		c.customerName,
		sum(p.amount) as paym_by_cust_2004
from orders o
inner join customers c on o.customerNumber=c.customerNumber
inner join payments p on c.customerNumber=p.customerNumber
where year(o.orderDate)='2004'
and o.status!='cancelled'
group by o.customerNumber ),

paym_2003 as (
select c.customerNumber,
		c.customerName,
		sum(p.amount) as paym_by_cust_2003
from orders o
inner join customers c on o.customerNumber=c.customerNumber
inner join payments p on c.customerNumber=p.customerNumber
where year(o.orderDate)='2003'
and o.status!='cancelled'
group by o.customerNumber )

select p4.customerNumber,
		p4.customerName,
		round(p4.paym_by_cust_2004/p3.paym_by_cust_2003,2) as '2004_vs_2003'
from paym_2004 p4
inner join paym_2003 p3 on p4.customernumber=p3.customernumber
order by 1;
```
27.Find the products sold in 2003 but not 2004.

```MySQL
select distinct p.*
from products p
inner join orderdetails od on p.productCode=od.productCode
inner join orders o on od.orderNumber=o.orderNumber
where year(o.orderDate)='2003'
and o.status!='cancelled'
and p.productcode not in (
		select distinct p.productCode
		from products p
		inner join orderdetails od on p.productCode=od.productCode
		inner join orders o on od.orderNumber=o.orderNumber
		where year(o.orderDate)='2004'
		and o.status!='cancelled' )
```
28.Find the customers without payments in 2003.

```MySQL
select customerNumber,
	customerName
from customers
where customerNumber not in (
		select customerNumber
		from payments
		where year(paymentDate)='2003')
order by 1;
```
</p>
</details>

### Correlated subqueries

<details>
<summary>Correlated subqueries questions 1-4</summary>

1.Who reports to Mary Patterson?

```MySQL
select e.employeeNumber,
	concat(e.firstName, ' ', e.lastName) as employee_name,
	e.jobTitle
from employees e
inner join employees m on e.reportsTo=m.employeeNumber
where concat(m.firstName, ' ', m.lastName)='Mary Patterson';
```
2.Which payments in any month and year are more than twice the average for that month and year. (i.e. compare all payments in Oct 2004 with the average payment for Oct 2004)? Order the results by the date of the payment. You will need to use the date functions.

```MySQL
with avg_amt as (
	select left(paymentDate,7) as m_y,
		avg(amount) as avg_amt_m_y
	from payments
	group by left(paymentDate,7) 
    ),

tot_amt as(
	select p.customerNumber,
		left(p.paymentDate,7) as m_y,
		sum(p.amount) as amt_m_y
	from payments p 
	group by left(p.paymentDate,7), p.customerNumber
)

select t.customerNumber,
	t.amt_m_y,
	t.m_y
from tot_amt t
inner join avg_amt a on t.m_y=a.m_y
where t.amt_m_y>a.avg_amt_m_y
order by 3;
```
3.Report for each product, the percentage value of its stock on hand as a percentage of the stock on hand for product line to which it belongs. 
Order the report by product line and percentage value within product line descending. Show percentages with two decimal places.

```MySQL
select p.productCode,
	p.productLine,
	round(100*(p.quantityInStock*p.buyPrice)/t.value_by_productline,2) as perct_val
from products p
left join (
	select productLine,
		sum(quantityInStock*buyPrice) as value_by_productline
	from products
	group by productLine
) t on p.productLine=t.productLine
order by 3 desc;
```
4.For orders containing more than two products, report those products that constitute more than 50% of the value of the order.

```MySQL
select *
from (
	select od.productCode,
		od.orderNumber,
		round(100*(od.quantityOrdered*od.priceEach)/t.val_ord,2) as perct
	from orderdetails od
	left join (
			select orderNumber,
				sum(quantityOrdered*priceEach) as val_ord
			from orderdetails
			group by orderNumber
			having count(distinct productCode)>2
	) t on od.orderNumber=t.orderNumber
		) tt
where tt.perct>50
order by 3 desc;
```
</p>
</details>

### Spatial data

<details>
<summary>Spatial data questions 1-6</summary>

The Offices and Customers tables contain the latitude and longitude of each office and customer in officeLocation and customerLocation, respectively, in POINT format. Conventionally, latitude and longitude and reported as a pair of points, with latitude first.

1.Which customers are in the Southern Hemisphere?

```MySQl
select customerName,
st_x(customerLocation) AS lat
from customers
where st_x(customerLocation) < 0;
```
-- 2.Which US customers are south west of the New York office?

```MySQL
select *
from customers c
inner join offices o
on o.state='NY'
and st_x(c.customerLocation)<st_x(o.officeLocation)
and st_y(c.customerLocation)<st_y(o.officeLocation);
```
-- 3.Which customers are closest to the Tokyo office (i.e., closer to Tokyo than any other office)?

-- 4.Which French customer is furthest from the Paris office?

-- 5.Who is the northernmost customer?

-- 6.What is the distance between the Paris and Boston offices?

-- To be precise for long distances, the distance in kilometers, as the crow flies, between two points when you have latitude and longitude, is (ACOS(SIN(lat1*PI()/180)*SIN(lat2*PI()/180)+COS(lat1*PI()/180)*COS(lat2*PI()/180)* COS((lon1-lon2)*PI()/180))*180/PI())*60*1.8532

</p>
</details>
