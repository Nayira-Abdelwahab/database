select product_id,product_name,list_price,
case 
when list_price<300 then 'economy'
when list_price between 300 and 999 then ' standard'
when list_price between 1000 and 2499 then 'premium'
when list_price >2500 then 'luxury'
end as price_category from production.products;


select order_id,order_status,required_date,
case
when order_status=1 then 'order received'
when order_status=2 then 'in preparation'
when order_status=3 then 'order cancelled'
when order_status=4 then 'order delivered'
end as status_description,
case
 WHEN order_status = 1 AND DATEDIFF(DAY, order_date, GETDATE()) > 5 THEN 'URGENT'
 WHEN order_status = 2 AND DATEDIFF(DAY, order_date, GETDATE()) > 3 THEN 'HIGH'
        ELSE 'NORMAL'
    END AS priority_level

FROM sales.orders;


select count(o.order_id)as total_orders,s.first_name,s.last_name,s.staff_id,
case 
when count(o.order_id)=0 then 'new_staff'
when count(o.order_id) between 1 and 10 then 'junior staff'
when count(o.order_id) between 11 and 25 then 'senior staff'
when count(o.order_id)>26 then 'expert staff'
end as staff_categorization
from sales.staffs s left join sales.orders o on o.staff_id=s.staff_id
group by s.staff_id,s.first_name, s.last_name;



select customer_id,first_name,last_name,
isnull(phone,'phone not available') as phone,
coalesce(phone, email,'no contact method') as info,
email,
 street,
 city,
 state
FROM sales.customers;



select p.product_name,p.list_price,s.quantity,
isnull(p.list_price/nullif(s.quantity,0),0)as price_per_unit,
case
WHEN s.quantity = 0 THEN 'Out of Stock'
WHEN s.quantity < 10 THEN 'Low Stock'
ELSE 'In Stock'
END AS stock_status from production.products p join production.stocks s
on p.product_id=s.product_id where s.store_id=1;


SELECT 
    customer_id,
    first_name,
    last_name,
    COALESCE(street, '') AS street,
    COALESCE(city, '') AS city,
    COALESCE(state, '') AS state,
    COALESCE(zip_code, '') AS zip_code,
    COALESCE(street, '') +
    CASE WHEN city IS NOT NULL AND city <> '' THEN ', ' + city ELSE '' END +
    CASE WHEN state IS NOT NULL AND state <> '' THEN ', ' + state ELSE '' END +
    CASE WHEN zip_code IS NOT NULL AND zip_code <> '' THEN ', ZIP: ' + zip_code ELSE '' END
    AS formatted_address
FROM sales.customers;




with customer_spending as(
select s.customer_id,sum(oi.list_price) as total_spent
from sales.orders s join sales.order_items oi on s.order_id=oi.order_id
group by s.customer_id) 
select c.customer_id,
    c.first_name,
    c.last_name,
    cs.total_spent
FROM customer_spending cs
JOIN sales.customers c ON cs.customer_id = c.customer_id
WHERE cs.total_spent > 1500
ORDER BY cs.total_spent DESC;


WITH total_revenue_per_category AS (
    SELECT 
        p.category_id,
        SUM(oi.list_price * oi.quantity) AS total_revenue
    FROM sales.order_items oi
    JOIN production.products p ON oi.product_id = p.product_id
    GROUP BY p.category_id
),
avg_order_value_per_category AS (
    SELECT 
        p.category_id,
        AVG(oi.list_price * oi.quantity) AS avg_order_value
    FROM sales.order_items oi
    JOIN production.products p ON oi.product_id = p.product_id
    GROUP BY p.category_id
)
SELECT 
    c.category_id,
    c.category_name,
    tr.total_revenue,
    ao.avg_order_value,
    CASE 
        WHEN tr.total_revenue > 50000 THEN 'Excellent'
        WHEN tr.total_revenue > 20000 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance_rating
FROM total_revenue_per_category tr
JOIN avg_order_value_per_category ao ON tr.category_id = ao.category_id
JOIN production.categories c ON tr.category_id = c.category_id
ORDER BY tr.total_revenue DESC;



WITH ranked_products AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category_id,
        c.category_name,
        p.list_price,
        ROW_NUMBER() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS row_num,
        RANK() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS rank_num,
        DENSE_RANK() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS dense_rank_num
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
)
SELECT 
    product_id,
    product_name,
    category_id,
    category_name,
    list_price,
    row_num,
    rank_num,
    dense_rank_num
FROM ranked_products
WHERE row_num <= 3
ORDER BY category_id, row_num;




WITH customer_totals AS (
    SELECT 
        c.customer_id,
        c.first_name + ' ' + c.last_name AS full_name,
        SUM(oi.list_price * oi.quantity) AS total_spent
    FROM sales.customers c
    JOIN sales.orders o ON c.customer_id = o.customer_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
ranked_customers AS (
    SELECT 
        customer_id,
        full_name,
        total_spent,
        RANK() OVER (ORDER BY total_spent DESC) AS spending_rank,
        NTILE(5) OVER (ORDER BY total_spent DESC) AS spending_group
    FROM customer_totals
)
SELECT 
    customer_id,
    full_name,
    total_spent,
    spending_rank,
    spending_group,
    CASE spending_group
        WHEN 1 THEN 'VIP'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
        WHEN 5 THEN 'Standard'
    END AS tier
FROM ranked_customers
ORDER BY spending_rank;



WITH store_performance AS (
    SELECT 
        s.store_id,
        s.store_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.list_price * oi.quantity) AS total_revenue
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY s.store_id, s.store_name
),
ranked_stores AS (
    SELECT 
        store_id,
        store_name,
        total_orders,
        total_revenue,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        RANK() OVER (ORDER BY total_orders DESC) AS order_rank,
        PERCENT_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_percentile
    FROM store_performance
)
SELECT 
    store_id,
    store_name,
    total_orders,
    total_revenue,
    revenue_rank,
    order_rank,
    CAST(revenue_percentile * 100 AS DECIMAL(5,2)) AS revenue_percentile_percentage
FROM ranked_stores
ORDER BY revenue_rank;



WITH store_order_status AS (
    SELECT 
        s.store_name,
        o.order_status
    FROM sales.orders o
    JOIN sales.stores s ON o.store_id = s.store_id
)

SELECT 
    store_name,
    ISNULL([1], 0) AS Pending,
    ISNULL([2], 0) AS Processing,
    ISNULL([3], 0) AS Completed,
    ISNULL([4], 0) AS Rejected
FROM store_order_status
PIVOT (
    COUNT(order_status)
    FOR order_status IN ([1], [2], [3], [4])
) AS pivot_table
ORDER BY store_name;



WITH revenue_per_year AS (
    SELECT 
        b.brand_name,
        YEAR(o.order_date) AS sales_year,
        SUM(oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    JOIN production.products p ON oi.product_id = p.product_id
    JOIN production.brands b ON p.brand_id = b.brand_id
    WHERE YEAR(o.order_date) IN (2016, 2017, 2018)
    GROUP BY b.brand_name, YEAR(o.order_date)
)

-- PIVOT
SELECT 
    brand_name,
    ISNULL([2016], 0) AS Revenue_2016,
    ISNULL([2017], 0) AS Revenue_2017,
    ISNULL([2018], 0) AS Revenue_2018,

    CASE 
        WHEN ISNULL([2016], 0) = 0 THEN NULL
        ELSE ROUND((1.0 * ([2017] - [2016]) / [2016]) * 100, 2)
    END AS Growth_16_17,

    CASE 
        WHEN ISNULL([2017], 0) = 0 THEN NULL
        ELSE ROUND((1.0 * ([2018] - [2017]) / [2017]) * 100, 2)
    END AS Growth_17_18

FROM revenue_per_year
PIVOT (
    SUM(total_revenue)
    FOR sales_year IN ([2016], [2017], [2018])
) AS pivot_result
ORDER BY brand_name;



SELECT 
    p.product_id, 
    p.product_name, 
    'In Stock' AS status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity > 0

UNION

SELECT 
    p.product_id, 
    p.product_name, 
    'Out of Stock' AS status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity = 0 OR s.quantity IS NULL

UNION

SELECT 
    p.product_id, 
    p.product_name, 
    'Discontinued' AS status
FROM production.products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM production.stocks s 
    WHERE s.product_id = p.product_id
);




SELECT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2017

INTERSECT

SELECT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2018;



SELECT 
    product_id, 
    'In All Stores' AS distribution_status
FROM production.stocks
WHERE store_id = 1

INTERSECT

SELECT 
    product_id, 
    'In All Stores' 
FROM production.stocks
WHERE store_id = 2

INTERSECT

SELECT 
    product_id, 
    'In All Stores' 
FROM production.stocks
WHERE store_id = 3

UNION

SELECT 
    product_id, 
    'Only in Store 1' AS distribution_status
FROM production.stocks
WHERE store_id = 1

EXCEPT

SELECT 
    product_id, 
    'Only in Store 1'
FROM production.stocks
WHERE store_id = 2;




SELECT 
    c.customer_id, 
    c.first_name + ' ' + c.last_name AS customer_name,
    'Lost' AS status
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
WHERE YEAR(o.order_date) = 2016
EXCEPT
SELECT 
    c.customer_id, 
    c.first_name + ' ' + c.last_name,
    'Lost'
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
WHERE YEAR(o.order_date) = 2017

UNION ALL

SELECT 
    c.customer_id, 
    c.first_name + ' ' + c.last_name,
    'New' AS status
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
WHERE YEAR(o.order_date) = 2017
EXCEPT
SELECT 
    c.customer_id, 
    c.first_name + ' ' + c.last_name,
    'New'
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
WHERE YEAR(o.order_date) = 2016

UNION ALL

SELECT 
    c.customer_id, 
    c.first_name + ' ' + c.last_name,
    'Retained' AS status
FROM sales.customers c
JOIN sales.orders o1 ON c.customer_id = o1.customer_id
JOIN sales.orders o2 ON c.customer_id = o2.customer_id
WHERE YEAR(o1.order_date) = 2016 AND YEAR(o2.order_date) = 2017;
