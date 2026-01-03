SELECT TOP 1 * FROM Sales.SalesTerritory
SELECT TOP 1 * FROM Sales.SalesOrderHeader
SELECT  * FROM Sales.Customer 
SELECT TOP 1 * FROM Sales.Store


SELECT
    t.Name AS Region,
    CASE
        WHEN c.StoreID IS NOT NULL THEN 'Store'
        ELSE 'Individual'
    END AS CustomerType,
    AVG(soh.TotalDue) AS AvgOrderValue
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesTerritory t ON soh.TerritoryID = t.TerritoryID
INNER JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
GROUP BY
    t.Name,
    CASE
        WHEN c.StoreID IS NOT NULL THEN 'Store'
        ELSE 'Individual'
    END
ORDER BY AVG(soh.TotalDue) DESC;