-- W6D4_REGNOTTO - Usa JOIN e SUBQUERY
-- 1. Esponi lʼanagrafica dei prodotti 
-- indicando per ciascun prodotto anche la sua sottocategoria (DimProduct, DimProductSubcategory).

USE AdventureWorksDW;

SELECT
	*
FROM
	dimproduct as P
INNER JOIN
	dimproductsubcategory as S
ON
	P.productsubcategorykey = S.productsubcategorykey;

-- 2. Esponi lʼanagrafica dei prodotti indicando per ciascun 
-- prodotto la sua sottocategoria e la sua categoria (DimProduct, DimProductSubcategory, DimProductCategory).

SELECT
	*
FROM
	dimproduct as P
INNER JOIN
	dimproductsubcategory as S
ON
	P.productsubcategorykey = S.productsubcategorykey
LEFT JOIN
	dimproductcategory as C
ON
	S.productcategorykey = C.productcategorykey;

-- 3. Esponi lʼelenco dei soli prodotti venduti (DimProduct, FactResellerSales).
SELECT
	*
FROM 
	dimproduct as P
INNER JOIN
	factresellersales as FS
ON
	P.productkey = FS.productkey;

-- 4.Esponi lʼelenco dei prodotti non venduti 
-- (considera i soli prodotti finiti cioè quelli per i quali il campo FinishedGoodsFlag è uguale a 1). 

SELECT
	*
FROM 
	dimproduct as P
LEFT JOIN
	factresellersales as FS
ON
	P.productkey = FS.productkey
WHERE
	FinishedGoodsFlag =1
AND
	FS.productkey IS NULL
;

-- 5. Esponi lʼelenco delle transazioni di vendita (FactResellerSales) 
-- indicando anche il nome del prodotto venduto (DimProduct) 
SELECT
	FS.productkey
    , orderdate
    , resellerkey
    , unitprice
    , orderquantity
    , P.englishproductname
FROM
	factresellersales as FS
INNER JOIN
	dimproduct as P
ON
	FS.productkey = P.productkey;

-- 6. Esponi lʼelenco delle transazioni di vendita 
-- indicando la categoria di appartenenza di ciascun prodotto venduto.
SELECT
	FS.productkey
    , orderdate
    , resellerkey
    , unitprice
    , orderquantity
    , P.englishproductname
    , SUBCAT.ProductSubcategoryKey
    , CAT.ProductCategoryKey
FROM
	factresellersales as FS
INNER JOIN
	dimproduct as P
ON
	FS.productkey = P.productkey
INNER JOIN
	dimproductsubcategory as SUBCAT
ON
	P.ProductSubcategoryKey = SUBCAT.ProductSubcategoryKey
INNER JOIN
	 dimproductcategory AS CAT
ON 
	SUBCAT.ProductCategoryKey = CAT.ProductCategoryKey;

-- 7. Esplora la tabella DimReseller.
SELECT
	*
FROM
	dimreseller;

-- 8. Esponi in output lʼelenco dei reseller indicando, per ciascun reseller, anche la sua area geografica. 

SELECT 
	ResellerKey
    ,RES.GeographyKey
    ,ResellerName
    ,Phone
FROM
	dimreseller as RES
LEFT JOIN
	dimgeography as GEO
ON
	RES.GeographyKey = GEO.GeographyKey;

-- 9. Esponi lʼelenco delle transazioni di vendita. 
-- Il result set deve esporre i campi: SalesOrderNumber, SalesOrderLineNumber, OrderDate, UnitPrice, Quantity, TotalProductCost. 
-- Il result set deve anche indicare il nome del prodotto, il nome della categoria del prodotto, il nome del reseller e lʼarea geografica.
SELECT
	SalesOrderNumber
    ,SalesOrderLineNumber
    ,OrderDate
    ,UnitPrice
    ,OrderQuantity
    ,TotalProductCost
	,PROD.productkey
    ,EnglishProductName
    ,CAT.EnglishProductCategoryName
    ,ResellerName
    ,GEO.GeographyKey
FROM
	factresellersales as SALES
LEFT JOIN
	dimproduct as PROD
ON
	SALES.productkey = PROD.productkey
INNER JOIN
	dimproductsubcategory as SUBCAT
ON
	PROD.ProductSubcategoryKey = SUBCAT.ProductSubcategoryKey
INNER JOIN
	dimproductcategory as CAT
ON
	SUBCAT.ProductCategoryKey = CAT.ProductCategoryKey
INNER JOIN
	dimreseller as RES
ON
	SALES.resellerkey = RES.resellerkey
INNER JOIN
	dimgeography as GEO
ON 
	RES.geographykey = GEO.geographykey;


