SELECT TOP 5 * FROM Sales.SalesOrderDetal
SELECT TOP 5 * FROM Production.Product
SELECT TOP 5 * FROM Production.ProductSubcategory
SELECT TOP 5 * FROM Production.ProductCategory
SELECT TOP 5 * FROM Production.ProductCostHistory


WITH Profit AS (
    SELECT 
        p.ProductID,
        p.Name,
        pc.Name AS ProductCategory,
        psc.Name AS ProductSubcategory,
        SUM(sod.LineTotal) AS Revenue,
        SUM(sod.OrderQty) AS Qty,
        SUM(sod.LineTotal) - SUM(sod.OrderQty * c.StandardCost) AS Margin
    FROM Sales.SalesOrderDetail sod
    INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory psc -- Left join ifall det finns NULL-värden i Subcategory
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc  -- Ifall det finns NULL-värden i Productcategory
        ON psc.ProductCategoryID = pc.ProductCategoryID
    INNER JOIN (
        SELECT ProductID, StandardCost,
               ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY StartDate DESC) AS rn
        FROM Production.ProductCostHistory
    ) c ON c.ProductID = p.ProductID AND c.rn = 1
    GROUP BY p.ProductID, p.Name, pc.Name, psc.Name
)
SELECT *,
    CASE 
        WHEN Revenue > (SELECT AVG(Revenue) FROM Profit)
         AND Margin > (SELECT AVG(Margin) FROM Profit)
        THEN 'Winner'
        WHEN Margin < 0 THEN 'Loser (Negative Margin)'
        WHEN Revenue < (SELECT AVG(Revenue) FROM Profit) THEN 'Low Performer'
        ELSE 'Neutral'
    END AS PerformanceGroup
FROM Profit
ORDER BY PerformanceGroup, Revenue DESC;

