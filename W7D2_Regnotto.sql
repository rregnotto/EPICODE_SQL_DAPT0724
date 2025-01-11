-- W7D2 Esercizio lezione di pratica

USE AdventureWorksDW;

-- ES 1 Scrivi una query per verificare che il campo ProductKey nella tabella DimProduct sia una chiave primaria. 
-- Quali considerazioni/ragionamenti è necessario che tu faccia?
-- usa il group by per trovare la PK

SELECT
	ProductKey
FROM
 DimProduct
 GROUP BY 
	productKey
HAVING 
	COUNT(*) > 1;
-- ritorna la colonna productkey NULL perché il conteggio dei valori ProductKey non è mai maggiore di 1, quindi ProductKEy è una PK

-- Es 2 Scrivi una query per verificare che la combinazione dei campi SalesOrderNumber e SalesOrderLineNumber sia una PK.
SELECT
	SalesOrderNumber,
    SalesOrderLineNumber
FROM
	factresellersales
GROUP BY
	SalesOrderNumber,
    SalesOrderLineNumber
HAVING 
	COUNT(*)>1;
    
-- Es 2 Metodo 2 
    
SELECT
	CONCAT(SalesOrderNumber, SalesOrderLineNumber) AS PK
FROM
	factresellersales
GROUP BY
	PK
HAVING
	COUNT(*)>1;
-- sfrutto ptoprietà della pk di essere un campo univoco

-- 3 Conta il numero transazioni (SalesOrderLineNumber) realizzate ogni giorno a partire dal 1 Gennaio 2020.
SELECT 
	COUNT(SalesOrderLineNumber) as OrderLine,
    OrderDate
FROM 
	factresellersales
GROUP BY
	OrderDate
HAVING
	OrderDate >= '2020-01-01';

-- 4 Calcola il fatturato totale (FactResellerSales.SalesAmount), la quantità totale venduta (FactResellerSales.OrderQuantity) e 
-- il prezzo medio di vendita (FactResellerSales.UnitPrice) per prodotto (DimProduct) a partire dal 1 Gennaio 2020. 
-- Il result set deve esporre pertanto il nome del prodotto, il fatturato totale, la quantità totale venduta e il prezzo medio di vendita. 
-- I campi in output devono essere parlanti!

SELECT
	SUM(SalesAmount) as FatturatoTot,
    SUM(OrderQuantity) as TotaleVenduti,
    AVG(UnitPrice) as PrezzoMedio,
    p.ProductKey,
    EnglishProductName,
    OrderDate
FROM
	factresellersales as f
INNER JOIN
	dimproduct as p
ON
	f.ProductKey = p.ProductKey
GROUP BY
	OrderDate, p.ProductKey, EnglishProductName
HAVING 
	OrderDate >= '2020-01-01';

-- Es 5 Calcola il fatturato totale (FactResellerSales.SalesAmount) e la quantità totale venduta (FactResellerSales.OrderQuantity) per Categoria prodotto (DimProductCategory). 
-- Il result set deve esporre pertanto il nome della categoria prodotto, il fatturato totale e la quantità totale venduta. 
-- I campi in output devono essere parlanti!

SELECT
	EnglishProductCategoryName AS NomeCategoria,
	SUM(SalesAmount) AS TotaleFatturato,
    SUM(OrderQuantity) AS TotaleVenduto
FROM
	factresellersales AS f
INNER JOIN
	dimproduct AS p
ON 
	f.ProductKey = p.ProductKey
 INNER JOIN
	dimproductsubcategory AS sub
ON
	p.productsubcategoryKey = sub.productsubcategoryKey
INNER JOIN
	dimproductcategory AS c
ON
	sub.productcategorykey = c.productcategorykey
GROUP BY
	EnglishProductCategoryName;

-- Es 6 Calcola il fatturato totale per area città (DimGeography.City) realizzato a partire dal 1 Gennaio 2020. 
-- Il result set deve esporre lʼelenco delle città con fatturato realizzato superiore a 60K.

SELECT
	SUM(SalesAmount) AS TotaleFatturato,
    City
FROM
	factresellersales AS f
INNER JOIN
	dimgeography AS g
ON
	f.SalesTerritoryKey = g.SalesTerritoryKey
WHERE
	OrderDate >= '2020-01-01'
GROUP BY
	City
HAVING
	SUM(SalesAmount) > 60000;
