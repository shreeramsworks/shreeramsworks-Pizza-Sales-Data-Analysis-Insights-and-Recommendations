use pizaa_sales_project;
select * from order_details;
select * from  orders;
select * from pizza_types;
select * from  pizzas;

-- Retrieve the total number of orders placed:

select count(order_id) as totals from  orders;

-- Calculate the total revenue generated from pizza sales:

select round(sum(pizzas.price*order_details.quantity),2) as total_revenue
from pizzas
join order_details on order_details.pizza_id=pizzas.pizza_id;

-- Identify the highest-priced pizza.

select max(price) from pizzas;

-- Identify the most common pizza size ordered.

select pizzas.size ,count(pizzas.pizza_id) as total from pizzas
join order_details on order_details.pizza_id=pizzas.pizza_id
group by 1
order by total desc
;

-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name,pizza_types.category,sum(order_details.quantity) as total_quantity from pizza_types
join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by 1,2
order by total_quantity desc
limit 5
;

-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category,sum(order_details.quantity) as total_quantity from pizza_types
join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by 1
order by total_quantity desc
;

-- Determine the distribution of orders by hour of the day.

select hour(time),count(order_id) as orders from orders
group by 1
order by orders desc ;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity) )from 
(select orders.date,sum(order_details.quantity) as quantity from orders
join order_details on order_details.order_id=orders.order_id
group by 1) as ordered_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(order_details.quantity*pizzas.price) as revenue from  order_details      
join pizzas on  pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by 1
order by revenue desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,(sum(order_details.quantity*pizzas.price)  / (select round(sum(pizzas.price*order_details.quantity),2) as total_revenue
from pizzas
join order_details on order_details.pizza_id=pizzas.pizza_id))*100 as rivenue
from  order_details  
join pizzas on  pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by 1;

-- Analyze the cumulative revenue generated over time.

select date, sum(rivenue) over(partition by date) as cumulative_rivenue
from
(select orders.date, sum(order_details.quantity*pizzas.price) as rivenue
from orders
join order_details on order_details.order_id=orders.order_id
join pizzas on  pizzas.pizza_id = order_details.pizza_id
group by 1
) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name,ranking from
(select category,name, rivenue, rank() over(partition by category order by rivenue desc) as ranking  from 
(select pizza_types.category as category,pizza_types.name as name,sum((order_details.quantity)*pizzas.price) as rivenue from order_details      
join pizzas on  pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by 1,2) as total) as b
where ranking<=3;

