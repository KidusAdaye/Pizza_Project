#Local pizza store sales project

#Total Sales per quarter for 2015

SELECT
	QUARTER(o.date) as Quarter_,
	CONCAT('$', ROUND(SUM(od.quantity * p.price),2)) as Quarter_Sales
FROM 
	PizzaProject.order_details od
JOIN 
	PizzaProject.pizzas p ON od.pizza_id = p.pizza_id
JOIN
    PizzaProject.orders o ON o.order_id = od.order_id
GROUP BY 
	QUARTER(o.date)
;

# Count of orders and quantities sold by month

SELECT 
	MONTHNAME(o.date) as Month,
    COUNT(DISTINCT(od.order_id)) as Number_of_orders,
    SUM(od.quantity) as Quantity_of_Pizzas_Sold
FROM 
	PizzaProject.order_details od
JOIN 
	PizzaProject.orders o ON o.order_id = od.order_id
GROUP BY  
	MONTHNAME(o.date)
ORDER BY
	MONTHNAME(o.date)
;
    
# Count of orders and quantities sold by day of the week 

SELECT 
    DAYNAME(o.date) as Day_of_week,
    COUNT(DISTINCT(od.order_id)) as Number_of_orders,
    SUM(od.quantity) as Quantity_of_Pizzas_Sold
FROM 
	PizzaProject.order_details od
JOIN 
	PizzaProject.orders o ON o.order_id = od.order_id
GROUP BY  
	DAYNAME(o.date)
ORDER BY 
	FIELD(Day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
;

# Count of orders and quantities sold by hour of day

SELECT 
    EXTRACT(HOUR FROM o.time) as Hour_of_day,
    COUNT(DISTINCT(od.order_id)) as Number_of_orders,
    SUM(od.quantity) as Quantity_of_Pizzas_Sold
FROM 
	PizzaProject.order_details od
JOIN 
	PizzaProject.orders o ON o.order_id = od.order_id
GROUP BY  
	EXTRACT(HOUR FROM o.time)
;

# Quantity of every pizza sold by month

with r as (
SELECT
	pt.name as Pizza_name,
    SUM(od.quantity) as quantity,
    MONTH(o.date) as month
FROM 
	PizzaProject.order_details od
JOIN 
	PizzaProject.pizzas p ON p.pizza_id = od.pizza_id
JOIN 
	PizzaProject.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
JOIN 
	PizzaProject.orders o ON o.order_id = od.order_id
GROUP BY 
	pt.name,
    MONTH(o.date)
)

SELECT 
	r.Pizza_name,
    SUM(CASE WHEN month = 1 THEN quantity ELSE 0 END) AS 'Jan',
    SUM(CASE WHEN month = 2 THEN quantity ELSE 0 END) AS 'Feb',
    SUM(CASE WHEN month = 3 THEN quantity ELSE 0 END) AS 'Mar',
    SUM(CASE WHEN month = 4 THEN quantity ELSE 0 END) AS 'Apr',
    SUM(CASE WHEN month = 5 THEN quantity ELSE 0 END) AS 'May',
    SUM(CASE WHEN month = 6 THEN quantity ELSE 0 END) AS 'Jun',
    SUM(CASE WHEN month = 7 THEN quantity ELSE 0 END) AS 'Jul',
    SUM(CASE WHEN month = 8 THEN quantity ELSE 0 END) AS 'Aug',
    SUM(CASE WHEN month = 9 THEN quantity ELSE 0 END) AS 'Sep',
    SUM(CASE WHEN month = 10 THEN quantity ELSE 0 END) AS 'Oct',
    SUM(CASE WHEN month = 11 THEN quantity ELSE 0 END) AS 'Nov',
    SUM(CASE WHEN month = 12 THEN quantity ELSE 0 END) AS 'Dec'
FROM
	r
GROUP BY 
	Pizza_name
ORDER BY 
	Pizza_name
;

# Quantity sold and revenue gained from most popular sizes 

SELECT
	p.size as Pizza_size,
    SUM(quantity) as Number_of_pizzas,
    SUM(CAST(p.price as decimal(10,2))) as Revenue_per_size
FROM 
	PizzaProject.order_details od
JOIN 
	PizzaProject.pizzas p ON p.pizza_id = od.pizza_id
GROUP BY 
	p.size
ORDER BY
CASE 
	WHEN p.size = 'S' THEN 1
	WHEN p.size = 'M' THEN 2
	WHEN p.size = 'L' THEN 3
	WHEN p.size = 'XL' THEN 4
	WHEN p.size = 'XXL' THEN 5
	END
;

# Quantity sold and revenue ganied from most popular category of pizza

SELECT 
	pt.category as Pizza_category,
    SUM(od.quantity) AS Number_of_pizzas,
    SUM(CAST(p.price as decimal(10,2))) as Revenue_per_category
FROM 
	PizzaProject.order_details od
JOIN 
	PizzaProject.pizzas p ON p.pizza_id = od.pizza_id
JOIN 
	PizzaProject.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY 
	pt.category
ORDER BY 
	Number_of_pizzas DESC
;

# Average revenue per order

SELECT
    CONCAT('$', FORMAT(AVG(order_revenue), 2)) AS Average_Revenue_Per_Order
FROM (
    SELECT
        o.order_id,
        SUM(od.quantity * p.price) AS order_revenue
    FROM
        PizzaProject.order_details od
    JOIN
        PizzaProject.pizzas p ON p.pizza_id = od.pizza_id
    JOIN
        PizzaProject.orders o ON o.order_id = od.order_id
    GROUP BY
        o.order_id
) AS order_revenues
;

# Total Revenue of every pizza 

with s as (
SELECT 
	pt.name as name,
    p.price * SUM(od.quantity) as Total_revenue
FROM
	PizzaProject.order_details od
JOIN 
	PizzaProject.pizzas p ON p.pizza_id = od.pizza_id
JOIN 
	PizzaProject.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY 
	pt.name,
    p.price
)

SELECT 
	s.name as name,
	CONCAT('$', FORMAT(SUM(s.Total_revenue), 2)) as Total_revenue
FROM 
	s
GROUP BY
	s.name
ORDER BY
	Total_revenue DESC
;
    
# Number of pizzas with each ingredient using a temp table 

DROP TEMPORARY TABLE IF EXISTS pizza_ingredients;
CREATE TEMPORARY TABLE pizza_ingredients (
	id int AUTO_INCREMENT PRIMARY KEY,
    ingredients varchar(255)
);


INSERT INTO pizza_ingredients (ingredients)
SELECT DISTINCT SUBSTRING_INDEX(SUBSTRING_INDEX(pt.ingredients, ',', n), ',', -1) AS value
FROM PizzaProject.pizza_types pt
JOIN (
    SELECT 1 AS n UNION ALL
    SELECT 2 UNION ALL
    SELECT 3 
) AS numbers ON CHAR_LENGTH(pt.ingredients)
             - CHAR_LENGTH(REPLACE(pt.ingredients, ',', '')) >= n - 1;

SELECT * FROM pizza_ingredients;

SELECT
	pi.ingredients,
    COUNT(DISTINCT pt.name) as Number_of_pizzas
FROM 
	PizzaProject.pizza_ingredients pi,
    PizzaProject.pizza_types pt 
WHERE 
	pt.ingredients LIKE CONCAT('%', pi.ingredients, '%')
GROUP BY 
	pi.ingredients
ORDER BY
	Number_of_pizzas DESC
;
    


    
    






	









