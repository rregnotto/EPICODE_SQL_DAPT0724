-- W7D4 Esercizi
USE 
	AdventureWorksDW;
-- Es 1 Implementa una vista denominata Product al fine di creare unʼanagrafica (dimensione) prodotto completa. 
-- La vista, se interrogata o utilizzata come sorgente dati, 
-- deve esporre il nome prodotto, il nome della sottocategoria associata e il nome della categoria associata.

CREATE VIEW Product
AS (
	SELECT
		p.ProductKey AS IDProdotto,
        p.EnglishProductName AS NomeProdotto,
        sub.EnglishProductSubcategoryName AS NomeSubCat,
        c.EnglishProductCategoryName AS NomeCat
    FROM
		dimproduct AS p
	INNER JOIN
		dimproductsubcategory AS sub
	ON
		p.ProductSubcategoryKey=sub.ProductSubcategoryKey
	INNER JOIN
		dimproductcategory AS c
	ON
		sub.ProductCategoryKey=c.ProductCategoryKey
	);

-- Es 2 Implementa una vista denominata Reseller al fine di creare unʼanagrafica (dimensione) reseller completa.
--  La vista, se interrogata o utilizzata come sorgente dati, deve esporre il nome del reseller, il nome della città 
-- e il nome della regione.

CREATE VIEW Reseller
AS (
	SELECT
		res.ResellerName AS ResellerName,
        res.ResellerKey AS IDReseller,
        geo.City,
        geo.EnglishCountryRegionName
    FROM
		dimreseller AS res
	INNER JOIN
		dimgeography AS geo
	ON
		res.GeographyKey=geo.GeographyKey
);

-- Es 3 Crea una vista denominata Sales che deve restituire la data dellʼordine, 
-- il codice documento, la riga di corpo del documento, la quantità venduta, lʼimporto totale e il profitto (=markup)

CREATE VIEW Sales
AS (
	SELECT
		f.SalesOrderNumber, -- codice documento
        f.SalesOrderLineNumber, -- riga di corpo del documento
		f.OrderDate,
        f.ProductKey,
        f.OrderQuantity,
        f.UnitPrice,
        f.TotalProductCost,
        f.SalesAmount,
        case when TotalProductCost is null then f.SalesAmount - f.OrderQuantity *p.StandardCost
        else SalesAmount - TotalProductCost end as Markup_corretto
	FROM
		factresellersales AS f
	INNER JOIN
		dimproduct AS p
	ON 
		f.ProductKey=p.ProductKey
);

-- Es 4 Crea un report in Excel che consenta ad un utente di analizzare quantità venduta, importo totale e profitti per prodotto/categoria prodotto e reseller/regione. 

CREATE VIEW Analisi
AS (
	SELECT
		OrderQuantity AS QuantVenduta,
        SalesAmount AS ImportoTot,
        TotalProductCost,
        StandardCost,
        case when TotalProductCost is null then f.SalesAmount - f.OrderQuantity *p.StandardCost
        else SalesAmount - TotalProductCost end as Markup_corretto,
        g.EnglishCountryRegionName,
        f.ResellerKey
	FROM
		factresellersales AS f
	INNER JOIN
		dimproduct AS p
	ON
		f.ProductKey=p.ProductKey
	INNER JOIN
     dimproductsubcategory AS sub
	ON
		p.ProductSubcategoryKey=sub.ProductSubcategoryKey
	INNER JOIN
		dimproductcategory AS c
	ON
		sub.ProductCategoryKey=c.ProductCategoryKey
	INNER JOIN
		dimgeography AS g
	ON
		f.SalesTerritoryKey=g.SalesTerritoryKey
);
	
	
	
