select product_id, product_name, list_price
FROM production.products
WHERE list_price > 1000;

select customer_id, first_name, last_name, state
FROM sales.customers where state in('ca','ny');

select  order_id, customer_id, order_date
from sales.orders where year(order_date)=2023;

SELECT customer_id, first_name, last_name, email
FROM sales.customers
WHERE email LIKE '%@gmail.com';

select staff_id, first_name, last_name, active
from sales.staffs where active=0;

select top 5 product_id, product_name, list_price
from production.products 
order by list_price desc 
;

select top 10 order_id,customer_id, order_date
FROM sales.orders
order by order_date desc;

select top 3 customer_id, first_name, last_name
FROM sales.customers 
order by last_name asc;

select customer_id, first_name, last_name, phone
FROM sales.customers 
where phone is null or phone =' ';

select staff_id, first_name, last_name, manager_id
FROM sales.staffs
WHERE manager_id IS NOT NULL;

SELECT category_id, COUNT(*) AS product_count
FROM production.products
GROUP BY category_id;

SELECT state, COUNT(*) AS customer_count
FROM sales.customers
GROUP BY state;

select brand_id ,avg(list_price) as avg_price
from production.products
group by brand_id;

SELECT staff_id, COUNT(*) AS order_count
FROM sales.orders
GROUP BY staff_id;

select customer_id,count(*) as order_count
from sales.orders
group by customer_id
having count(*)>2;

select product_id,product_name,list_price 
from production.products
where list_price between 500 and 1500;

select customer_id,first_name,last_name,city
from sales.customers
where city like 's%';

select order_id,customer_id, order_status
FROM sales.orders
WHERE order_status IN (2, 4);

SELECT product_id, product_name, category_id
FROM production.products
WHERE category_id IN (1, 2, 3);

SELECT staff_id, first_name, last_name, store_id, phone
FROM sales.staffs
WHERE store_id = 1 OR phone IS NULL ;
 


