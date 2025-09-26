--Analysis 1

select * from amazon_brazil.payments;
select * from amazon_brazil.order_items;

--Round the average payment values to integer (no decimal) 
--for each payment type and display the results sorted in ascending order.

select payment_type, Round(avg(payment_value),0) as 
rounded_avg_payment from amazon_brazil.payments
group by payment_type
order by rounded_avg_payment asc;


--Calculate the percentage of total orders for each payment type, rounded to one decimal place, 
--and display them in descending order

select payment_type, 
Round((count(distinct order_id) * 100 / sum(count(distinct order_id)) over()),1) 
as percentage_orders from amazon_brazil.payments
group by payment_type
order by percentage_orders desc;


SELECT 
    payment_type,
    ROUND(CAST(COUNT(DISTINCT order_id) AS NUMERIC) * 100.0 / 
         (SELECT COUNT(DISTINCT order_id) FROM amazon_brazil.payments), 1) AS percentage_orders
FROM amazon_brazil.payments
GROUP BY payment_type
ORDER BY percentage_orders DESC


--Identify all products priced between 100 and 500 BRL that contain the word 'Smart' in their name. Display these products, 
--sorted by price in descending order.
select o.product_id,
o.price
from amazon_brazil.order_items as o
join amazon_brazil.product  as p
on o.product_id=p.product_id
where o.price  between 100 and 500
and p.product_category_name like '%smart%'
order by o.price Desc;


--Determine the top 3 months with the highest total sales value, 
--rounded to the nearest integer.

select extract (month  from  order_purchase_timestamp) as month,
round(sum(oi.price)) as total_sales
from amazon_brazil.orders as o
join amazon_brazil.order_items as oi
on o.order_id=oi.order_id
group by extract (month  from  order_purchase_timestamp)
order by total_sales desc limit 3;

--Find categories where the difference between the maximum and minimum 
--product prices is greater than 500 BRL.

select product_category_name , max(oi.price)- min(oi.price) as price_difference from
amazon_brazil.product p 
join amazon_brazil.order_items oi
on p.product_id=oi.product_id
group by p.product_category_name
having max(oi.price) - min(oi.price)> 500 
order by price_difference desc;


--Identify the payment types with the least variance in transaction amounts, 
--sorting by the smallest standard deviation first.


select payment_type,
round(StdDev(payment_value),2)as std_deviation
from amazon_brazil.payments
group by payment_type
order by std_deviation asc;

--Retrieve the list of products where the product category 
--name is missing or contains only a single character.

SELECT 
product_id, 
product_category_name
FROM amazon_brazil.product
WHERE 
product_category_name IS NULL
OR LENGTH(product_category_name) = 1;


--Analysis 2

select * from amazon_brazil.customer;


--Identify Popular Payment Types by Order Value Segments

select payment_type, count(*) as count_payment, 
CASE
 when payment_value < 200 THEN 'low'
 when payment_value Between 200 AND 1000 THEN 'medium'
 when payment_value > 100 THEN 'high'
 END AS segment from amazon_brazil.payments
 group by payment_type, CASE
 when payment_value < 200 THEN 'low'
 when payment_value Between 200 AND 1000 THEN 'medium'
 when payment_value > 100 THEN 'high'
 END
 order by count_payment;


--Calculate the minimum, maximum, and average price for each category, 
--and list them in descending order by the average price.
SELECT 
    product_category_name,
    MIN(oi.price) AS min_price, 
    MAX(oi.price) AS max_price, 
    ROUND(AVG(oi.price), 2) AS avg_price
FROM 
    amazon_brazil.product p join amazon_brazil.order_items oi
	on p.product_id=oi.product_id
GROUP BY 
    product_category_name
ORDER BY 
    avg_price DESC;

--Find all customers with more than one order,
--and display their customer unique IDs along with the total number of orders they have placed.	

SELECT customer_unique_id, 
COUNT(order_id) AS total_orders
FROM amazon_brazil.orders o
JOIN amazon_brazil.customer c 
ON o.customer_id = c.customer_id
GROUP BY customer_unique_id
HAVING COUNT(order_id) > 1;

 --Use a temporary table to define these categories and join it with the customers table to 
 --update and display the customer types
WITH CustomerOrderCounts AS (
    SELECT customer_id, 
    COUNT(order_id) AS total_orders
    FROM amazon_brazil.orders
    GROUP BY customer_id
)
SELECT customer_id,
       CASE 
           WHEN total_orders = 1 THEN 'New'
           WHEN total_orders BETWEEN 2 AND 4 THEN 'Returning'
           ELSE 'Loyal'
       END AS customer_type
FROM CustomerOrderCounts
ORDER BY customer_id;


--Use joins between the tables to calculate the total 
--revenue for each product category. Display the top 5 categories.

select p.product_category_name, sum(oi.price)
as total_revenue from amazon_brazil.product p
join amazon_brazil.order_items oi 
on p.product_id=oi.product_id
group by p.product_category_name
order by total_revenue desc 
limit 5;


--Analyis 3

--Use a subquery to calculate total sales for each season 
--(Spring, Summer, Autumn, Winter) 
SELECT 
    CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (6, 7, 8) THEN 'Summer'
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (9, 10, 11) THEN 'Autumn'
        ELSE 'Winter'
    END AS season,
    SUM(oi.price) AS total_sales
FROM 
    amazon_brazil.orders o
INNER JOIN 
   amazon_brazil.order_items oi
ON 
    o.order_id = oi.order_id
GROUP BY 
    season
ORDER BY 
    season;


 --Write a query that uses a subquery to filter products with a 
 --total quantity sold above the average quantity.
 SELECT product_id, total_quantity_sold
FROM (
    SELECT product_id, COUNT(order_item_id) AS total_quantity_sold
    FROM amazon_brazil.order_items
    GROUP BY product_id) 
WHERE total_quantity_sold > (
    SELECT AVG(total_quantity_sold)
FROM ( SELECT COUNT(order_item_id) AS total_quantity_sold
FROM amazon_brazil.order_items
GROUP BY product_id 
));

--Create a segmentation based on purchase frequency: 
--‘Occasional’ for customers with 1-2 orders, ‘Regular’ for 3-5 orders,
--and ‘Loyal’ for more than 5 orders. Use a CTE
--to classify customers and their count and generate a chart in Excel to 
--show the proportion of each segment.
WITH cte AS(
	SELECT customer_id ,
		   CASE WHEN COUNT(order_id) <= 2 THEN 'Occasional'
	   	   WHEN COUNT(order_id) BETWEEN 3 AND 5 THEN 'Regular'
	       WHEN COUNT(order_id) > 5 THEN 'Loyal'
	       END AS customer_type
	FROM amazon_brazil.orders
	GROUP BY customer_id
)
SELECT  customer_type,
		COUNT(customer_id) AS count
FROM cte 
GROUP BY customer_type;

--Run a query to calculate total revenue generated each month
--and identify periods of peak and low sales.

SELECT EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month, 
       SUM(oi.price) AS total_revenue
FROm amazon_brazil.orders o
JOIN amazon_brazil.order_items oi ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY month
ORDER BY month;

--You are required to rank customers based on their average order 
--value (avg_order_value) to find the top 20 customers.
WITH CustomerOrderValue AS (
    SELECT customer_id, 
           AVG(price) AS avg_order_value
    FROM amazon_brazil.orders o
    JOIN amazon_brazil.order_items oi
	ON o.order_id = oi.order_id
    GROUP BY customer_id
)
SELECT customer_id, 
       avg_order_value, 
       RANK() OVER (ORDER BY avg_order_value DESC) 
	   AS customer_rank
FROM CustomerOrderValue
ORDER BY avg_order_value DESC
LIMIT 20;


--Calculate monthly cumulative sales for each product from the date of its first sale. Use a recursive CTE to compute the cumulative sales (total_sales) 
--for each product month by month.
WITH MonthlySales AS (
    SELECT 
        product_id, 
        TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp), 'YYYY-MM') AS sale_month, 
        SUM(oi.price) AS monthly_sales
    FROM amazon_brazil.orders o
    JOIN amazon_brazil.order_items oi ON o.order_id = oi.order_id
    GROUP BY product_id, sale_month 
)
SELECT 
    product_id, 
    sale_month, 					
    monthly_sales,
    SUM(monthly_sales) OVER (PARTITION BY product_id ORDER BY sale_month) AS total_sales 
FROM MonthlySales
ORDER BY product_id, sale_month;

--Write query to first calculate total monthly sales for each payment method, then compute the percentage
--change from the previous month.

WITH MonthlyPaymentSales AS (
    SELECT  p.payment_type, 
        TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp), 'YYYY-MM') AS sale_month, 
        SUM(oi.price) AS monthly_total
    FROM amazon_brazil.orders o
    JOIN amazon_brazil.order_items oi ON o.order_id = oi.order_id
    JOIN amazon_brazil.payments p ON o.order_id = p.order_id
    WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018 
    GROUP BY p.payment_type, sale_month
)
SELECT 
    payment_type, 
    sale_month, 
    monthly_total,
    ROUND(((monthly_total - LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month)) / 
           LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month)) * 100, 2) AS monthly_change
FROM MonthlyPaymentSales
ORDER BY payment_type, sale_month;






























