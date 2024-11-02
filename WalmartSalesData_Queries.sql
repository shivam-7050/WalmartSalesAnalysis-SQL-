--IF OBJECT_ID('sales', 'U') IS NULL
--BEGIN
--    CREATE TABLE WalmartSalesData (
--        invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
--        branch VARCHAR(5) NOT NULL,
--        city VARCHAR(30) NOT NULL,
--        customer_type VARCHAR(30) NOT NULL,
--        gender VARCHAR(30) NOT NULL,
--        product_line VARCHAR(100) NOT NULL,
--        unit_price DECIMAL(10, 2) NOT NULL,
--        quantity INT NOT NULL,
--        tax_pct DECIMAL(6, 4) NOT NULL,
--        total DECIMAL(12, 4) NOT NULL,
--        date DATETIME2 NOT NULL,
--        time TIME(0) NOT NULL,
--        payment VARCHAR(15) NOT NULL,
--        cogs DECIMAL(10, 2) NOT NULL,
--        gross_margin_pct DECIMAL(5, 4),
--        gross_income DECIMAL(12, 4),
--        rating DECIMAL(3, 1)
--    );
--END


--Add the time_of_day column

SELECT time,
CASE
    WHEN time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
    WHEN time BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
    ELSE 'Evening'
END AS time_of_day
FROM WalmartSalesData;

ALTER TABLE WalmartSalesData
ADD time_of_day VARCHAR(10);

UPDATE WalmartSalesData
SET time_of_day = CASE
    WHEN time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
    WHEN time BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
    ELSE 'Evening'
END;

--Add the day_name column

SELECT DATENAME(weekday,date) AS day_name
FROM WalmartSalesData

ALTER TABLE WalmartSalesData
ADD day_name VARCHAR(10);

UPDATE WalmartSalesData
SET day_name=DATENAME(weekday,date);

--Add the month_name column

SELECT DATENAME(month,date) AS month_name
FROM WalmartSalesData

ALTER TABLE WalmartSalesData
ADD month_name VARCHAR(10);

UPDATE WalmartSalesData
SET month_name=DATENAME(month,date);

-- --------------------------------------------------------------------
-- ---------------------------- Generic ------------------------------
-- --------------------------------------------------------------------
-- How many unique cities does the data have?

SELECT DISTINCT city
FROM WalmartSalesData;

-- In which city is each branch?

SELECT DISTINCT branch,city
FROM WalmartSalesData
ORDER BY branch;

-- --------------------------------------------------------------------
-- ---------------------------- Product -------------------------------
-- --------------------------------------------------------------------

-- How many unique product lines does the data have?

SELECT COUNT(DISTINCT product_line)
FROM WalmartSalesData;

-- What is the most common payment method?

SELECT payment ,COUNT(payment)
FROM WalmartSalesData
GROUP BY payment
ORDER BY COUNT(payment) DESC;

-- What is the most selling product line?

SELECT product_line,SUM(quantity) AS "Total Quantity"
FROM WalmartSalesData
GROUP BY product_line
ORDER BY [Total Quantity] DESC;

-- What is the total revenue by month?

SELECT month_name AS Month ,SUM(total) AS "Total Revenue"
FROM WalmartSalesData
GROUP BY month_name
ORDER BY [Total Revenue] DESC;

-- What month had the largest COGS?

SELECT month_name AS Month,SUM(cogs) AS Cogs
FROM WalmartSalesData
GROUP BY month_name
ORDER BY Cogs DESC;

-- What product line had the largest revenue?	

SELECT product_line ,SUM(total) AS "Total Revenue"
FROM WalmartSalesData
GROUP BY product_line
ORDER BY [Total Revenue] DESC;

-- What is the city with the largest revenue?

SELECT branch,city ,SUM(total) AS "Total Revenue"
FROM WalmartSalesData
GROUP BY city,branch
ORDER BY [Total Revenue] DESC;

-- What product line had the largest VAT?

SELECT product_line,AVG(tax_pct) AS avg_tax
FROM WalmartSalesData 
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT AVG(quantity) as avg_quantity
FROM WalmartSalesData;


-- Which branch sold more products than average product sold?

SELECT branch,SUM(quantity) AS "Total Quanity"
FROM WalmartSalesData
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM WalmartSalesData);

-- What is the most common product line by gender?

SELECT gender,product_line,COUNT(gender)
FROM WalmartSalesData
GROUP BY gender,product_line
ORDER BY COUNT(gender) DESC;

--What is the average rating of each product line?

SELECT product_line,AVG(rating) AS Avg_rating
FROM WalmartSalesData
GROUP BY product_line;

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday?

SELECT time_of_day,COUNT(*) AS total_sales
FROM WalmartSalesData
WHERE day_name='Saturday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?

SELECT customer_type,SUM(total) AS total_rev
FROM WalmartSalesData
GROUP BY customer_type
ORDER BY total_rev DESC;

-- Which city has the largest tax/VAT percent?

SELECT city,AVG(tax_pct) AS tax
FROM WalmartSalesData
GROUP BY city
ORDER BY tax DESC;

-- Which customer type pays the most in VAT?

SELECT customer_type,AVG(tax_pct) AS tax
FROM WalmartSalesData
GROUP BY customer_type
ORDER BY tax DESC;

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?

SELECT DISTINCT customer_type
FROM WalmartSalesData;

-- How many unique payment methods does the data have?

SELECT DISTINCT payment
FROM WalmartSalesData;

-- What is the most common customer type?

SELECT customer_type,COUNT(*)
FROM WalmartSalesData
GROUP BY customer_type
ORDER BY COUNT(*) DESC;

-- What is the gender of most of the customers?

SELECT gender,COUNT(*)
FROM WalmartSalesData
GROUP BY gender
ORDER BY COUNT(*) DESC;

-- What is the gender distribution per branch?

SELECT gender,COUNT(*)
FROM WalmartSalesData
WHERE branch ='A'
GROUP BY gender
ORDER BY COUNT(*) DESC;

-- Which time of the day do customers give most ratings?

SELECT time_of_day,AVG(rating) AS avg_rating
FROM WalmartSalesData
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?

SELECT time_of_day,AVG(rating) AS avg_rating
FROM WalmartSalesData
WHERE branch='B'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day of the week has the best avg ratings?

SELECT day_name,AVG(rating) AS avg_rating
FROM WalmartSalesData
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?

SELECT day_name,AVG(rating) AS avg_rating
FROM WalmartSalesData
WHERE branch='B'
GROUP BY day_name
ORDER BY avg_rating DESC;