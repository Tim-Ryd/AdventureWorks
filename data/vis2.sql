USE AdventureWorks2025

SELECT * FROM Production.ProductCategory
SELECT * FROM Production.ProductSubcategory
SELECT * FROM Production.Product
SELECT * FROM Sales.SalesOrderDetail


SELECT
    pc.Name AS CategoryName,
    SUM(sod.LineTotal) AS TotalSales
FROM Production.ProductCategory pc
INNER JOIN Production.ProductSubcategory psc ON pc.ProductCategoryID = psc.ProductCategoryID
INNER JOIN Production.Product p ON psc.ProductSubcategoryID = p.ProductSubcategoryID
INNER JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY pc.Name
ORDER BY TotalSales DESC

SELECT SUM(LineTotal) FROM Sales.SalesOrderDetail