--Create Database Superstore;


Create Table Product_Details(
	Product_ID varchar(255) PRIMARY KEY NOT NULL,
	Product_Name varchar(255) NOT NULL,
	Category  varchar(255) NOT NULL,
	Sub_Category  varchar(255) NOT NULL,
	unit_price double precision NOT NULL,
	Sales double precision NOT NULL,
	Row_ID	int NOT NULL
);

Select * from Product_Details;

Create Table Customer_Details(
	customer_name varchar(255) NOT NULL,	
	Customer_ID	varchar(255) PRIMARY KEY NOT NULL,
	Country varchar(255)  NOT NULL,
	state	varchar(255)  NOT NULL,
	Region	varchar(255)  NOT NULL,
	City	varchar(255)  NOT NULL,
	Phone_number varchar(255) Not Null,
	Email_ID varchar(255)  NOT NULL
);

Select * from customer_Details;


Create Table Order_Details(
	Order_ID varchar(255) NOT NUll,
	Order_Date	date NOT NULL,
	Customer_ID	varchar(255)  NOT NULL,
	Ship_Mode	varchar(255)  NOT NULL,
	Product_ID	varchar(255)  NOT NULL,
	Quantity	int NOT NUll,
	Category	varchar(255)  NOT NULL,
	Order_Priority  varchar(255) NOT NULL,
	FOREIGN KEY (Product_ID) REFERENCES Product_Details (Product_ID),
	FOREIGN KEY (Customer_ID) REFERENCES Customer_Details (Customer_ID)
	
);

Select * from Order_Details;

Create Table Billing_Details(
	Order_ID varchar(255)  PRIMARY KEY NOT NULL,
	Quantity	int NOT NUll,
	Unit_Price	double precision NOT NUll,
	Sales	double precision NOT NUll,
	Discount	double precision NOT NUll,
	Shipping_Cost double precision NOT NUll
);

Select * from Billing_Details;


Create Table Shipping_Details(
	Order_ID	varchar(255)  PRIMARY KEY NOT NULL,
	Order_Date	Date,
	Order_Priority	varchar(255) NOT NULL,
	Ship_Date	Date,
	Ship_Mode	varchar(255) NOT NULL,
	Country	 varchar(255) NOT NULL,
	State	varchar(255) NOT NULL,
	Region	varchar(255) NOT NULL,
	City  varchar(255) NOT NULL
);

Select * from Shipping_Details;


ALTER TABLE Order_Details
ADD FOREIGN KEY (Order_ID) REFERENCES Shipping_details(ORDER_ID);


ALTER TABLE Order_Details
ADD FOREIGN KEY (Order_ID) REFERENCES Billing_details(ORDER_ID);

-- to decompose the table order details Order_Product and Order_Customer
CREATE TABLE Order_Product (
	Order_ID varchar(255) NOT NULL,
	Product_ID varchar(255) NOT NULL,
	Order_Date date NOT NULL,
	Ship_Mode varchar(255) NOT NULL,
	Category varchar(255) NOT NULL,
	Order_Priority varchar(255) NOT NULL,
	PRIMARY KEY (Order_ID, Product_ID),
	FOREIGN KEY (Product_ID) REFERENCES Product_Details (Product_ID)
);



CREATE TABLE Order_Customer (
	Order_ID varchar(255) NOT NULL,
	Order_Date date NOT NULL,
	Customer_ID varchar(255) NOT NULL,
	Ship_Mode varchar(255) NOT NULL,
	Order_Priority varchar(255) NOT NULL,
	PRIMARY KEY (Order_ID, Customer_ID),
	FOREIGN KEY (Customer_ID) REFERENCES Customer_Details(Customer_ID)
);








