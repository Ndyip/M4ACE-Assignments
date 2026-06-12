SELECT OrderID,
OrderDate, 
OrderTotal, 
CustomerName, 
Phone
FROM Orders o
JOIN Customers c on o.CustomerID = c.CustomerID

SELECT * FROM Orders 
WHERE OrderDate >= '2/18/2022'
Order by OrderTotal
 

SELECT MIN(OrderDate) AS EarliestOrder,
       MAX(OrderDate) AS LatestOrder
FROM Orders;

SELECT *
FROM Customers
WHERE State = 'NY'or Country = 'United States' 

SELECT *
FROM Orders
WHERE CustomerID IN (
    SELECT CustomerID
    FROM Customers
);

SELECT CustomerName as [Customer Name], Notes FROM Customers