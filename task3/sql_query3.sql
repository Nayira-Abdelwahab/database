select count(*) as total_products
from production.products;

select avg(list_price) AS average_price,
max(list_price)AS maximum_price,min(list_price)AS minimum_price
from production.products;

select category_id,count(*) as product_count
from production.products group by category_id;

select store_id,count(*) as order_count
from sales.stores group by store_id;


select top 10 UPPER(first_name) AS first_name_upper,
    LOWER(last_name) AS last_name_lower
FROM sales.customers;

select top 10 product_name,len(product_name) as name_length
from production.products;

select top 15 customer_id,substring(phone,1,3) as area_code
from sales.customers;

select top 10 order_id,getdate() as today,
year(order_date) as order_year,
month(order_date) as order_month
FROM sales.orders;

select top 10 p.product_name ,c.category_name
from production.products p join production.categories c
on p.category_id=c.category_id;

select top 10
    c.first_name + ' ' + c.last_name AS customer_name,
    o.order_date
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id;

SELECT 
    p.product_name,
    COALESCE(b.brand_name, 'No Brand') AS brand_name
FROM production.products p
LEFT JOIN production.brands b ON p.brand_id = b.brand_id;

SELECT 
    product_name, list_price
FROM production.products
WHERE list_price > (SELECT AVG(list_price) FROM production.products);

SELECT 
    customer_id, 
    first_name + ' ' + last_name AS customer_name
FROM sales.customers
WHERE customer_id IN (SELECT DISTINCT customer_id FROM sales.orders);

SELECT 
    first_name + ' ' + last_name AS customer_name,
	(SELECT COUNT(*) FROM sales.orders o WHERE o.customer_id = c.customer_id) AS total_orders
FROM sales.customers c;

CREATE VIEW easy_product_list AS
SELECT 
    p.product_name,
    c.category_name,
    p.list_price
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id;

select * from easy_product_list
where list_price>100;


create view customer_info as
select
customer_id, first_name+' '+ last_name as full_name,
email,city+', '+state as location
from sales.customers;

SELECT * 
FROM customer_info
WHERE location LIKE '%, CA';


SELECT 
    product_name, 
    list_price
FROM production.products
WHERE list_price BETWEEN 50 AND 200
ORDER BY list_price;

select state,count(*) as customer_count
from sales.customers
group by state
order by customer_count desc;


SELECT 
    c.category_name,
    p.product_name,
    p.list_price
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
WHERE p.list_price = (
    SELECT MAX(p2.list_price)
    FROM production.products p2
    WHERE p2.category_id = p.category_id
);


SELECT 
    s.store_name,
    s.city,
    COUNT(o.order_id) AS order_count
FROM sales.stores s
LEFT JOIN sales.orders o ON s.store_id = o.store_id
GROUP BY s.store_id, s.store_name, s.city;
