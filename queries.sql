--Inserting Operation:

--1. Insert a new product into the Product_Details table

INSERT INTO Product_Details (Product_ID, Product_Name, Category, Sub_Category, unit_price, Sales, Row_ID)
VALUES ('TEC-CO-5800', 'Lenovo IdeaPad 5', 'Technology', 'Computers', 1000, 500000, 324);

select * from Product_Details where Product_ID = 'TEC-CO-5800';

--Deleting Operation:

--2. Delete a product from the Product_Details table

DELETE FROM Product_Details
WHERE Product_ID = 'TEC-CO-5800';

select * from Product_Details where Product_ID = 'TEC-CO-5800';

--extra 
--Insert a new customer into the customer_Details table

INSERT INTO Customer_Details (customer_name,customer_id,country,state,region,city,phone_number,email_id)
VALUES ('Rakshitha',	'CV-0000000',	'United States',	'NewYork',	'Central US'	,'Buffalo',	'500-101-9012',	'rakshitha@example.com');

select * from Customer_Details where Customer_ID = 'CV-0000000';


--Deleting Operation:

--2. Delete a product from the Product_Details table

DELETE FROM Customer_Details where Customer_ID = 'CV-0000000';

select * from Customer_Details where Customer_ID = 'CV-0000000';


--Update 
select order_date from order_details where order_id = 'IN-2015-VG2180558-42273';

UPDATE order_details
SET order_date = '2015-09-24'
WHERE order_id = 'IN-2015-VG2180558-42273';


select * from order_Details where order_id = 'IN-2015-VG2180558-42273';

--Update 
UPDATE order_details
SET order_date = '2012-12-27'
WHERE order_id = 'SA-2012-MM7260110-41269';

select * from order_details where order_id = 'SA-2012-MM7260110-41269';

--Updating using functions,triggers Operation:


-- 3. Update the unit price of a product in the Product_Details table:
CREATE OR REPLACE FUNCTION update_sales()
RETURNS TRIGGER AS
$$
BEGIN
    UPDATE Product_Details
    SET Sales = NEW.unit_price * (
        SELECT SUM(od.quantity) 
        FROM Order_Details od 
        WHERE od.product_id = NEW.product_id
    )
    WHERE Product_ID = NEW.Product_ID;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_sales_trigger
AFTER UPDATE OF unit_price ON Product_Details
FOR EACH ROW
EXECUTE FUNCTION update_sales();


UPDATE Product_Details SET unit_price = 625.00 WHERE Product_ID = 'TEC-PH-5356';

select * from Product_Details where Product_ID = 'TEC-PH-5356';


--Select Operation:

-- 4. Select all the orders made by a specific customer:

SELECT *
FROM Order_Details
WHERE Customer_ID = 'HI-185111';


-- 5. Select the total sales for each category in the Product_Details table:

SELECT Category, SUM(Sales) AS Total_Sales
FROM Product_Details
GROUP BY Category;

--Joins 
--6. Select the product details and the corresponding customer details for a specific order.
	
SELECT p.Product_Name, p.Category, c.customer_name, c.Country, c.state
FROM Product_Details p
INNER JOIN Order_Details o ON p.Product_ID = o.Product_ID
INNER JOIN Customer_Details c ON o.Customer_ID = c.Customer_ID
WHERE o.Order_ID = 'IN-2012-AB1010558-41270';



/*8. This query retrieves the total sales and last shipment date for each customer in the USA who has ordered more 
than 5 different products. The results are sorted by total sales in descending order.
The query uses JOINs to combine data from the Customer_Details, Order_Details, Billing_Details, and 
Shipping_Details tables. It also uses subqueries to calculate the number of different products each customer 
has ordered, and aggregation functions to calculate the total sales and last shipment date for each group. Finally,
it uses the WHERE clause to filter the customers based on their country, the HAVING clause to filter the groups based 
on the number of different products, and the ORDER BY clause to sort the results.
*/

SELECT c.customer_name, c.Country, c.state, 
       SUM(b.Sales) AS Total_Sales, 
       MAX(s.Ship_Date) AS Last_Shipment_Date
FROM Customer_Details c
INNER JOIN Order_Details o ON c.Customer_ID = o.Customer_ID
INNER JOIN Billing_Details b ON o.Order_ID = b.Order_ID
INNER JOIN Shipping_Details s ON o.Order_ID = s.Order_ID
WHERE c.Country = 'United States'
GROUP BY c.customer_name, c.Country, c.state
HAVING COUNT(DISTINCT o.Product_ID) > 5
ORDER BY Total_Sales DESC;


--------------------------------------------------- Triggers, Functions, Views, Procedures-----------------------------------------------------
-- 9. Create a view that shows the total sales for each product by year:

CREATE VIEW product_sales_by_year AS
SELECT pd.product_id, pd.product_name, DATE_TRUNC('year', od.order_date) AS year, SUM(bd.sales) AS total_sales
FROM product_details pd
INNER JOIN order_details od ON pd.product_id = od.product_id
INNER JOIN billing_details bd ON od.order_id = bd.order_id
GROUP BY pd.product_id, pd.product_name, DATE_TRUNC('year', od.order_date);

SELECT * FROM product_sales_by_year;


/*10. Create a trigger that automatically inserts a new record into the Shipping_Details
table whenever a new order is inserted into the Order_Details table:*/

CREATE OR REPLACE FUNCTION insert_shipping_details()
RETURNS TRIGGER AS $$
BEGIN
  -- Try to update the existing record with the new values
  UPDATE Shipping_Details
  SET Order_Date = NEW.Order_Date,
      Order_Priority = NEW.Order_Priority,
      Ship_Mode = NEW.Ship_Mode,
      Country = (SELECT Country FROM Customer_Details WHERE Customer_ID = NEW.Customer_ID),
      State = (SELECT State FROM Customer_Details WHERE Customer_ID = NEW.Customer_ID),
      Region = (SELECT Region FROM Customer_Details WHERE Customer_ID = NEW.Customer_ID),
      City = (SELECT City FROM Customer_Details WHERE Customer_ID = NEW.Customer_ID)
  WHERE Order_ID = NEW.Order_ID;
  
  
  -- If no record was updated, insert a new one
  IF NOT FOUND THEN
    INSERT INTO Shipping_Details (Order_ID, Order_Date, Order_Priority, Ship_Mode, Country, State, Region, City)
    SELECT NEW.Order_ID, NEW.Order_Date, NEW.Order_Priority, NEW.Ship_Mode, c.Country, c.State, c.Region, c.City
    FROM Customer_Details c
    WHERE c.Customer_ID = NEW.Customer_ID;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insert_shipping_details
AFTER INSERT ON Order_Details
FOR EACH ROW
EXECUTE FUNCTION insert_shipping_details();

/* trigger first tries to update the existing record in the Shipping_Details table with the new values based
on the Order_ID. If no record was updated, it means that there was no existing record with that Order_ID, so 
it inserts a new record into the Shipping_Details table.*/


-- checking purpose 
select * from order_details;

INSERT INTO Order_Details (Order_ID, Order_Date,customer_id,ship_mode,product_id,quantity,category,order_priority)
VALUES ('SA-2012-MM7260110-41269',	'2015-12-31',	'Fe-3512840',	'Second Class',	'TEC-PH-3807',	4	,'Technology',	'Critical');

select * from shipping_details where order_id='SA-2012-MM7260110-41269';

--Procedure to calculate the total revenue generated by a customer in a particular year

CREATE OR REPLACE PROCEDURE calculate_customer_revenue(
    IN customer_name varchar(255),
    IN year int,
    OUT revenue double precision
)
AS $$
BEGIN
    SELECT SUM(bd.Sales) INTO revenue
    FROM Order_Details od
    JOIN Billing_Details bd ON od.Order_ID = bd.Order_ID
    JOIN Customer_Details cd ON od.Customer_ID = cd.Customer_ID
    WHERE cd.Customer_Name = calculate_customer_revenue.customer_name
    AND extract(year from od.Order_Date) = year;
END;
$$ LANGUAGE plpgsql;


DO $$
DECLARE
    v_revenue double precision;
BEGIN
    CALL calculate_customer_revenue('Stacy Cruz', 2014, v_revenue);
    RAISE NOTICE 'Revenue for Stacy Cruz in 2014: %', v_revenue;
END $$;



-- Find the top 5 customers who have the highest number of orders, along with the average order amount:
SELECT 
  cd.customer_name, COUNT(DISTINCT od.order_id) AS num_orders, AVG(bd.quantity * pd.unit_price) AS avg_order_amount
FROM 
  billing_details bd 
  JOIN order_details od ON bd.order_id = od.order_id 
  JOIN customer_details cd ON od.customer_id = cd.customer_id 
  JOIN product_details pd ON od.product_id = pd.product_id 
GROUP BY 
  cd.customer_name 
ORDER BY 
  num_orders DESC 
LIMIT 
  5;

--Retrieve the top 5 customers who have spent the most amount of money on purchases:
SELECT customer_details.customer_name, SUM(billing_details.sales) AS total_sales
FROM customer_details
INNER JOIN order_details ON customer_details.customer_id = order_details.customer_id
INNER JOIN billing_details ON order_details.order_id = billing_details.order_id
GROUP BY customer_details.customer_name
HAVING SUM(billing_details.sales) > 0
ORDER BY total_sales DESC
LIMIT 5;



/* 7. This query retrieves the name, country, and state of the top 10 customers with the highest total sales,
along with the number of orders and shipments they have made. The subqueries are used to calculate the total 
number of orders and sales for each customer, as well as the total number of shipments based on the orders they 
have made. The results are sorted by total sales in descending order and limited to the top 10 customers.*/
-- Before optimization
SELECT c.customer_name, c.Country, c.state, 
       (SELECT COUNT(*) FROM Order_Details WHERE Customer_ID = c.Customer_ID) AS Total_Orders,
       (SELECT COALESCE(SUM(pd.unit_price * od.quantity), 0) 
        FROM Product_Details pd 
        INNER JOIN Order_Details od ON pd.Product_ID = od.Product_ID 
        WHERE od.Customer_ID = c.Customer_ID) AS Total_Sales,
       (SELECT COUNT(*) FROM Shipping_Details WHERE Order_ID IN 
            (SELECT Order_ID FROM Order_Details WHERE Customer_ID = c.Customer_ID)) AS Total_Shipments
FROM Customer_Details c
ORDER BY Total_Sales DESC
LIMIT 10;

-- After optimization
CREATE MATERIALIZED VIEW customer_sales AS
SELECT od.Customer_ID,
       COALESCE(SUM(pd.unit_price * od.quantity), 0) AS Total_Sales
FROM Product_Details pd 
INNER JOIN Order_Details od ON pd.Product_ID = od.Product_ID 
GROUP BY od.Customer_ID;

SELECT c.customer_name, c.Country, c.state, 
       (SELECT COUNT(*) FROM Order_Details WHERE Customer_ID = c.Customer_ID) AS Total_Orders,
       cs.Total_Sales,
       (SELECT COUNT(*) FROM Shipping_Details WHERE Order_ID IN 
            (SELECT Order_ID FROM Order_Details WHERE Customer_ID = c.Customer_ID)) AS Total_Shipments
FROM Customer_Details c
LEFT JOIN customer_sales cs ON c.Customer_ID = cs.Customer_ID
ORDER BY cs.Total_Sales DESC
LIMIT 10;




-- Create a view that displays the top 5 most sold products along with their total sales:
-- Time taking query 
SELECT p.product_name, s.total_sales
FROM product_details p
JOIN (
  SELECT op.product_id, SUM(b.sales) AS total_sales
  FROM order_product op
  JOIN billing_details b ON op.order_id = b.order_id
  GROUP BY op.product_id
) s ON p.product_id = s.product_id
ORDER BY s.total_sales DESC
LIMIT 5;

-- Time taking query than the above
CREATE VIEW top_products AS
SELECT p.product_name, SUM(b.sales) AS total_sales
FROM product_details p
JOIN order_product op ON p.product_id = op.product_id
JOIN order_details o ON op.order_id = o.order_id
JOIN billing_details b ON o.order_id = b.order_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 5;
select * from top_products;

-- 3 problematic query
UPDATE Product_Details pd
SET Sales = pd.unit_price * (
    SELECT SUM(od.quantity) 
    FROM Order_Details od 
    WHERE od.product_id = pd.product_id
);
select * from Product_Details where Product_ID = 'TEC-PH-5356';

--after optimization
CREATE OR REPLACE FUNCTION update_sales()
RETURNS TRIGGER AS
$$
BEGIN
    UPDATE Product_Details
    SET Sales = NEW.unit_price * (
        SELECT SUM(od.quantity) 
        FROM Order_Details od 
        WHERE od.product_id = NEW.product_id
    )
    WHERE Product_ID = NEW.Product_ID;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_sales_trigger
AFTER UPDATE OF unit_price ON Product_Details
FOR EACH ROW
EXECUTE FUNCTION update_sales();

UPDATE Product_Details SET unit_price = 625.00 WHERE Product_ID = 'TEC-PH-5356';

select * from Product_Details where Product_ID = 'TEC-PH-5356';

