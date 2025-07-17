DECLARE @CustomerID INT = 1;
DECLARE @TotalSpent MONEY;

SELECT @TotalSpent = SUM(oi.quantity * oi.list_price)
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = @CustomerID;

IF @TotalSpent > 5000
    PRINT 'Customer ' + CAST(@CustomerID AS VARCHAR) + ' is a VIP customer. Total spent: $' + CAST(@TotalSpent AS VARCHAR);
ELSE
    PRINT 'Customer ' + CAST(@CustomerID AS VARCHAR) + ' is a regular customer. Total spent: $' + CAST(@TotalSpent AS VARCHAR);



DECLARE @Threshold int = 1500;
DECLARE @ProductCount INT;

SELECT @ProductCount = COUNT(*)
FROM production.products
WHERE list_price > @Threshold;

PRINT 'Threshold price: $' + CAST(@Threshold AS VARCHAR) +
      ' | Number of products above threshold: ' + CAST(@ProductCount AS VARCHAR);



declare @staffid int=2;
declare @year int=2017;
declare @totalsales int;
select @totalsales=sum(oi.quantity*oi.list_price)
from sales.orders o
join sales.order_items oi on o.order_id=oi.order_id
where o.staff_id=@staffid and year(o.order_date)=@year;
PRINT 'Total Sales for Staff ID ' + CAST(@staffid AS VARCHAR) + ' in ' +
CAST(@year AS VARCHAR) + ': ' + CAST(@totalsales AS VARCHAR);


SELECT 
    @@SERVERNAME AS Server_Name,
    @@VERSION AS SQL_Version,
    @@ROWCOUNT AS Rows_Affected;



declare @quan int ;
select @quan =quantity from production.stocks
where product_id=1 and store_id =1;
if @quan>20
print 'well stocked';
else if @quan between 10 and 20
print 'moderate stock';
else print 'low stock - reorder needed';



declare @cnt int =0;
while @cnt <3
begin 
update top(3) production.stocks
set quantity=quantity+10
where quantity<5;
set @cnt=@cnt+1;
 PRINT 'Batch ' + CAST(@cnt AS VARCHAR) + ' updated.';
END



select product_id,product_name,list_price ,
case
when list_price < 300 THEN 'Budget'
        WHEN list_price BETWEEN 300 AND 800 THEN 'Mid-Range'
        WHEN list_price BETWEEN 801 AND 2000 THEN 'Premium'
        ELSE 'Luxury'
    END AS PriceCategory
FROM production.products;



declare @customerid int=5;
declare @cnt int ;
if exists(select 1 from sales.customers where customer_id=@customerid)
begin
select @cnt=count(*) from sales.orders
where customer_id=@customerid;
print 'customer id  '+cast(@customerid as varchar)+'  has '+
cast(@cnt as varchar)+'orders';
end
else
begin print 'customer id'+cast(@customerid as varchar)+'does not exist';



create function calculationshipping ( @ordertotal decimal(10,2))
returns decimal(10,2)
as
begin
declare @shippingcost decimal(5,2)
if @ordertotal>100
set @shippingcost=0
else if @ordertotal between 50 and 99
set @shippingcost=5.99
else set @shippingcost=12.99
return @shippingcost 
end

SELECT dbo.calculationshipping(120.00) AS Shipping 
SELECT dbo.calculationshipping(70.00) AS Shipping 
SELECT dbo.calculationshipping(30.00) AS Shipping  



create function getproducts_by_price_range(@minprice int,@maxprice int)
returns table
as
return(
select b.brand_name,c.category_name,p.list_price
from production.products p join production.brands b on p.brand_id=b.brand_id
join production.categories c on p.category_id=c.category_id
where p.list_price between @minprice and @maxprice)

select * from getproducts_by_price_range(100,300);



CREATE FUNCTION GetCustomer_Yearly_Summary (@CustomerID INT)
RETURNS @Summary TABLE
(
    OrderYear INT,
    TotalOrders INT,
    TotalSpent DECIMAL(10, 2),
    AverageOrderValue DECIMAL(10, 2)
)
AS
BEGIN
    INSERT INTO @Summary
    SELECT
        YEAR(o.order_date) AS OrderYear,
        COUNT(DISTINCT o.order_id) AS TotalOrders,
        SUM(oi.quantity * oi.list_price) AS TotalSpent,
        AVG(oi.quantity * oi.list_price) AS AverageOrderValue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @CustomerID
    GROUP BY YEAR(o.order_date);

    RETURN;
END;

SELECT * FROM dbo.GetCustomer_Yearly_Summary(5);


create function CalculateBulkDiscount(@quan int)
returns int 
as
begin declare @discount decimal(5,2)
if @quan between 1 and 2 set @discount=0.00
else if @quan between 3 and 5 set @discount=5.0
else if @quan between 6 and 9 set @discount=10.00
else if @quan >=10 set @discount=15.00
else set @discount=0.00
return @discount
end

SELECT dbo.CalculateBulkDiscount(1) AS Discount1,  
       dbo.CalculateBulkDiscount(4) AS Discount2,  
       dbo.CalculateBulkDiscount(7) AS Discount3,  
       dbo.CalculateBulkDiscount(12) AS Discount4  



CREATE PROCEDURE sp_GetCustomerOrderHistory
    @CustomerID INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.order_id,
        o.order_date,
        SUM(od.quantity * od.list_price * (1 - od.discount)) AS OrderTotal
    FROM sales.orders o
    JOIN sales.order_items od ON o.order_id = od.order_id
    WHERE o.customer_id = @CustomerID
      AND (@StartDate IS NULL OR o.order_date >= @StartDate)
      AND (@EndDate IS NULL OR o.order_date <= @EndDate)
    GROUP BY o.order_id, o.order_date
    ORDER BY o.order_date;
END;

EXEC sp_GetCustomerOrderHistory @CustomerID = 5;

EXEC sp_GetCustomerOrderHistory @CustomerID = 5, @StartDate = '2024-01-01';

EXEC sp_GetCustomerOrderHistory @CustomerID = 5, @StartDate = '2024-01-01', @EndDate = '2024-12-31';



SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS total_ordered,
    CASE 
        WHEN SUM(oi.quantity) < 10 AND c.category_name = 'Electronics' THEN 50
        WHEN SUM(oi.quantity) < 20 AND c.category_name = 'Clothing' THEN 100
        WHEN SUM(oi.quantity) < 30 THEN 150
        ELSE 0
    END AS reorder_quantity
FROM 
    production.products p
JOIN 
    sales.order_items oi ON p.product_id = oi.product_id
JOIN 
    production.categories c ON p.category_id = c.category_id
GROUP BY 
    p.product_id, p.product_name, c.category_name;



SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    ISNULL(SUM(oi.quantity * oi.list_price), 0) AS total_spent,
    CASE 
        WHEN SUM(oi.quantity * oi.list_price) IS NULL THEN 'No Tier'
        WHEN SUM(oi.quantity * oi.list_price) >= 10000 THEN 'Gold'
        WHEN SUM(oi.quantity * oi.list_price) >= 5000 THEN 'Silver'
        WHEN SUM(oi.quantity * oi.list_price) >= 1000 THEN 'Bronze'
        ELSE 'No Tier'
    END AS loyalty_tier
FROM 
    sales.customers c
LEFT JOIN 
    sales.orders o ON c.customer_id = o.customer_id
LEFT JOIN 
    sales.order_items oi ON o.order_id = oi.order_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name;



CREATE OR ALTER PROCEDURE sp_DiscontinueProduct
    @OldProductID INT,
    @NewProductID INT = NULL  -- Optional
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PendingOrders INT;
    DECLARE @StatusMessage NVARCHAR(500);

    BEGIN TRY
        BEGIN TRANSACTION;

        
        SELECT @PendingOrders = COUNT(DISTINCT order_id)
        FROM sales.order_items
        WHERE product_id = @OldProductID;

        IF @PendingOrders > 0
        BEGIN
            IF @NewProductID IS NOT NULL
            BEGIN
              
                UPDATE sales.order_items
                SET product_id = @NewProductID
                WHERE product_id = @OldProductID;

                SET @StatusMessage = CONCAT(
                    'Product ', @OldProductID, ' found in ', @PendingOrders,
                    ' orders. Replaced with product ', @NewProductID, '.'
                );
            END
            ELSE
            BEGIN
                SET @StatusMessage = CONCAT(
                    'Product ', @OldProductID, ' found in ', @PendingOrders, 
                    ' orders. No replacement specified.'
                );
            END
        END
        ELSE
        BEGIN
            SET @StatusMessage = CONCAT(
                'Product ', @OldProductID, ' has no orders.'
            );
        END

     
        UPDATE production.stocks
        SET quantity = 0
        WHERE product_id = @OldProductID;

      
        PRINT @StatusMessage;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'An error occurred: ' + @ErrorMessage;
    END CATCH
END;


      
        UPDATE production.stocks
        SET quantity = 0
        WHERE product_id = @OldProductID;

 
        PRINT @StatusMessage;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'An error occurred: ' + @ErrorMessage;
    END CATCH
END;


