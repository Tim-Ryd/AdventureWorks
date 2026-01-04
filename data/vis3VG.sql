SELECT TOP 5 * FROM Sales.SalesOrderDetail
SELECT TOP 5 * FROM Production.Product
SELECT TOP 5 * FROM Production.ProductSubcategory
SELECT TOP 5 * FROM Production.ProductCategory
SELECT TOP 5 * FROM Production.ProductCostHistory

USE AdventureWorks2025;

WITH Profit AS (
    SELECT 
        pc.Name AS ProductCategory,
        SUM(sod.LineTotal) AS Revenue,
        SUM(sod.OrderQty) AS Qty,
        SUM(sod.LineTotal) - SUM(sod.OrderQty * c.StandardCost) AS Margin
    FROM Sales.SalesOrderDetail sod
    INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory psc  
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc  
        ON psc.ProductCategoryID = pc.ProductCategoryID
    INNER JOIN (
        SELECT ProductID, StandardCost,
               ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY StartDate DESC) AS rn
        FROM Production.ProductCostHistory
    ) c ON c.ProductID = p.ProductID AND c.rn = 1
    GROUP BY pc.Name
),

Totals AS (
    SELECT SUM(Margin) AS GrandTotalMargin
    FROM Profit
)

SELECT 
    ProductCategory,
    SUM(Revenue) AS TotalRevenue,
    SUM(Margin) AS TotalMargin,
    SUM(Qty) AS TotalQty,
    SUM(Margin) * 1.0 / NULLIF(SUM(Revenue), 0) AS MarginPct,
    SUM(Margin) * 1.0 / t.GrandTotalMargin AS MarginShare,
    RANK() OVER (ORDER BY SUM(Margin) DESC) AS CategoryRank -- Rank utifrån total Margin
FROM Profit
CROSS JOIN Totals t -- Lägga till total på samtliga rader
GROUP BY ProductCategory, t.GrandTotalMargin
ORDER BY CategoryRank;
