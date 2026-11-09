--Section A — SQL fundamentals — Retrieve all customer records.
--Q1 Display customer names, cities, and segments.
SELECT customer_name,city,customer_segment
FROM customers;

--Q2 Find customers living in Nairobi.
SELECT customer_name,city
FROM customers
WHERE city='Nairobi';
--Q3 Find customers registered after January 1, 2025.
SELECT customer_name, registration_date
FROM customers
WHERE registration_date >'2025-01-01';


--Q4 Display all unique customer cities.
SELECT DISTINCT city
FROM customers
ORDER BY city;

--Q5 Retrieve the 10 most recent orders.
SELECT order_id,product_name,unit_price, order_date
FROM orders
order by order_date desc
limit 10;

--Q6 Find orders with unit prices above KSh 10,000.
SELECT order_id, unit_price
FROM orders
where unit_price>10000;

--Q7 Find customers whose names start with A.
SELECT customer_name
FROM customers
WHERE customer_name like 'A%';
--Q8 Retrieve orders with quantities between 2 and 5.
SELECT product_name,quantity
FROM orders
WHERE quantity between 2 and 5;

--Q9 Find orders paid through M-Pesa.
SELECT product_name,payment_method
FROM orders
where payment_method='M-Pesa';

--Q10 Count all orders.
SELECT count(order_id) as total_orders
FROM orders;
--Q11 Calculate completed-order revenue.
SELECT  SUM(quantity * unit_price * (1 - discount / 100)) as completed_revenue
FROM orders
WHERE order_status='Completed';
--Q12 Calculate the average completed-order value.
SELECT AVG(quantity * unit_price * (1 - discount / 100)) as average_of_completed_orders
FROM orders
WHERE order_status ='Completed';
--Q13 Find the highest and lowest product prices.
SELECT  MAX(unit_price) AS highest_price, MIN(unit_price) as lowest_price
FROM orders;

--Q14 Calculate revenue by product category.
SELECT product_category, SUM(quantity * unit_price * (1 - discount / 100)) as completed_revenue
FROM orders
WHERE order_status='Completed'
GROUP BY product_category;
--Q15 Count customers by city.
SELECT  city,count(customer_id) as total_customers
FROM customers
group by city;
--Q16 Calculate quantity sold by product.
SELECT product_name, count(quantity) as total_quantity_sold
FROM orders
WHERE order_status='Completed'
GROUP BY product_name;
--Q17 Find categories generating more than KSh 100,000 in revenue.
SELECT product_category, SUM(quantity * unit_price * (1 - discount / 100)) as completed_revenue
FROM orders
WHERE order_status='Completed'
GROUP BY product_category
HAVING SUM(quantity * unit_price * (1 - discount / 100)) > 100000
ORDER BY completed_revenue desc;

--Q18 Calculate the percentage of cancelled orders.
SELECT COUNT(*)*100 as percentage_cancelled_order
FROM orders
WHERE order_status='Cancelled';
--Q21 Section C — Joins and customer analytics — Display orders with customer names and cities.
SELECT o.order_id,
    c.customer_name,
    c.city,
    o.order_date,
    o.quantity,
    o.unit_price
FROM orders o
JOIN customers c on o.customer_id=c.customer_id;

--22 Calculate total spending by customer.
SELECT o.order_id,
       c.customer_name,
	   o.quantity,
	   o.unit_price,
	   sum(o.quantity*o.unit_price) as total_spent
FROM orders o
 RIGHT JOIN customers c on o.customer_id=c.customer_id
group by o.order_id,c.customer_name;

--23 Identify customers who have never ordered.
SELECT o.order_id,
       c.customer_name,
	   o.product_name
FROM orders o
RIGHT JOIN customers c on C.customer_id=o.customer_id
WHERE o.product_name IS NULL;

--Q24 Find the 10 highest-spending customers.
SELECT o.order_id,
       c.customer_name,
	   o.quantity,
	   o.unit_price,
	   sum(o.quantity*o.unit_price) as total_spent
FROM orders o
RIGHT JOIN customers c on o.customer_id=c.customer_id
WHERE order_id IS NOT NULL
group by o.order_id,c.customer_name
ORDER BY total_spent DESC;
--Q25 Calculate revenue by customer city.
SELECT c.city,
	   ROUND(SUM(o.quantity * o.unit_price * (1 - discount / 100)),2)as revenue_per_city
FROM orders o
RIGHT JOIN customers c on o.customer_id=c.customer_id
group by c.city;
--Q26 Identify customers with more than five orders.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 5
ORDER BY total_orders DESC;
--Q27 Calculate average customer spending by segment.
SELECT c.customer_segment,
       AVG(o.quantity*o.unit_price) as Average_Spent_Per_Segment
FROM customers c
JOIN orders o on c.customer_id=o.customer_id
group by c.customer_segment;
--Q28 Identify the most popular category among VIP customers.
SELECT o.product_category,
    SUM(o.quantity * o.unit_price) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE c.customer_segment = 'VIP'
GROUP BY o.product_category
ORDER BY total_revenue DESC
LIMIT 1;
--Q29 Section D — Subqueries and CTEs — Find customers spending above the average total spending per purchasing customer.
WITH customer_spending AS (
    SELECT c.customer_id, c.customer_name,
        SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id,customer_name,
    ROUND(total_spending, 2) AS total_spending
FROM customer_spending
WHERE total_spending > (
    SELECT AVG(total_spending)
    FROM customer_spending
)
ORDER BY total_spending DESC;

--Q30 Find products priced above the overall average unit price.
WITH average_price AS (
    SELECT AVG(unit_price) AS avg_price
    FROM orders
)
SELECT product_name, unit_price
FROM orders
WHERE unit_price > (
    SELECT avg_price
    FROM average_price
)
ORDER BY unit_price DESC;
--Q31 Use a CTE to identify the three highest-revenue months.
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS sales_month,
        SUM(quantity * unit_price) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    sales_month,
    total_revenue
FROM monthly_revenue
ORDER BY total_revenue DESC
LIMIT 3;
--Q32 Find customers purchasing from at least three categories.
SELECT c.customer_id,c.customer_name,
    COUNT(DISTINCT o.product_category) AS total_categories
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(DISTINCT o.product_category) >= 3
ORDER BY total_categories DESC;
--Q33 Use a CTE to calculate category revenue, cost, profit, and profit margin.
WITH category_performance AS (
    SELECT product_category,SUM(quantity * unit_price) AS total_revenue,
        SUM(quantity * cost_price) AS total_cost
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category,total_revenue, total_cost,
    total_revenue - total_cost AS total_profit,
    ROUND((total_revenue - total_cost) * 100.0 /NULLIF(total_revenue, 0), 2
    ) AS profit_margin_percentage
FROM category_performance
ORDER BY total_profit DESC;
--Q34 Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.
WITH latest_completed_orders AS (
    SELECT customer_id, MAX(order_date) AS latest_completed_order
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
dataset_latest_date AS (
    SELECT MAX(order_date) AS latest_order_date
    FROM orders
)
SELECT c.customer_id,c.customer_name, l.latest_completed_order, d.latest_order_date,
    d.latest_order_date - l.latest_completed_order AS days_inactive
FROM customers c
JOIN latest_completed_orders l
    ON c.customer_id = l.customer_id
CROSS JOIN dataset_latest_date d
WHERE l.latest_completed_order < (
    SELECT MAX(order_date) - INTERVAL '90 days'
    FROM orders
)
ORDER BY l.latest_completed_order ASC;
--Q35 Section E — Window functions — Rank customers by spending using RANK().
WITH customer_spending AS (
    SELECT c.customer_id, c.customer_name,
        SUM(o.quantity * o.unit_price) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id,customer_name, total_spending,
    RANK() OVER (ORDER BY total_spending DESC ) AS spending_rank
FROM customer_spending
ORDER BY spending_rank;
--Q36 Number each customer's orders by recency using ROW_NUMBER().
SELECT customer_id,order_id,order_date,order_status,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC
    ) AS order_number
FROM orders
ORDER BY customer_id, order_number;
--Q37 Rank products within categories using DENSE_RANK().
WITH product_revenue AS (
    SELECT product_category,product_name,SUM(quantity * unit_price) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category, product_name
)
SELECT product_category,product_name,total_revenue, DENSE_RANK() OVER (PARTITION  BY product_category
        ORDER BY total_revenue DESC
    ) AS product_rank
FROM product_revenue
ORDER BY product_category, product_rank;

--Q38 Calculate cumulative monthly revenue.
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS sales_month,SUM(quantity * unit_price) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT sales_month,total_revenue,SUM(total_revenue) OVER ( ORDER BY sales_month ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY sales_month;
--Q39 Compare monthly revenue using LAG().
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS sales_month,SUM(quantity * unit_price) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT sales_month,total_revenue,
LAG(total_revenue) OVER (
        ORDER BY sales_month
    ) AS previous_month_revenue,total_revenue - LAG(total_revenue) OVER (
        ORDER BY sales_month
    ) AS revenue_difference
FROM monthly_revenue
ORDER BY sales_month;
--Q40 Calculate month-over-month revenue growth (%).

--Q41 Divide customers into four spending groups using NTILE(4).
--Q42 Calculate each category's share of total revenue using window functions.
WITH category_revenue AS (
    SELECT product_category,SUM(quantity * unit_price) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category,total_revenue,SUM(total_revenue) OVER () AS overall_revenue,
    ROUND(total_revenue * 100.0 /NULLIF(SUM(total_revenue) OVER (), 0), 2
    ) AS revenue_share_percentage
FROM category_revenue
ORDER BY revenue_share_percentage DESC;
--Q43 Section F — Advanced business intelligence — Create a monthly_sales_summary view (month, orders, revenue, cost, profit), then select from it.

--Q44 Create a PL/pgSQL function that returns completed-order revenue for a supplied customer ID — show it for one customer and for an ID that does not exist (it must return 0).

--Q45 Segment customers into High, Medium and Low Value, and explain why you chose your thresholds.

--Q46 Produce a management report: top five customers, top five products, the most profitable category, and the lowest-revenue month.




















