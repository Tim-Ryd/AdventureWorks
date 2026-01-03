WITH ProductTotals AS (
    SELECT 
        p.ProductID,
        p.Name,
        pc.Name AS ProductCategory,
        SUM(sod.OrderQty) AS Qty,
        SUM(sod.LineTotal) AS Revenue,
        SUM(sod.LineTotal) - SUM(sod.OrderQty * c.StandardCost) AS Margin
    FROM Sales.SalesOrderDetail sod
    INNER JOIN Production.Product p 
        ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory psc
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc
        ON psc.ProductCategoryID = pc.ProductCategoryID
    INNER JOIN (
        SELECT 
            ProductID,
            StandardCost,
            ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY StartDate DESC) AS rn
        FROM Production.ProductCostHistory
    ) c ON c.ProductID = p.ProductID AND c.rn = 1
    GROUP BY p.ProductID, p.Name, pc.Name
)
SELECT 
    pt.ProductID,
    pt.Name,
    pt.ProductCategory,
    pt.Qty,
    pt.Margin
FROM ProductTotals pt
ORDER BY pt.Qty DESC;
