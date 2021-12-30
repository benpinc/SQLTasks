USE WideWorldImporters

--Stored procedure to retrieve the details of a table
exec sp_columns Invoices

-- Simple query
SELECT *
FROM Sales.InvoiceLines;

--Basic query search on details of an invoice
SELECT *
FROM Sales.InvoiceLines
WHERE InvoiceID = 2

--Query with a filter condition where order quantity is more than 250
SELECT DISTINCT StockItemID, Description, Quantity
FROM Sales.Invoicelines
WHERE Quantity >250
ORDER BY StockItemID;

--Query using inner join and date filter and ordering
SELECT I.InvoiceID, IL.StockItemID, I.InvoiceDate, IL.Description, IL.Quantity, IL.UnitPrice
FROM Sales.InvoiceLines AS IL
JOIN Sales.Invoices AS I
ON I.InvoiceID = IL.InvoiceID
WHERE I.InvoiceDate = '2016-01-01'
ORDER BY I.InvoiceDate;

--Query using left outer join to retrieve total number of invoices for every customer
SELECT Sales.Customers.CustomerID, Sales.Customers.CustomerName,COUNT(Sales.Invoices.InvoiceID) AS [Number of invoices]
FROM Sales.Customers
LEFT OUTER JOIN Sales.Invoices
ON Sales.Customers.CustomerID = Sales.Invoices.CustomerID 
GROUP BY Sales.Customers.CustomerID,Sales.Customers.CustomerName
ORDER BY [Number of invoices] DESC;

--Query using aggregations, joins and grouping
SELECT I.InvoiceID, IL.StockItemID, SUM(IL.Quantity) AS TotalQuantity, SUM(IL.UnitPrice) AS TotalPrice
FROM Sales.InvoiceLines AS IL
JOIN Sales.Invoices AS I
ON I.InvoiceID = IL.InvoiceID
WHERE I.InvoiceID = 2
GROUP BY I.InvoiceID, IL.StockItemID;

--Subquery to return customer details based on an invoice via a subquery
    SELECT sales.Customers.CustomerName,sales.Customers.DeliveryAddressLine1,DeliveryAddressLine2
	FROM Sales.Customers
	WHERE CustomerID IN (
	SELECT Sales.Invoices.CustomerID
	FROM Sales.Invoices
	WHERE Sales.Invoices.InvoiceID=2
	)
;
--Query using alias, case, joins, groupings, subquery and having statement to categorise customers based on the 
-- number of chiller items together with their contact details
SELECT	C.CustomerID, 
		C.CustomerName, 
		C.PhoneNumber, 
		C.FaxNumber, 
		SUM(I.TotalChillerItems) AS [Total Chiller Items], 
		Category = case
			when SUM(I.TotalChillerItems) <3 THEN 'Low'
			when SUM(I.TotalChillerItems) BETWEEN 3 and 4 THEN 'Middle'
			else 'High' 
		end
FROM Sales.Customers AS C
JOIN Sales.Invoices AS I
ON I.CustomerID = C.CustomerID
--JOIN Sales.CustomerCategories
--ON Sales.CustomerCategories.CustomerCategoryID = Customers.CustomerCategoryID
WHERE C.CustomerCategoryID IN (
	SELECT Sales.CustomerCategories.CustomerCategoryID
	FROM Sales.CustomerCategories
	WHERE CustomerCategoryName LIKE 'Novel%')
GROUP BY C.CustomerID, C.CustomerName, C.PhoneNumber, C.FaxNumber
HAVING SUM(I.TotalChillerItems)>0;

--Query using aggregations and data conversions via cast to format data
SELECT	I.InvoiceID, 
		IL.StockItemID, 
		CAST(SUM(IL.Quantity) AS decimal(4,1)) AS TotalQuantity, 
		--SUM(IL.UnitPrice) AS TotalPrice,
		CAST(SUM(IL.UnitPrice) AS decimal(4,1)) AS UnitTotalPrice
FROM Sales.InvoiceLines AS IL
JOIN Sales.Invoices AS I
ON I.InvoiceID = IL.InvoiceID
WHERE I.InvoiceID = 2
GROUP BY I.InvoiceID, IL.StockItemID;

--Concatenating strings, formatting dates and currency to US Dollars - would be En-GB for GBP, filtering results for those with accounts opened in the last 8 years
SELECT	CustomerRef = concat (C.CustomerID, C.CustomerName),
		ContactDetails = concat('Tel:',C.PhoneNumber,' Fax:',C.FaxNumber),
		C.DeliveryPostalCode,
		Credit = FORMAT(C.CreditLimit,'C','En-US'),
		C.AccountOpenedDate,
		AccountStart = FORMAT(C.AccountOpenedDate,'dd MMM, yyyy')
FROM Sales.Customers AS C
WHERE C.AccountOpenedDate > dateadd(year,-8,GETDATE());
