SELECT TOP 1 * FROM Sales.SalesOrderHeader

SELECT
    FORMAT(OrderDate, 'yyyy-MM') AS OrderMonth,
    SUM(TotalDue) AS SalesAmount
FROM Sales.SalesOrderHeader
GROUP BY FORMAT(OrderDate, 'yyyy-MM')
ORDER BY OrderMonth;

SELECT *
FROM Sales.SalesOrderHeader
WHERE CurrencyRateID IS NULL
