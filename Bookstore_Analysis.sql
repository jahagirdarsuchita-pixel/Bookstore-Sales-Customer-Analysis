/*
Project: Bookstore Sales & Customer Analysis
Database: PostgreSQL

Tables:
  1. Books
  2. Customers
  3. Orders

Important:
- This script creates the tables and contains basic and advanced analysis queries.
- Load your CSV data into Books and Customers before loading Orders.
- Update the CSV file paths in the import examples for your own computer.
- In PostgreSQL, SERIAL is appropriate for auto-generated primary keys. Foreign-key columns
  should use the same integer type as the referenced primary key, so Customer_ID and Book_ID
  in Orders are INTEGER rather than SERIAL.
*/

-- =========================================================
-- 1. CREATE TABLES
-- =========================================================

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Books;

CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10,2),
    Stock INT
);

CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Cust_Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(50),
    City VARCHAR(50),
    Country VARCHAR(150)
);

CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10,2)
);

-- Check table contents after loading data
SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;

-- =========================================================
-- 2. IMPORT CSV DATA (EXAMPLES - UPDATE FILE PATHS)
-- =========================================================
-- Run these in the psql terminal using \copy, or import the CSV files
-- through your database tool. The paths below are examples only.
--
-- \copy Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock) FROM 'C:/your/path/Books.csv' WITH (FORMAT CSV, HEADER TRUE);
-- \copy Customers(Customer_ID, Cust_Name, Email, Phone, City, Country) FROM 'C:/your/path/Customers.csv' WITH (FORMAT CSV, HEADER TRUE);
-- \copy Orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount) FROM 'C:/your/path/Orders.csv' WITH (FORMAT CSV, HEADER TRUE);
--
-- If CSV files provide explicit ID values for SERIAL columns, you may need to
-- reset each sequence after importing, so future inserts do not reuse existing IDs.
-- Example:
-- SELECT setval(pg_get_serial_sequence('books', 'book_id'), COALESCE((SELECT MAX(book_id) FROM books), 1));
-- SELECT setval(pg_get_serial_sequence('customers', 'customer_id'), COALESCE((SELECT MAX(customer_id) FROM customers), 1));
-- SELECT setval(pg_get_serial_sequence('orders', 'order_id'), COALESCE((SELECT MAX(order_id) FROM orders), 1));

-- =========================================================
-- 3. BASIC SQL QUESTIONS
-- =========================================================

-- 1. Retrieve all books in the Fiction genre
SELECT *
FROM Books
WHERE Genre = 'Fiction';

-- 2. Find books published after 1950
SELECT *
FROM Books
WHERE Published_Year > 1950;

-- 3. List all customers from Canada
SELECT *
FROM Customers
WHERE Country = 'Canada';

-- 4. Show orders placed in November 2023
SELECT *
FROM Orders
WHERE Order_Date >= DATE '2023-11-01'
  AND Order_Date < DATE '2023-12-01';

-- 5. Retrieve the total stock of books available
SELECT SUM(Stock) AS Total_Stock
FROM Books;

-- 6. Find the most expensive book (returns one row)
SELECT *
FROM Books
ORDER BY Price DESC
LIMIT 1;

-- 7. Show orders where more than one copy was ordered
SELECT *
FROM Orders
WHERE Quantity > 1;

-- 8. Retrieve orders where the total amount exceeds $20
SELECT *
FROM Orders
WHERE Total_Amount > 20;

-- 9. List all distinct genres
SELECT DISTINCT Genre
FROM Books
ORDER BY Genre;

-- 10. Find the book with the lowest stock
SELECT *
FROM Books
ORDER BY Stock ASC
LIMIT 1;

-- 11. Calculate total revenue from all orders
SELECT SUM(Total_Amount) AS Total_Revenue
FROM Orders;

-- =========================================================
-- 4. ADVANCED SQL QUESTIONS
-- =========================================================

-- 1. Total number of copies sold for each genre
SELECT
    b.Genre,
    SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b ON b.Book_ID = o.Book_ID
GROUP BY b.Genre
ORDER BY Total_Books_Sold DESC;

-- 2. Average price of books in the Fantasy genre
SELECT AVG(Price) AS Average_Price
FROM Books
WHERE Genre = 'Fantasy';

-- 3. Customers who have placed at least two orders, highest count first
SELECT
    c.Customer_ID,
    c.Cust_Name,
    COUNT(o.Order_ID) AS Order_Count
FROM Orders o
JOIN Customers c ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Cust_Name
HAVING COUNT(o.Order_ID) >= 2
ORDER BY Order_Count DESC, c.Cust_Name ASC;

-- 4. Most frequently ordered book by number of order records
SELECT
    b.Book_ID,
    b.Title,
    COUNT(o.Order_ID) AS Order_Count
FROM Orders o
JOIN Books b ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title
ORDER BY Order_Count DESC
LIMIT 1;

-- 5. Top three most expensive books in the Fantasy genre
SELECT *
FROM Books
WHERE Genre = 'Fantasy'
ORDER BY Price DESC
LIMIT 3;

-- 6. Total quantity of books sold by each author
SELECT
    b.Author,
    SUM(o.Quantity) AS Total_Quantity_Sold
FROM Orders o
JOIN Books b ON b.Book_ID = o.Book_ID
GROUP BY b.Author
ORDER BY Total_Quantity_Sold DESC;

-- 7. Cities where customers placed orders worth more than $30
SELECT DISTINCT
    c.City
FROM Orders o
JOIN Customers c ON c.Customer_ID = o.Customer_ID
WHERE o.Total_Amount > 30
ORDER BY c.City;

-- 8. Customer who spent the most in total
SELECT
    c.Customer_ID,
    c.Cust_Name,
    SUM(o.Total_Amount) AS Total_Spent
FROM Orders o
JOIN Customers c ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Cust_Name
ORDER BY Total_Spent DESC
LIMIT 1;

-- 9. Estimated remaining stock after fulfilling recorded orders
-- Assumption: Books.Stock represents starting stock before these orders.
-- If Stock is already the current on-hand quantity, do not subtract orders again.
SELECT
    b.Book_ID,
    b.Title,
    b.Stock AS Starting_Stock,
    COALESCE(SUM(o.Quantity), 0) AS Ordered_Quantity,
    b.Stock - COALESCE(SUM(o.Quantity), 0) AS Estimated_Remaining_Stock
FROM Books b
LEFT JOIN Orders o ON o.Book_ID = b.Book_ID
GROUP BY b.Book_ID, b.Title, b.Stock
ORDER BY b.Book_ID;

-- =========================================================
-- 5. ADDITIONAL BUSINESS ANALYSIS QUERIES
-- =========================================================

-- 10. Monthly revenue trend
SELECT
    DATE_TRUNC('month', Order_Date)::DATE AS Sales_Month,
    SUM(Total_Amount) AS Monthly_Revenue,
    COUNT(Order_ID) AS Order_Count
FROM Orders
GROUP BY DATE_TRUNC('month', Order_Date)
ORDER BY Sales_Month;

-- 11. Top five customers by total spend
SELECT
    c.Customer_ID,
    c.Cust_Name,
    SUM(o.Total_Amount) AS Total_Spent,
    COUNT(o.Order_ID) AS Order_Count
FROM Customers c
JOIN Orders o ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Cust_Name
ORDER BY Total_Spent DESC
LIMIT 5;

-- 12. Revenue by book genre
SELECT
    b.Genre,
    SUM(o.Total_Amount) AS Total_Revenue
FROM Orders o
JOIN Books b ON b.Book_ID = o.Book_ID
GROUP BY b.Genre
ORDER BY Total_Revenue DESC;

-- 13. Customers with no orders
SELECT
    c.Customer_ID,
    c.Cust_Name,
    c.City,
    c.Country
FROM Customers c
LEFT JOIN Orders o ON o.Customer_ID = c.Customer_ID
WHERE o.Order_ID IS NULL
ORDER BY c.Cust_Name;

-- End of project script
