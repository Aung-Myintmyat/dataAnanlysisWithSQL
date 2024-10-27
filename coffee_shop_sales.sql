DESCRIBE coffee_shop_sales;

SELECT* FROM coffee_shop_sales;
 
 
 -- CHANGE THE data types(String to date)
UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y')
WHERE transaction_date LIKE '__-__-____';

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;


 -- CHANGE THE data types(String to time)

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

-- Change the cloumn name
ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id int;

SELECT* FROM coffee_shop_sales;

-- Total sales analysis

SELECT SUM(unit_price*transaction_qty) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 3;

-- Selected Month / CM - May=5
-- PM -April =4

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY
	MONTH(transaction_date) ;


-- TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH

SELECT COUNT(transaction_id) AS Toatl_Order
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5;-- May month

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH


SELECT SUM(transaction_qty) AS Toatl_Quantity_Sold
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 6;-- June month

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);




-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS

SELECT
	CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS Total_Sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS Total_Qty_Sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') Total_Orders
FROM coffee_shop_sales
WHERE 
	transaction_date = '2023-03-27';
    
-- Weedends - Sat and Sun
-- Weekdays - Mon to Fri
SELECT 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 2 -- Fed Month
GROUP BY
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END;
	
SELECT
	store_location,
    CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- May
GROUP BY store_location
ORDER BY Total_Sales DESC;


SELECT 
	CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        coffee_shop_sales
	WHERE 
        MONTH(transaction_date) = 4  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;


-- DAILY SALES FOR MONTH SELECTED
SELECT
	DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”


SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;

-- Sales by product category
SELECT product_category,
	SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY total_sales DESC;


-- Sales by product type
SELECT product_type,
	SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 AND product_category = 'Coffee'
GROUP BY product_type
ORDER BY total_sales DESC
LIMIT 10;


--  SALES BY DAY | HOUR


SELECT
	SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS Total_Qty_Sold,
    COUNT(*)
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
AND DAYOFWEEK(transaction_date) =1 -- Monday
AND HOUR(transaction_time) = 8;


SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);


SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;




