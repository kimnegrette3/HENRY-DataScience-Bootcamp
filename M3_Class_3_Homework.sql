SET sql_mode='';

-- CREAR VISTA
CREATE VIEW cantidadVentasAnio as
SELECT YEAR(h.OrderDate) as Anio, SUM(d.OrderQty) as CantidadTotalAnio FROM salesorderheader h
        JOIN salesorderdetail d ON (h.SalesOrderID = d.SalesOrderID)
        GROUP BY YEAR(h.OrderDate);


SELECT * FROM cantidadenvio;

SELECT 
    YEAR(h.OrderDate) AS Anio,
    e.Name AS MetodoEnvio,
    SUM(d.OrderQty) AS Cantidad,
    SUM(d.OrderQty) / t.CantidadTotalAnio * 100 AS Porcentaje
FROM
    salesorderheader h
        JOIN
    shipmethod AS e ON h.ShipMethodID = e.ShipMethodID
        JOIN
    salesorderdetail d ON h.SalesOrderID = d.SalesOrderID
        JOIN
    cantidadVentasAnio AS t ON YEAR(h.OrderDate) = t.anio
GROUP BY 1 , 2;

-- Ahora usando un subquery
SELECT 
    YEAR(h.OrderDate) AS Anio,
    e.Name AS MetodoEnvio,
    SUM(d.OrderQty) AS Cantidad,
    ROUND((SUM(d.OrderQty) / t.CantidadTotalAnio) * 100, 2) AS Porcentaje
FROM
    salesorderheader h
        JOIN
    shipmethod AS e ON h.ShipMethodID = e.ShipMethodID
        JOIN
    salesorderdetail d ON h.SalesOrderID = d.SalesOrderID
        JOIN
    (SELECT 
        YEAR(h.OrderDate) AS Anio,
            SUM(d.OrderQty) AS CantidadTotalAnio
    FROM
        salesorderheader h
    JOIN salesorderdetail d ON (h.SalesOrderID = d.SalesOrderID)
    GROUP BY YEAR(h.OrderDate)) AS t ON YEAR(h.OrderDate) = t.anio
GROUP BY MetodoEnvio , t.anio
ORDER BY YEAR(h.OrderDate);

-- Ahora usando window functions

SELECT t.Año, t.MetodoEnvio, t.Cantidad,
	(t.Cantidad/SUM(t.Cantidad) OVER (PARTITION BY t.Año) *100) as Porcentaje
FROM
	(SELECT YEAR(h.OrderDate) as Año, e.Name as MetodoEnvio, SUM(d.OrderQty) as Cantidad
	FROM salesorderheader h
	JOIN 
    salesorderdetail d ON h.SalesOrderID = d.SalesOrderID
    JOIN
    shipmethod AS e ON h.ShipMethodID = e.ShipMethodID
    GROUP BY YEAR(h.OrderDate)) t;

/*2. Obtener un listado por categoría de productos, con el valor total de ventas y productos vendidos, 
mostrando para ambos, su porcentaje respecto del total.*/

SELECT Categoria, Cantidad, Total,
	(Cantidad/SUM(Cantidad) OVER())*100 as PorcentajeCantidad,
    (Total/SUM(Total) OVER())*100 as PorcentajeTotal
FROM
	(SELECT c.Name as Categoria, SUM(d.OrderQty) as Cantidad, SUM(d.LineTotal) as Total
FROM salesorderdetail d
JOIN product p ON d.ProductID = p.ProductID
JOIN productsubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN productcategory c ON ps.ProductCategoryID = c.ProductCategoryID
GROUP BY c.Name
ORDER BY c.Name) v;


/*3. Obtener un listado por país (según la dirección de envío), con el valor total de ventas y productos vendidos,
 mostrando para ambos, su porcentaje respecto del total.*/
 
 SELECT Pais, Cantidad, Total,
	ROUND(Cantidad/SUM(Cantidad) OVER()*100,2) as PorcentajeCantidad,
    ROUND(Total/SUM(Total) OVER()*100,2) AS PorcentajeTotal
FROM
	(SELECT cr.Name as Pais, SUM(sd.OrderQty) as Cantidad, ROUND(SUM(sd.LineTotal),2) as Total
	FROM
    salesorderdetail sd
        JOIN
    salesorderheader s ON sd.SalesOrderID = s.SalesOrderID
        JOIN
    address a ON s.ShipToAddressID = a.AddressID
        JOIN
    stateprovince sp ON a.StateProvinceID = sp.StateProvinceID
        JOIN
    countryregion cr ON sp.CountryRegionCode = cr.CountryRegionCode
	GROUP BY cr.Name
    ORDER BY cr.Name) q;
    
    
/*4. Obtener por ProductID, los valores correspondientes a la mediana de las ventas (LineTotal), 
sobre las ordenes realizadas. Investigar las funciones FLOOR() y CEILING().*/

-- no idea
 
 
 

