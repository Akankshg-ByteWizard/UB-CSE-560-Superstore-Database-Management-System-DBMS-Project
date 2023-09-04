COPY public.product_details (product_id, product_name, category, sub_category, unit_price, sales, row_id)
FROM 'C:/Users/harik/DOCUME~1/Project/Product.csv' 
DELIMITER ',' 
CSV HEADER 
QUOTE '"' 
ESCAPE '''';

COPY public.billing_details (order_id, quantity, unit_price, sales, discount, shipping_cost) 
FROM 'C:/Users/harik/DOCUME~1/Project/Billing.csv' 
DELIMITER ',' 
CSV HEADER 
QUOTE '"' 
ESCAPE '''';


COPY public.shipping_details (order_id, order_date, order_priority, ship_date, ship_mode, country, state, region, city) 
FROM 'C:/Users/harik/DOCUME~1/Project/Shipping.csv' 
DELIMITER ',' 
CSV HEADER 
QUOTE '"' 
ESCAPE '''';


COPY public.customer_details (customer_name, customer_id, country, state, region, city, phone_number, email_id) 
FROM 'C:/Users/harik/DOCUME~1/Project/Customer.csv' 
DELIMITER ',' 
CSV HEADER 
QUOTE '"' 
ESCAPE '''';


COPY public.order_details (order_id, order_date, customer_id, ship_mode, product_id, quantity, category, order_priority) 
FROM 'C:/Users/harik/DOCUME~1/Project/Order.csv' 
DELIMITER ',' 
CSV HEADER 
QUOTE '"' 
ESCAPE '''';



INSERT INTO Order_Customer (Order_ID, Customer_ID, Order_Date, Ship_Mode, Order_Priority)
SELECT Order_ID, Customer_ID,Order_Date, Ship_Mode,Order_Priority
FROM Order_Details
ON CONFLICT DO NOTHING;


INSERT INTO Order_Product (Order_ID, Product_ID, Order_Date, Ship_Mode,Category, Order_Priority)
SELECT Order_ID, Product_ID, Order_Date, Ship_Mode, Category,Order_Priority
FROM Order_Details
ON CONFLICT DO NOTHING;









