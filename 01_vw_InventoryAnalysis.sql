
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS Category,
    ISNULL(p.Weight, 0) AS ProductWeight, -- Cleaning null weights
    p.StandardCost,
    p.ListPrice,
    -- Business Logic: Creating a Simulated Inventory Level
    CAST(ISNULL(p.Weight, 50) * 2 AS INT) AS CurrentStock, 
    -- Aggregating Sales for Inventory Turnover calculation
    ISNULL(SUM(sod.OrderQty), 0) AS TotalUnitsSold,
    ISNULL(SUM(sod.LineTotal), 0) AS TotalRevenue,
    -- Categorizing Inventory Status
    CASE 
        WHEN (ISNULL(p.Weight, 50) * 2) < 20 THEN 'Critical'
        WHEN (ISNULL(p.Weight, 50) * 2) BETWEEN 20 AND 100 THEN 'Healthy'
        ELSE 'Overstocked'
    END AS StockStatus
FROM SalesLT.Product p
LEFT JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
LEFT JOIN SalesLT.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY 
    p.ProductID, p.Name, pc.Name, p.Weight, p.StandardCost, p.ListPrice
ORDER BY TotalUnitsSold DESC;



CREATE VIEW vw_InventoryAnalysis AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS CategoryName,
    p.StandardCost,
    p.ListPrice,
    -- Simulating On-Hand Stock: Using Weight/Size logic to create a dynamic inventory number
    ISNULL(p.Weight, 50) * 2 AS OnHandQty, 
    -- Target Stock: Creating a benchmark for 'Stock-Out' analysis
    ISNULL(p.Weight, 50) * 1.5 AS SafetyStockLevel,
    (SELECT SUM(OrderQty) FROM SalesLT.SalesOrderDetail WHERE ProductID = p.ProductID) AS UnitsSold
FROM SalesLT.Product p
LEFT JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID;


CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Year INT,
    Quarter INT,
    Month INT,
    MonthName VARCHAR(15),
    DayOfWeek VARCHAR(15)
);

-- Basic script to populate 2024-2026
DECLARE @StartDate DATE = '2024-01-01', @EndDate DATE = '2026-12-31';
WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO DimDate (DateKey, FullDate, Year, Quarter, Month, MonthName, DayOfWeek)
    SELECT 
        CAST(CONVERT(VARCHAR(8), @StartDate, 112) AS INT),
        @StartDate, YEAR(@StartDate), DATEPART(QUARTER, @StartDate),
        MONTH(@StartDate), DATENAME(MONTH, @StartDate), DATENAME(WEEKDAY, @StartDate);
    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;





ALTER VIEW vw_InventoryAnalysis AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS CategoryName,
    -- Pulling StandardCost directly from the Product table
    p.StandardCost,
    p.ListPrice,
    -- Simulating On-Hand Stock: If Weight is null, we default to 50 units
    CAST(ISNULL(p.Weight, 50) * 2 AS INT) AS OnHandQty, 
    -- Safety Stock: Defining a threshold for 'Stock-Out' alerts
    CAST(ISNULL(p.Weight, 50) * 1.5 AS INT) AS SafetyStockLevel
FROM SalesLT.Product p
LEFT JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID;




USE AdventureWorksLT2025
GO;
CREATE OR ALTER VIEW vw_InventoryAnalysis AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS CategoryName,
    p.StandardCost,
    p.ListPrice,
    CAST(ISNULL(p.Weight, 50) * (1.0 + (p.ProductID % 3) * 0.4) AS INT) AS OnHandQty, 
    CAST(ISNULL(p.Weight, 50) * 1.5 AS INT) AS SafetyStockLevel
FROM SalesLT.Product p
LEFT JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID;


ALTER VIEW vw_InventoryAnalysis AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS CategoryName,
    p.StandardCost,
    p.ListPrice,
    CAST(((p.ProductID % 50) + 5) AS INT) AS OnHandQty, 
    CAST(((p.ProductID % 30) + 15) AS INT) AS SafetyStockLevel
FROM SalesLT.Product p
LEFT JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID;