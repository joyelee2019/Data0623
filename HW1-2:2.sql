-- General queries
-- 1.Who is at the top of the organization (i.e.,  reports to no one).
select *
from employees
where reportsto is null

-- 2.Who reports to William Patterson?
select e.*
from employees e
inner join employees m on e.reportsto=m.employeenumber
and concat(m.firstname, ' ', m.lastname)='William Patterson';

-- 3.List all the products purchased by Herkku Gifts.
select p.*
from products p
inner join orderdetails od on p.productCode=od.productCode
inner join orders o on od.ordernumber=o.ordernumber
inner join customers c on o.customernumber=c.customernumber
where c.customername='Herkku Gifts';

-- 4.Compute the commission for each sales representative, assuming the commission is 5% of the value of an order. Sort by employee last name and first name.
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

-- 5.What is the difference in days between the most recent and oldest order date in the Orders file?
select t.latest_date-oldest_date as diff_day
from
(select (select orderdate from orders order by 1 desc limit 1) as latest_date,
		(select orderdate from orders order by 1 limit 1) as oldest_date
        ) t

-- 6.Compute the average time between order date and ship date for each customer ordered by the largest difference.
select customernumber,
		round(avg(shippeddate-orderdate),2) as diff
from orders
where status='shipped'
group by 1
order by 2 desc

-- 7.What is the value of orders shipped in August 2004? (Hint).
select od.ordernumber,
		sum(od.quantityordered*od.priceeach) as ord_amt
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
where month(o.shippeddate)='8'
and o.status='shipped'
group by od.ordernumber
order by 2 desc;

-- 8.Compute the total value ordered, total amount paid, and their difference for each customer for orders placed in 2004 and payments received in 2004 
-- (Hint; Create views for the total paid and total ordered).
select o.customernumber,
		sum(od.quantityordered*od.priceeach)-sum(p.amount) as payable_amt
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
inner join payments p on o.customernumber=p.customernumber
where year(o.orderdate)='2004'
and year(p.paymentdate)='2004'
and o.status!='cancelled'
group by o.customerNumber;

-- 9.List the employees who report to those employees who report to Diane Murphy. Use the CONCAT function to combine 
-- the employee's first name and last name into a single field for reporting.
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

-- 10.What is the percentage value of each product in inventory sorted by the highest percentage first (Hint: Create a view first).
select *,
round(100*sum(quantityinstock)/ (select sum(quantityinstock) from products),2) as percent_invt
from products
group by productCode
order by 10 desc;

-- 11.Write a function to convert miles per gallon to liters per 100 kilometers.
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

-- 12.Write a procedure to increase the price of a specified product category by a given percentage. 
-- You will need to create a product table with appropriate data to test your procedure. 
-- Alternatively, load the ClassicModels database on your personal machine so you have complete access. 
-- You have to change the DELIMITER prior to creating the procedure.
delimiter $$

create procedure GetPriceIncreased()
begin
 
select 1.1*buyprice
from products
where productCode like 'S32%';
 
end $$

delimiter ;

call GetPriceIncreased();

-- 13.What is the value of orders shipped in August 2004? (Hint).
select od.ordernumber,
		sum(od.quantityordered*od.priceeach) as ord_amt
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
where left(o.shippeddate,7)='2004-08'
and o.status='shipped'
group by od.ordernumber
order by 2 desc;

-- 14.What is the ratio the value of payments made to orders received for each month of 2004. (i.e., divide the value of payments made by the orders received)?
select left(o.orderDate,7) as months,
		round(100*sum(p.amount)/sum(od.quantityordered*od.priceeach),2) as payment_ratio
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber and year(o.orderdate)='2004'
inner join payments p on o.customernumber=p.customernumber and year(p.paymentdate)='2004'
where o.status!='cancelled'
group by 1
order by 1;

-- 15.What is the difference in the amount received for each month of 2004 compared to 2003?
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

-- 16.Write a procedure to report the amount ordered in a specific month and year for customers containing a specified character string in their name.
delimiter $$

create procedure GetAmountOrdered()
begin
 
select c.customernumber,
		c.customername,
		sum(od.quantityordered*od.priceeach) as amt_ordered
from orderdetails od
inner join orders o on od.ordernumber=o.ordernumber
inner join customers c on o.customernumber=c.customernumber
where left(o.orderdate,7)='2004-07'
and c.customername like 'A%'
and o.status!='cancelled'
group by o.customerNumber;
 
end $$

delimiter ; 

call GetAmountOrdered();

-- 17.Write a procedure to change the credit limit of all customers in a specified country by a specified percentage.
delimiter $$

create procedure ChangeCreditLimit()
begin

select customerNumber,
		customerName,
		contactLastName,
		contactFirstName,
		country,
		round(1.15*creditLimit,2) as IncreasedCreditLimit
from customers
where country='Germany';

end $$

delimiter ;

call ChangeCreditLimit();

-- 18.Basket of goods analysis: A common retail analytics task is to analyze each basket or order to learn what products are often purchased together. 
-- Report the names of products that appear in the same order ten or more times.

-- 19.ABC reporting: Compute the revenue generated by each customer based on their orders. Also, show each customer's revenue as a percentage of total revenue. Sort by customer name.

-- 20.Compute the profit generated by each customer based on their orders. Also, show each customer's profit as a percentage of total profit. Sort by profit descending.

-- 21.Compute the revenue generated by each sales representative based on the orders from the customers they serve.

-- 22.Compute the profit generated by each sales representative based on the orders from the customers they serve. Sort by profit generated descending.

-- 23.Compute the revenue generated by each product, sorted by product name.

-- 24.Compute the profit generated by each product line, sorted by profit descending.

-- 25.Same as Last Year (SALY) analysis: Compute the ratio for each product of sales for 2003 versus 2004.

-- 26.Compute the ratio of payments for each customer for 2003 versus 2004.

-- 27.Find the products sold in 2003 but not 2004.

-- 28.Find the customers without payments in 2003.

-- Correlated subqueries
-- 1.Who reports to Mary Patterson?

-- 2.Which payments in any month and year are more than twice the average for that month and year (i.e. compare all payments in Oct 2004 with the average payment for Oct 2004)? Order the results by the date of the payment. You will need to use the date functions.

-- 3.Report for each product, the percentage value of its stock on hand as a percentage of the stock on hand for product line to which it belongs. 
-- Order the report by product line and percentage value within product line descending. Show percentages with two decimal places.

-- 4.For orders containing more than two products, report those products that constitute more than 50% of the value of the order.

-- Spatial data
-- The Offices and Customers tables contain the latitude and longitude of each office and customer in officeLocation and customerLocation, respectively, in POINT format. Conventionally, latitude and longitude and reported as a pair of points, with latitude first.
-- 1.Which customers are in the Southern Hemisphere?
-- 2.Which US customers are south west of the New York office?
-- 3.Which customers are closest to the Tokyo office (i.e., closer to Tokyo than any other office)?
-- 4.Which French customer is furthest from the Paris office?
-- 5.Who is the northernmost customer?
-- 6.What is the distance between the Paris and Boston offices?
-- To be precise for long distances, the distance in kilometers, as the crow flies, between two points when you have latitude and longitude, is (ACOS(SIN(lat1*PI()/180)*SIN(lat2*PI()/180)+COS(lat1*PI()/180)*COS(lat2*PI()/180)* COS((lon1-lon2)*PI()/180))*180/PI())*60*1.8532