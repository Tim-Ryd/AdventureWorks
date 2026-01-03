WITH Profit AS (
    SELECT 
        pc.Name AS ProductCategory,
        SUM(sod.LineTotal) AS Revenue,
        SUM(sod.OrderQty) AS Qty,
        SUM(sod.LineTotal) - SUM(sod.OrderQty * c.StandardCost) AS Margin
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory psc  -- Ifall det finns NULL-värden i Subcategory
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc  -- Ifall det finns NULL-värden i Productcategory
        ON psc.ProductCategoryID = pc.ProductCategoryID
    JOIN (
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
    RANK() OVER (ORDER BY SUM(Margin) DESC) AS CategoryRank
FROM Profit
CROSS JOIN Totals t -- Lägga till total på samtliga rader
GROUP BY ProductCategory, t.GrandTotalMargin
ORDER BY CategoryRank;
