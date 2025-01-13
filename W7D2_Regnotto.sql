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
	OrderDate >= '2020-01-01'
ORDER BY
	FatturatoTot DESC;

-- correzione AVGprice - Salvatore

SELECT
	p.EnglishProductName,
	SUM(f.SalesAmount) as FatturatoTot,
    SUM(f.OrderQuantity) as TotaleVenduti,
    SUM(f.SalesAmount)/SUM(f.OrderQuantity) as PrezzoMedio1,
    AVG(f.UnitPrice) as PrezzoMedio2
FROM
	factresellersales as f
LEFT JOIN
	dimproduct as p
ON
	f.ProductKey = p.ProductKey
GROUP BY
	OrderDate, p.ProductKey, EnglishProductName
HAVING 
	OrderDate >= '2020-01-01'
ORDER BY
	FatturatoTot DESC;


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
	c.EnglishProductCategoryName;

-- Es 6 Calcola il fatturato totale per area città (DimGeography.City) realizzato a partire dal 1 Gennaio 2020. 
-- Il result set deve esporre lʼelenco delle città con fatturato realizzato superiore a 60K.

SELECT
	SUM(SalesAmount) AS TotaleFatturato,
    City
FROM
	factresellersales AS f
LEFT JOIN
	dimgeography AS g
ON
	f.SalesTerritoryKey = g.SalesTerritoryKey
WHERE
	OrderDate >= '2020-01-01'
GROUP BY
	City
HAVING
	SUM(SalesAmount) > 60000;


/*6.Calcola il fatturato totale per area città (DimGeography.City) realizzato a partire dal 1 Gennaio 2020. 
Il result set deve esporre l’elenco delle città con fatturato realizzato superiore a 60K.*/

SELECT CITY AS CITTA, 
SUM(SalesAmount) AS FATTURATO
-- , SUM(OrderQuantity) AS QUANT, AVG(UnitPrice) AS PREZZO_MEDIO_TOT, SUM(SalesAmount)/SUM(OrderQuantity)  -- , SUM(OrderQuantity)*AVG(UnitPrice)-SUM(SalesAmount)
FROM adventureworksdw.factresellersales A
LEFT JOIN dimproduct B ON A.ProductKey=B.ProductKey
-- LEFT JOIN dimproductsubcategory D ON B.ProductSubcategoryKey=D.ProductSubcategoryKey
-- LEFT JOIN dimproductcategory C ON C.ProductCategoryKey=D.ProductCategoryKey
LEFT JOIN dimreseller E ON E.ResellerKey=A.ResellerKey
LEFT JOIN dimgeography F ON F.GeographyKey=E.GeographyKey
WHERE A.ORDERDATE >= '2020-01-01'
GROUP BY 1
HAVING SUM(SalesAmount) >60000
ORDER BY 2 DESC;

-- deepdive chiave di join NON CORRETTA (Factresellersales->dimgeography tramite SALESTERRITORYKEY)
 -- --> A toronto sono associati non solo gli store effettivamente presenti nella città di TORONTO 
 -- ma anche tutti quelli del Territorio con SALESTERRITORYKEY=6 (CANADA)
select resellerkey, e.GeographyKey, SalesTerritoryKey, city
from dimreseller e
left join dimgeography F ON F.GeographyKey=E.GeographyKey
where resellerkey in (SELECT 
distinct resellerkey
FROM ADV.factresellersales A
-- LEFT JOIN dimproduct B ON A.ProductKey=B.ProductKey
-- LEFT JOIN dimproductsubcategory D ON B.ProductSubcategoryKey=D.ProductSubcategoryKey
-- LEFT JOIN dimproductcategory C ON C.ProductCategoryKey=D.ProductCategoryKey
-- LEFT JOIN dimreseller E ON E.ResellerKey=A.ResellerKey
LEFT JOIN dimgeography F ON F.SalesTerritoryKey=A.SalesTerritoryKey
WHERE A.ORDERDATE >= '2020-01-01'
and F.city='Toronto');



-- deepdive chiave di join corretta (dimreseller->dimgeography)
 -- --> A toronto sono associati solo gli store effettivamente presenti in città
select resellerkey, e.GeographyKey, SalesTerritoryKey, city
from dimreseller e
left join dimgeography F ON F.GeographyKey=E.GeographyKey
where resellerkey in (SELECT 
distinct e.resellerkey
FROM ADV.factresellersales A
-- LEFT JOIN dimproduct B ON A.ProductKey=B.ProductKey
-- LEFT JOIN dimproductsubcategory D ON B.ProductSubcategoryKey=D.ProductSubcategoryKey
-- LEFT JOIN dimproductcategory C ON C.ProductCategoryKey=D.ProductCategoryKey
 LEFT JOIN dimreseller E ON E.ResellerKey=A.ResellerKey
LEFT JOIN dimgeography F ON F.GeographyKey=e.GeographyKey
WHERE A.ORDERDATE >= '2020-01-01'
and F.city='Toronto');
