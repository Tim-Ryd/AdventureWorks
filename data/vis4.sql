SELECT TOP 1 * FROM Sales.SalesOrderHeader

SELECT
    YEAR(OrderDate) AS Year,
    COUNT(SalesOrderID) AS NbrOrders,
    SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY Year;
