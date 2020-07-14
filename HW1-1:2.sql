-- Single entity
-- 1.Prepare a list of offices sorted by country, state, city.
select *
from offices
order by country, state, city;

-- 2.How many employees are there in the company?
select count(distinct employeenumber) as employee_total
from employees;

-- 3.What is the total of payments received?
select sum(amount) as amount_total
from payments;

-- 4.List the product lines that contain 'Cars'.
select *
from productlines
where productline like '%Cars%';

-- 5.Report total payments for October 28, 2004.
select sum(amount) as payment_on_a_day
from payments
where paymentdate='2004-10-28';

-- 6.Report those payments greater than $100,000.
select *
from payments
where amount>100000;

-- 7.List the products in each product line.
select *
from products
group by productline, productname
order by productline, productname;

-- 8.How many products in each product line?
select productline, count(distinct productcode) as product_cnt
from products
group by productline;

-- 9.What is the minimum payment received?
select *
from payments
order by amount
limit 1;

-- 10.List all payments greater than twice the average payment.
select *
from payments
where amount > (select 2*avg(amount) from payments);

-- 11.What is the average percentage markup of the MSRP on buyPrice? /*MSRP stands for manufacturer's suggested retail price*/
select round(100*avg(msrp/buyprice-1),2) as avg_percent_markup
from products;

-- 12.How many distinct products does ClassicModels sell?
select count(distinct productname) as prod_num
from products
where productvendor='Classicmodels';

-- 13.Report the name and city of customers who don't have sales representatives?
select customername,
	city
from customers
where salesrepemployeenumber is null;

-- 14.What are the names of executives with VP or Manager in their title? Use the CONCAT function to combine the employee's first name and last name into a single field for reporting.
select concat(firstname, ' ', lastname) as excutives_name,
	jobtitle
from employees
where jobtitle like '%VP%' or
	jobtitle like '%manager%';
    
-- 15.Which orders have a value greater than $5,000?
select ordernumber,
	sum(quantityordered*priceeach) as order_amt
from orderdetails
group by ordernumber
having order_amt>5000;

-- One to many relationship
-- 1.Report the account representative for each customer.
select concat(e.firstname,' ', e.lastname) as rep_for_cust, 
		c.*
from employees e
join customers c on e.employeenumber=c.salesrepemployeenumber;

-- 2.Report total payments for Atelier graphique.
select sum(amount) as tot_amt
from payments p
inner join customers c on c.customernumber=p.customernumber
where c.customername= 'Atelier graphique';

-- 3.Report the total payments by date.
select paymentdate,
	sum(amount) as tot_amt_by_date
from payments
group by paymentdate
order by 1;

-- 4.Report the products that have not been sold.
select *
from products
where productcode not in
(select productcode
from orderdetails);

-- 5.List the amount paid by each customer.
select o.customernumber, 
	c.customername, 
        sum(od.quantityordered*od.priceeach) as ord_amt
from customers c
inner join orders o on c.customernumber=o.customernumber
inner join orderdetails od on o.ordernumber=od.ordernumber
group by o.customernumber, o.ordernumber

-- 6.How many orders have been placed by Herkku Gifts?
select c.customername, 
	count(distinct ordernumber) as ord_num
from customers c
inner join orders o on c.customernumber=o.customernumber
where c.customername='Herkku Gifts'
group by 1;

-- 7.Who are the employees in Boston?
select e.*
from employees e
where officecode =
	(select officecode
	from offices
	where city='Boston')
    
-- 8.Report those payments greater than $100,000. 
-- Sort the report so the customer who made the highest payment appears first.
select c.customername, 
	p.*
from customers c
inner join payments p on c.customernumber=p.customernumber
where amount>100000
order by amount desc;

-- 9.List the value of 'On Hold' orders.
select od.ordernumber, 
	sum(od.quantityordered*od.priceeach) as ord_value
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
where o.status='On Hold'
group by 1;

-- 10.Report the number of orders 'On Hold' for each customer.
select c.customernumber, 
	c.customername, 
	count(distinct ordernumber) as ord_num_on_hold
from customers c
inner join orders o on c.customernumber=o.customernumber
where status='On Hold'
group by 1;

-- Many to many relationship
-- 1.List products sold by order date.
select p.productcode, 
		p.productname, 
		o.orderdate
from products p
inner join orderdetails od on p.productcode=od.productcode
inner join orders o on od.ordernumber=o.ordernumber
order by 3,1;

-- 2.List the order dates in descending order for orders for the 1940 Ford Pickup Truck.
select o.*
from products p
inner join orderdetails od on p.productcode=od.productcode
inner join orders o on od.ordernumber=o.ordernumber
where productname='1940 Ford Pickup Truck'
order by 3 desc;

-- 3.List the names of customers and their corresponding order number where a particular order from 
-- that customer has a value greater than $25,000?
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

-- 4.Are there any products that appear on all orders?
select productcode, 
	count(distinct ordernumber) as ord_num
from orderdetails
group by productcode
having ord_num=( select count(distinct ordernumber)
					from orders);

-- 5.Reports those products that have been sold with a markup of 100% or more (i.e.,  the priceEach is at least twice the buyPrice)
select p.*
from products p
left join orderdetails od on p.productcode=od.productcode
group by od.productcode
having (avg(od.priceeach)-p.buyprice)/p.buyprice>1;

-- 6.List the products ordered on a Monday.
select p.*,
	o.orderdate
from products p
inner join orderdetails od on p.productcode=od.productcode
inner join orders o on od.ordernumber=o.ordernumber
where weekday(orderdate)='Monday';

-- 7.What is the quantity on hand for products listed on 'On Hold' orders?
select p.productcode,
	p.productname,
	p.quantityinstock
from products p
inner join orderdetails od on p.productcode=od.productcode
inner join orders o on od.ordernumber=o.ordernumber
where o.status='On Hold'
order by 1;

-- Regular expressions
-- 1.Find products containing the name 'Ford'.
select *
from products
where productname like '%ford%';  /* case insensitive for character search*/

select *
from products
where productname regexp 'ford';

-- 2.List products ending in 'ship'.
select *
from products
where productname like '%ship';

select *
from products
where productname regexp 'ship$';

-- 3.Report the number of customers in Denmark, Norway, and Sweden.
select country,
	count(distinct customernumber) as cust_num
from customers
where country in ('Denmark', 'Norway', 'Sweden')
group by 1
order by 1;

-- 4.What are the products with a product code in the range S700_1000 to S700_1499?
select *
from products
where productcode between 'S700_1000' and 'S700_1499';

-- 5.Which customers have a digit in their name?
-- select *
-- from customers
-- where customername like '[0-9]';
select *
from customers
where customername regexp '[0-9]';

-- 6.List the names of employees called Dianne or Diane.
select lastname,
	firstname
from employees
where lastname regexp 'Dian{1,2}e'
or firstname regexp 'Dian{1,2}e';

-- 7.List the products containing ship or boat in their product name.
select productname
from products
where productname regexp 'ship|boat';

-- 8.List the products with a product code beginning with S700.
select productcode
from products
where productcode like 'S700%';

select productcode
from products
where productcode regexp '^S700';

-- 9.List the names of employees called Larry or Barry.
select lastname,
	firstname
from employees
where lastname regexp 'l|barry'
or firstname regexp 'l|barry';

-- 10.List the names of employees with non-alphabetic characters in their names.
select lastname,
	firstname
from employees
where lastname regexp '[^a-z]'
or firstname regexp '[^a-z]';

-- 11.List the vendors whose name ends in Diecast
select productvendor
from products
where productvendor regexp 'Diecast$';
