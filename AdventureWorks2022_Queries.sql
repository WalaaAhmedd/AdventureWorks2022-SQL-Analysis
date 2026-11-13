
USE AdventureWorks2022;

/*
   SELECT, WHERE, ORDER BY, TOP, DISTINCT
 */

-- Q1. What are the 20 most recently placed sales orders?
SELECT TOP (20)
    SalesOrderID,
    OrderDate,
    CustomerID,
    TotalDue
FROM Sales.SalesOrderHeader
ORDER BY OrderDate DESC, SalesOrderID DESC;


-- Q2. Which orders are still in process?
SELECT
    SalesOrderID,
    OrderDate,
    CustomerID,
    Status,
    TotalDue
FROM Sales.SalesOrderHeader
WHERE Status = 1
ORDER BY OrderDate DESC;


-- Q3. Which orders were placed online?
SELECT
    SalesOrderID,
    OrderDate,
    CustomerID,
    TotalDue
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 1
ORDER BY OrderDate DESC;


-- Q4. Which products are currently listed with a price above $1,000?
SELECT
    ProductID,
    Name AS ProductName,
    ListPrice
FROM Production.Product
WHERE ListPrice > 1000
ORDER BY ListPrice DESC;


-- Q5. Which products are not currently assigned to a product subcategory?
SELECT
    ProductID,
    Name AS ProductName,
    ProductSubcategoryID
FROM Production.Product
WHERE ProductSubcategoryID IS NULL
ORDER BY Name;


-- Q6. What different order statuses exist in the sales data?
SELECT DISTINCT
    Status
FROM Sales.SalesOrderHeader
ORDER BY Status;


-- Q7. Which products have a standard cost but no list price?
SELECT
    ProductID,
    Name AS ProductName,
    StandardCost,
    ListPrice
FROM Production.Product
WHERE StandardCost > 0
  AND ListPrice = 0
ORDER BY StandardCost DESC;


-- Q8. Which sales orders have not yet been shipped?
SELECT
    SalesOrderID,
    OrderDate,
    DueDate,
    ShipDate,
    CustomerID
FROM Sales.SalesOrderHeader
WHERE ShipDate IS NULL
ORDER BY DueDate;


/* 
    COUNT, SUM, AVG, GROUP BY, HAVING, CASE
   */

-- Q9. How many sales orders have been placed?
SELECT
    COUNT(*) AS TotalOrders
FROM Sales.SalesOrderHeader;


-- Q10. What are the total sales, tax, freight, and amount due?
SELECT
    SUM(SubTotal) AS TotalBeforeTaxAndFreight,
    SUM(TaxAmt) AS TotalTax,
    SUM(Freight) AS TotalFreight,
    SUM(TotalDue) AS TotalAmountDue
FROM Sales.SalesOrderHeader;


-- Q11. How many orders were placed in each year?
SELECT
    YEAR(OrderDate) AS OrderYear,
    COUNT(*) AS NumberOfOrders
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;


-- Q12. What is the average order value for each year?
SELECT
    YEAR(OrderDate) AS OrderYear,
    COUNT(*) AS NumberOfOrders,
    AVG(TotalDue) AS AverageOrderValue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;


-- Q13. Which customers have placed more than five orders?
SELECT
    CustomerID,
    COUNT(*) AS NumberOfOrders
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(*) > 5
ORDER BY NumberOfOrders DESC;


-- Q14. How many orders fall into each order-status category?
SELECT
    CASE Status
        WHEN 1 THEN 'In Process'
        WHEN 2 THEN 'Approved'
        WHEN 3 THEN 'Backordered'
        WHEN 4 THEN 'Rejected'
        WHEN 5 THEN 'Shipped'
        WHEN 6 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS OrderStatus,
    COUNT(*) AS NumberOfOrders
FROM Sales.SalesOrderHeader
GROUP BY Status
ORDER BY NumberOfOrders DESC;


-- Q15. Which products have sold more than 500 units in total?
SELECT
    ProductID,
    SUM(OrderQty) AS UnitsSold
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(OrderQty) > 500
ORDER BY UnitsSold DESC;


-- Q16. What is the total revenue generated in each month?
SELECT
    YEAR(OrderDate) AS SalesYear,
    MONTH(OrderDate) AS SalesMonth,
    SUM(TotalDue) AS MonthlyRevenue
FROM Sales.SalesOrderHeader
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate)
ORDER BY SalesYear, SalesMonth;


/*
  INNER JOIN, LEFT JOIN, multi-table joins
   */

-- Q17. What are the names and prices of products in each subcategory?
SELECT
    p.ProductID,
    p.Name AS ProductName,
    ps.Name AS SubcategoryName,
    p.ListPrice
FROM Production.Product AS p
INNER JOIN Production.ProductSubcategory AS ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
ORDER BY ps.Name, p.Name;


-- Q18. Which products belong to each product category?
SELECT
    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS CategoryName,
    ps.Name AS SubcategoryName
FROM Production.Product AS p
LEFT JOIN Production.ProductSubcategory AS ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS pc
    ON ps.ProductCategoryID = pc.ProductCategoryID
ORDER BY pc.Name, ps.Name, p.Name;


-- Q19. Which customer placed each sales order?
SELECT TOP (100)
    soh.SalesOrderID,
    soh.OrderDate,
    soh.CustomerID,
    CONCAT(pp.FirstName, ' ', pp.LastName) AS IndividualCustomerName,
    s.Name AS StoreName,
    soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.Customer AS c
    ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.Person AS pp
    ON c.PersonID = pp.BusinessEntityID
LEFT JOIN Sales.Store AS s
    ON c.StoreID = s.BusinessEntityID
ORDER BY soh.OrderDate DESC, soh.SalesOrderID DESC;


-- Q20. Which sales orders were handled by each salesperson?
SELECT
    soh.SalesOrderID,
    soh.OrderDate,
    soh.SalesPersonID,
    CONCAT(p.FirstName, ' ', p.LastName) AS SalesPersonName,
    soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesPerson AS sp
    ON soh.SalesPersonID = sp.BusinessEntityID
INNER JOIN Person.Person AS p
    ON sp.BusinessEntityID = p.BusinessEntityID
ORDER BY soh.OrderDate DESC;


-- Q21. How much revenue was generated in each sales territory?
SELECT
    st.TerritoryID,
    st.Name AS TerritoryName,
    st.CountryRegionCode,
    COUNT(soh.SalesOrderID) AS NumberOfOrders,
    SUM(soh.TotalDue) AS TotalRevenue
FROM Sales.SalesTerritory AS st
LEFT JOIN Sales.SalesOrderHeader AS soh
    ON st.TerritoryID = soh.TerritoryID
GROUP BY
    st.TerritoryID,
    st.Name,
    st.CountryRegionCode
ORDER BY TotalRevenue DESC;


-- Q22. Which products were included in each sales order?
SELECT TOP (100)
    soh.SalesOrderID,
    soh.OrderDate,
    p.ProductID,
    p.Name AS ProductName,
    sod.OrderQty,
    sod.UnitPrice,
    sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
ORDER BY soh.OrderDate DESC, soh.SalesOrderID;


-- Q23. Which customers have never placed a sales order?
SELECT
    c.CustomerID,
    c.PersonID,
    c.StoreID
FROM Sales.Customer AS c
LEFT JOIN Sales.SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
WHERE soh.SalesOrderID IS NULL
ORDER BY c.CustomerID;


-- Q24. Which shipping methods are used most often?
SELECT
    sm.ShipMethodID,
    sm.Name AS ShipMethodName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders,
    SUM(soh.Freight) AS TotalFreight
FROM Purchasing.ShipMethod AS sm
LEFT JOIN Sales.SalesOrderHeader AS soh
    ON sm.ShipMethodID = soh.ShipMethodID
GROUP BY
    sm.ShipMethodID,
    sm.Name
ORDER BY NumberOfOrders DESC;


/*
 business calculations, subqueries, CTEs
   */

-- Q25. Which ten products generated the highest sales revenue?
SELECT TOP (10)
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.OrderQty) AS UnitsSold,
    SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.Name
ORDER BY TotalRevenue DESC;


-- Q26. Which ten customers spent the most?
SELECT TOP (10)
    soh.CustomerID,
    COUNT(*) AS NumberOfOrders,
    SUM(soh.TotalDue) AS TotalSpent
FROM Sales.SalesOrderHeader AS soh
GROUP BY soh.CustomerID
ORDER BY TotalSpent DESC;


-- Q27. Which products received the highest total discount amount?
SELECT TOP (10)
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.OrderQty) AS UnitsSold,
    SUM(sod.UnitPrice * sod.OrderQty) AS SalesBeforeDiscount,
    SUM(sod.LineTotal) AS SalesAfterDiscount,
    SUM((sod.UnitPrice * sod.OrderQty) - sod.LineTotal) AS TotalDiscount
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.Name
ORDER BY TotalDiscount DESC;


-- Q28. Which products have generated more revenue than the average product?
WITH ProductRevenue AS
(
    SELECT
        ProductID,
        SUM(LineTotal) AS TotalRevenue
    FROM Sales.SalesOrderDetail
    GROUP BY ProductID
)
SELECT
    ProductID,
    TotalRevenue
FROM ProductRevenue
WHERE TotalRevenue > (
    SELECT AVG(TotalRevenue)
    FROM ProductRevenue
)
ORDER BY TotalRevenue DESC;


-- Q29. Which sales representatives generated the highest sales this year?
-- Uses the current calendar year at the time the query is run.
SELECT
    sp.BusinessEntityID AS SalesPersonID,
    CONCAT(p.FirstName, ' ', p.LastName) AS SalesPersonName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders,
    SUM(soh.SubTotal) AS SalesBeforeTaxAndFreight
FROM Sales.SalesPerson AS sp
INNER JOIN Person.Person AS p
    ON sp.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader AS soh
    ON sp.BusinessEntityID = soh.SalesPersonID
   AND soh.OrderDate >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
   AND soh.OrderDate < DATEFROMPARTS(YEAR(GETDATE()) + 1, 1, 1)
GROUP BY
    sp.BusinessEntityID,
    p.FirstName,
    p.LastName
ORDER BY SalesBeforeTaxAndFreight DESC;


-- Q30. Which orders took longer than the average number of days to ship?
WITH OrderShippingTime AS
(
    SELECT
        SalesOrderID,
        OrderDate,
        ShipDate,
        DATEDIFF(DAY, OrderDate, ShipDate) AS DaysToShip
    FROM Sales.SalesOrderHeader
    WHERE ShipDate IS NOT NULL
)
SELECT
    SalesOrderID,
    OrderDate,
    ShipDate,
    DaysToShip
FROM OrderShippingTime
WHERE DaysToShip > (
    SELECT AVG(CAST(DaysToShip AS DECIMAL(10, 2)))
    FROM OrderShippingTime
)
ORDER BY DaysToShip DESC;


-- Q31. What percentage of orders were placed online versus offline?
SELECT
    CASE
        WHEN OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Offline'
    END AS OrderChannel,
    COUNT(*) AS NumberOfOrders,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5, 2)
    ) AS PercentageOfOrders
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag
ORDER BY NumberOfOrders DESC;


-- Q32. Which product categories contribute the most to total sales?
SELECT
    pc.Name AS CategoryName,
    SUM(sod.LineTotal) AS TotalRevenue,
    CAST(
        100.0 * SUM(sod.LineTotal)
        / SUM(SUM(sod.LineTotal)) OVER ()
        AS DECIMAL(6, 2)
    ) AS PercentageOfRevenue
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
INNER JOIN Production.ProductSubcategory AS ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS pc
    ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY TotalRevenue DESC;


/* 
   Window Functions, ranking, running totals, LAG
  */

-- Q33. How do customers rank based on their total spending?
WITH CustomerSpending AS
(
    SELECT
        CustomerID,
        SUM(TotalDue) AS TotalSpent
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    TotalSpent,
    DENSE_RANK() OVER (ORDER BY TotalSpent DESC) AS SpendingRank
FROM CustomerSpending
ORDER BY SpendingRank, CustomerID;


-- Q34. What is the running total of monthly sales?
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS SalesMonth,
        SUM(TotalDue) AS MonthlyRevenue
    FROM Sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT
    SalesMonth,
    MonthlyRevenue,
    SUM(MonthlyRevenue) OVER (
        ORDER BY SalesMonth
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningRevenue
FROM MonthlySales
ORDER BY SalesMonth;


-- Q35. How did monthly revenue change compared with the previous month?
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS SalesMonth,
        SUM(TotalDue) AS MonthlyRevenue
    FROM Sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
SalesWithPreviousMonth AS
(
    SELECT
        SalesMonth,
        MonthlyRevenue,
        LAG(MonthlyRevenue) OVER (ORDER BY SalesMonth) AS PreviousMonthRevenue
    FROM MonthlySales
)
SELECT
    SalesMonth,
    MonthlyRevenue,
    PreviousMonthRevenue,
    MonthlyRevenue - PreviousMonthRevenue AS RevenueDifference,
    CAST(
        100.0 * (MonthlyRevenue - PreviousMonthRevenue)
        / NULLIF(PreviousMonthRevenue, 0)
        AS DECIMAL(10, 2)
    ) AS MonthOverMonthChangePercent
FROM SalesWithPreviousMonth
ORDER BY SalesMonth;


-- Q36. What is each customer's most recent order?
WITH CustomerOrders AS
(
    SELECT
        CustomerID,
        SalesOrderID,
        OrderDate,
        TotalDue,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID
            ORDER BY OrderDate DESC, SalesOrderID DESC
        ) AS OrderNumber
    FROM Sales.SalesOrderHeader
)
SELECT
    CustomerID,
    SalesOrderID,
    OrderDate,
    TotalDue
FROM CustomerOrders
WHERE OrderNumber = 1
ORDER BY OrderDate DESC;


-- Q37. What are the top three best-selling products in each category?
WITH ProductSales AS
(
    SELECT
        pc.Name AS CategoryName,
        p.ProductID,
        p.Name AS ProductName,
        SUM(sod.OrderQty) AS UnitsSold
    FROM Sales.SalesOrderDetail AS sod
    INNER JOIN Production.Product AS p
        ON sod.ProductID = p.ProductID
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY
        pc.Name,
        p.ProductID,
        p.Name
),
RankedProducts AS
(
    SELECT
        CategoryName,
        ProductID,
        ProductName,
        UnitsSold,
        ROW_NUMBER() OVER (
            PARTITION BY CategoryName
            ORDER BY UnitsSold DESC, ProductID
        ) AS ProductRank
    FROM ProductSales
)
SELECT
    CategoryName,
    ProductID,
    ProductName,
    UnitsSold,
    ProductRank
FROM RankedProducts
WHERE ProductRank <= 3
ORDER BY CategoryName, ProductRank;


-- Q38. Which customers have increased or decreased their order value?
-- Compares each customer's order with their previous order.
WITH CustomerOrderHistory AS
(
    SELECT
        CustomerID,
        SalesOrderID,
        OrderDate,
        TotalDue,
        LAG(TotalDue) OVER (
            PARTITION BY CustomerID
            ORDER BY OrderDate, SalesOrderID
        ) AS PreviousOrderValue
    FROM Sales.SalesOrderHeader
)
SELECT
    CustomerID,
    SalesOrderID,
    OrderDate,
    TotalDue,
    PreviousOrderValue,
    TotalDue - PreviousOrderValue AS DifferenceFromPreviousOrder,
    CASE
        WHEN PreviousOrderValue IS NULL THEN 'First recorded order'
        WHEN TotalDue > PreviousOrderValue THEN 'Higher than previous order'
        WHEN TotalDue < PreviousOrderValue THEN 'Lower than previous order'
        ELSE 'Same as previous order'
    END AS OrderValueTrend
FROM CustomerOrderHistory
ORDER BY CustomerID, OrderDate;


-- Q39. Which products have a list price above the average price in their subcategory?
SELECT
    p.ProductID,
    p.Name AS ProductName,
    ps.Name AS SubcategoryName,
    p.ListPrice,
    AVG(p.ListPrice) OVER (
        PARTITION BY p.ProductSubcategoryID
    ) AS SubcategoryAverageListPrice
FROM Production.Product AS p
INNER JOIN Production.ProductSubcategory AS ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
WHERE p.ListPrice > 0
  AND p.ListPrice > (
      SELECT AVG(p2.ListPrice)
      FROM Production.Product AS p2
      WHERE p2.ProductSubcategoryID = p.ProductSubcategoryID
        AND p2.ListPrice > 0
  )
ORDER BY SubcategoryName, p.ListPrice DESC;


-- Q40. How does each salesperson's year-to-date sales compare with last year's sales?
SELECT
    sp.BusinessEntityID AS SalesPersonID,
    CONCAT(p.FirstName, ' ', p.LastName) AS SalesPersonName,
    sp.SalesYTD,
    sp.SalesLastYear,
    sp.SalesYTD - sp.SalesLastYear AS DifferenceFromLastYear,
    CAST(
        100.0 * (sp.SalesYTD - sp.SalesLastYear)
        / NULLIF(sp.SalesLastYear, 0)
        AS DECIMAL(10, 2)
    ) AS DifferencePercent
FROM Sales.SalesPerson AS sp
INNER JOIN Person.Person AS p
    ON sp.BusinessEntityID = p.BusinessEntityID
ORDER BY DifferenceFromLastYear DESC;

