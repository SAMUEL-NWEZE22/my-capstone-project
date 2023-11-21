--creation of orders_table
CREATE TABLE orders_table(
	order_id INT PRIMARY KEY,
	date DATE,
	time TIME	
);

--creation of pizzas_types_table
CREATE TABLE pizzas_types_table(
	pizza_type_id VARCHAR (100) PRIMARY KEY,
	name  VARCHAR (100),	
	category VARCHAR (20),
	ingredients	 VARCHAR (500)
);

--creation of pizzas_table
CREATE TABLE pizzas_table(
	pizza_id VARCHAR (100) PRIMARY KEY,
	pizza_type_id VARCHAR (100)  REFERENCES pizzas_types_table (pizza_type_id),
	size VARCHAR (5),
	price DECIMAL (10,2)
);	

--creation of order_details
CREATE TABLE order_details(
	order_details_id INT,
	order_id INT  REFERENCES orders_table(order_id),
	pizza_id VARCHAR (100) REFERENCES pizzas_table(pizza_id),
	quantity INT
);
----QUESTIONS
---1. How many customers do we have each day?
SELECT 
    CASE
        WHEN EXTRACT(DOW FROM date) = 0 THEN 'SUNDAY'
        WHEN EXTRACT(DOW FROM date) = 1 THEN 'MONDAY'
        WHEN EXTRACT(DOW FROM date) = 2 THEN 'TUESDAY'
        WHEN EXTRACT(DOW FROM date) = 3 THEN 'WEDNESDAY'
        WHEN EXTRACT(DOW FROM date) = 4 THEN 'THURSDAY'
        WHEN EXTRACT(DOW FROM date) = 5 THEN 'FRIDAY'
        ELSE 'SATURDAY'
    END AS day_of_week,
    COUNT(*) AS no_of_customers
FROM orders_table
GROUP BY day_of_week
ORDER BY no_of_customers DESC;

--ARE there any peak hours?
SELECT
		CASE 
			WHEN DATE_PART('hour', time) = 0 THEN '00:00:00'
			WHEN DATE_PART('hour', time) = 1 THEN '01:00:00'
			WHEN DATE_PART('hour', time) = 2 THEN '02:00:00'
			WHEN DATE_PART('hour', time) = 3 THEN '03:00:00'
			WHEN DATE_PART('hour', time) = 4 THEN '04:00:00'
			WHEN DATE_PART('hour', time) = 5 THEN '05:00:00'
			WHEN DATE_PART('hour', time) = 6 THEN '06:00:00'
			WHEN DATE_PART('hour', time) = 7 THEN '07:00:00'
			WHEN DATE_PART('hour', time) = 8 THEN '08:00:00'
			WHEN DATE_PART('hour', time) = 9 THEN '09:00:00'
			WHEN DATE_PART('hour', time) = 10 THEN '10:00:00'
			WHEN DATE_PART('hour', time) = 11 THEN '11:00:00'
			WHEN DATE_PART('hour', time) = 12 THEN '12:00:00'
			WHEN DATE_PART('hour', time) = 13 THEN '13:00:00'
			WHEN DATE_PART('hour', time) = 14 THEN '14:00:00'
			WHEN DATE_PART('hour', time) = 15 THEN '15:00:00'
			WHEN DATE_PART('hour', time) = 16 THEN '16:00:00'
			WHEN DATE_PART('hour', time) = 17 THEN '17:00:00'
			WHEN DATE_PART('hour', time) = 18 THEN '18:00:00'
			WHEN DATE_PART('hour', time) = 19 THEN '19:00:00'
			WHEN DATE_PART('hour', time) = 20 THEN '20:00:00'
			WHEN DATE_PART('hour', time) = 21 THEN '21:00:00'
			WHEN DATE_PART('hour', time) = 22 THEN '22:00:00'
			WHEN DATE_PART('hour', time) = 23 THEN '23:00:00'
		ELSE '24:00:00'
		END AS hour_of_the_day,
		COUNT(*) AS no_of_orders
FROM orders_table
GROUP BY DATE_PART('hour', time)
ORDER BY no_of_orders DESC
LIMIT 5;

---2. How many pizzas are typically in an order? Do we have any bestsellers?
SELECT
'There are ' ||	CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2)) || ' pizza per order' AS avg_no_of_pizza  
FROM order_details;


--Do we have any bestsellers?
SELECT pizzas_types_table.name,
	CAST(SUM(quantity * price) AS DECIMAL(10,0)) AS Revenue
FROM order_details
INNER JOIN pizzas_table ON order_details.pizza_id = pizzas_table.pizza_id
INNER JOIN pizzas_types_table ON pizzas_table.pizza_type_id = pizzas_types_table.pizza_type_id
GROUP BY pizzas_types_table.name
ORDER BY Revenue DESC
LIMIT 5;


---3. How much money did we make this year?  
SELECT
	'We made $ ' || SUM(quantity * price) || ' as profit for the year' AS profit_for_the_year
FROM order_details
INNER JOIN pizzas_table ON order_details.pizza_id = pizzas_table.pizza_id;

--Can we identify any seasonality in the sales?

SELECT CASE
			WHEN DATE_PART('month', date) = 1 THEN 'January'
			WHEN DATE_PART('month', date) = 2 THEN 'February'
			WHEN DATE_PART('month', date) = 3 THEN 'March'
			WHEN DATE_PART('month', date) = 4 THEN 'April'
			WHEN DATE_PART('month', date) = 5 THEN 'May'
			WHEN DATE_PART('month', date) = 6 THEN 'June'
			WHEN DATE_PART('month', date) = 7 THEN 'July'
			WHEN DATE_PART('month', date) = 8 THEN 'August'
			WHEN DATE_PART('month', date) = 9 THEN 'September'
			WHEN DATE_PART('month', date) = 10 THEN 'October'
			WHEN DATE_PART('month', date) = 11 THEN 'November'
			ELSE 'December'
		END AS months,
	COUNT(*) AS total_orders
FROM orders_table
GROUP BY months
ORDER BY total_orders DESC;

---4. Are there any pizzas we should take of the menu?
 SELECT pizzas_types_table.pizza_type_id, name,
 		SUM(quantity) AS pizza_sold
FROM pizzas_types_table
INNER JOIN pizzas_table ON pizzas_types_table.pizza_type_id = pizzas_table.pizza_type_id
INNER JOIN order_details ON pizzas_table.pizza_id = order_details.pizza_id
GROUP BY pizzas_types_table.pizza_type_id, name
ORDER BY pizza_sold
LIMIT 5;

--or any promotions we could leverage?
 SELECT pizzas_types_table.pizza_type_id, name,
 	SUM(quantity) AS pizza_sold
FROM pizzas_types_table
INNER JOIN pizzas_table ON pizzas_types_table.pizza_type_id = pizzas_table.pizza_type_id
INNER JOIN order_details ON pizzas_table.pizza_id = order_details.pizza_id
GROUP BY pizzas_types_table.pizza_type_id, name
ORDER BY pizza_sold DESC
LIMIT 5;
