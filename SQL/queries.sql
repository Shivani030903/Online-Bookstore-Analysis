-- 1) Retrieve all books in the "Fiction" genre:
SELECT * FROM Books WHERE Genre = 'Fiction';

-- 2) Find books published after the year 1950:
SELECT * FROM Books WHERE Published_year > 1950;

-- 3) List all customers from the Canada:
SELECT * FROM Customers WHERE Country = 'Canada';

SELECT Country, LENGTH(Country) FROM Customers; -- to find length of the country

SELECT Country, HEX(Country) FROM Customers; 	-- to find the HEX value of the countries 0D → \r  and 0A → \n

UPDATE Customers
SET Country = TRIM(REPLACE(REPLACE(Country, CHAR(13), ''), CHAR(10), ''));   -- To remove the \r and \n from the text

SELECT CONCAT('|', Country, '|') FROM Customers;	-- to find on which side is the inline space



-- 4) Show orders placed in November 2023:
SELECT * FROM Orders WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5) Retrieve the total stock of books available:
SELECT SUM(Stock) AS Total_stock FROM Books;

-- 6) Find the details of the most expensive book:
SELECT * FROM Books 
ORDER BY Price DESC 
LIMIT 1;

-- 7) Show all customers who ordered more than 1 quantity of a book:
SELECT * FROM Orders WHERE Quantity>1;

-- 8) Retrieve all orders where the total amount exceeds $20:
SELECT * FROM Orders WHERE Total_Amount > 20;

-- 9) List all genres available in the Books table:
SELECT Genre 
FROM Books 
GROUP BY Genre;
-- or --
SELECT DISTINCT Genre
FROM Books;


-- 10) Find the book with the lowest stock:
SELECT * 
FROM Books 
ORDER BY Stock
LIMIT 1;


-- 11) Calculate the total revenue generated from all orders:
SELECT SUM(Total_Amount) AS Total_Revenue FROM Orders;


-- Advance Questions : 

-- 1) Retrieve the total number of books sold for each genre:

SELECT b.Genre, SUM(o.Quantity)
FROM Orders o
JOIN Books b ON b.Book_ID = o.Book_ID
GROUP BY b.Genre;


-- 2) Find the average price of books in the "Fantasy" genre:

SELECT AVG(Price) AS AvgPrice
FROM Books WHERE Genre = 'Fantasy';

-- 3) List customers who have placed at least 2 orders:

SELECT Customer_ID, COUNT(Order_ID) AS OrderCount
FROM Orders 
GROUP BY Customer_ID
HAVING COUNT(Order_ID) >= 2;

-- or using joins to show customer details --

SELECT o.Customer_ID,c.name, COUNT(o.Order_ID) AS OrderCount
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY o.Customer_ID, c.name
HAVING COUNT(Order_ID) >= 2;


-- 4) Find the most frequently ordered book:

SELECT Book_ID, COUNT(Order_ID) AS ORDER_COUNT
FROM Orders
GROUP BY Book_ID
ORDER BY ORDER_COUNT DESC
LIMIT 1;

-- 5) Show the top 3 most expensive books of 'Fantasy' Genre :

SELECT Book_ID, Title,Genre, Price 
FROM Books WHERE Genre = 'Fantasy'
ORDER BY Price DESC
LIMIT 3;

-- 6) Retrieve the total quantity of books sold by each author:
SELECT * FROM Orders;
SELECT * FROM Books;
SELECT b.Author, SUM(o.Quantity) AS Book_Quantity
FROM Books b
JOIN Orders o ON o.Book_ID = b.Book_ID
GROUP BY b.Author;

-- 7) List the cities where customers who spent over $30 are located:

SELECT DISTINCT c.City, o.Total_Amount
FROM Orders o 
JOIN Customers c ON c.Customer_ID = o.Customer_ID
WHERE o.Total_Amount > 30;


-- 8) Find the customer who spent the most on orders:

SELECT c.Customer_ID, c.Name, SUM(o.Total_Amount) AS totalAmnt
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY totalAmnt DESC
LIMIT 1;


-- 9) Calculate the stock remaining after fulfilling all orders:

SELECT b.book_id, b.title, b.stock, 
       COALESCE(SUM(o.quantity),0) AS Order_quantity,
       b.stock - COALESCE(SUM(o.quantity),0) AS Remaining_Quantity
FROM books b
LEFT JOIN orders o ON b.book_id = o.book_id
GROUP BY b.book_id
ORDER BY b.book_id;

-- Revenue Contribution by Genre 

SELECT 
    b.Genre,
    SUM(o.Total_Amount) AS Revenue,
    ROUND(100 * SUM(o.Total_Amount) / 
        (SELECT SUM(Total_Amount) FROM Orders), 2) AS Revenue_Percentage
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Genre
ORDER BY Revenue DESC;

-- Top 10% Customers Contribution

WITH CustomerSpending AS (
    SELECT 
        Customer_ID,
        SUM(Total_Amount) AS Total_Spent
    FROM Orders
    GROUP BY Customer_ID
),
RankedCustomers AS (
    SELECT *,
           NTILE(10) OVER (ORDER BY Total_Spent DESC) AS percentile
    FROM CustomerSpending
)
SELECT 
    SUM(Total_Spent) AS Top10_Revenue,
    (SELECT SUM(Total_Amount) FROM Orders) AS Total_Revenue,
    ROUND(100 * SUM(Total_Spent) / 
        (SELECT SUM(Total_Amount) FROM Orders), 2) AS Percentage
FROM RankedCustomers
WHERE percentile = 1;

-- Low Stock Detection

SELECT 
    Book_ID,
    Title,
    Stock
FROM Books
WHERE Stock < 10
ORDER BY Stock ASC;

-- Average Price by Genre

SELECT 
    Genre,
    ROUND(AVG(Price), 2) AS Avg_Price
FROM Books
GROUP BY Genre
ORDER BY Avg_Price DESC;

-- Monthly Sales Trend (Seasonality)

SELECT 
    DATE_FORMAT(Order_Date, '%Y-%m') AS Month,
    SUM(Total_Amount) AS Revenue
FROM Orders
GROUP BY Month
ORDER BY Month;
