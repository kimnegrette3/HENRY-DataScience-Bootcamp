USE adventureworks;
/*1. Obtener un listado contactos que hayan ordenado productos de la subcategoría "Mountain Bikes", 
entre los años 2000 y 2003, cuyo método de envío sea "CARGO TRANSPORT 5".*/

-- salesorderheader CustomerID, 

/*SELECT p.ProductID, ps.Name, sd.SalesOrderID, s.ContactID, c.FirstName, c.LastName, sh.Name
FROM product p
JOIN productsubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN salesorderdetail sd on sd.ProductID = p.ProductID 
JOIN salesorderheader s on s.SalesOrderID = sd.SalesOrderID
JOIN contact c on s.ContactID = c.ContactID
JOIN shipmethod sh on sh.ShipMethodID = s.ShipMethodID
WHERE (ps.Name = 'Mountain Bikes') AND (sh.Name = 'CARGO TRANSPORT 5') AND (YEAR(s.OrderDate) BETWEEN '2000' AND '2003');*/


SELECT DISTINCT
    (s.ContactID), CONCAT(c.FirstName, ' ', c.LastName) AS 'nombre y apellido'
FROM
    product p
        JOIN
    productsubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN
    salesorderdetail sd ON sd.ProductID = p.ProductID
        JOIN
    salesorderheader s ON s.SalesOrderID = sd.SalesOrderID
        JOIN
    contact c ON s.ContactID = c.ContactID
        JOIN
    shipmethod sh ON sh.ShipMethodID = s.ShipMethodID
WHERE
    (ps.Name = 'Mountain Bikes')
        AND (sh.Name = 'CARGO TRANSPORT 5')
        AND (YEAR(s.OrderDate) BETWEEN '2000' AND '2003')
ORDER BY 2;

/*2. Obtener un listado contactos que hayan ordenado productos de la subcategoría "Mountain Bikes", 
entre los años 2000 y 2003 con la cantidad de productos adquiridos y ordenado por este valor, de forma descendente.*/

SELECT 
    s.ContactID,
    CONCAT(c.FirstName, ' ', c.LastName),
    SUM(sd.OrderQty) AS 'cantidad de productos'
FROM
    product p
        JOIN
    productsubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN
    salesorderdetail sd ON sd.ProductID = p.ProductID
        JOIN
    salesorderheader s ON s.SalesOrderID = sd.SalesOrderID
        JOIN
    contact c ON s.ContactID = c.ContactID
        JOIN
    shipmethod sh ON sh.ShipMethodID = s.ShipMethodID
WHERE
    (ps.Name = 'Mountain Bikes')
        AND (sh.Name = 'CARGO TRANSPORT 5')
        AND (YEAR(s.OrderDate) BETWEEN '2000' AND '2003')
GROUP BY 1
ORDER BY 3 DESC;

/*3. Obtener un listado de cual fue el volumen de compra (cantidad) por año y método de envío.*/
SELECT 
    YEAR(s.OrderDate) AS 'año',
    sh.Name AS 'método de envío',
    SUM(sd.OrderQty) AS 'volumen compra'
FROM
    salesorderheader s
        JOIN
    salesorderdetail sd ON s.SalesOrderID = sd.SalesOrderID
        JOIN
    shipmethod sh ON s.ShipMethodID = sh.ShipMethodID
GROUP BY 1 , 2;

/*4. Obtener un listado por categoría de productos, con el valor total de ventas y productos vendidos.*/
-- Para obtener product category hay que hacer join de product - productsubcategory - product category
-- Los datos de quantity y precio unitario están en salesorderdetail, o está la columna linetotal que ya tiene la multiplicación

-- No es claro si total ventas es multiplicación de precio por cantidad o solo conteo de órdenes
SELECT 
    pc.Name AS 'Categoría',
    SUM(sd.OrderQty) AS 'Cantidad',
    ROUND(SUM(sd.LineTotal), 2) AS 'Total'
FROM
    salesorderdetail sd
        JOIN
    product p ON sd.ProductID = p.ProductID
        JOIN
    productsubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN
    productcategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY 1;

/*5. Obtener un listado por país (según la dirección de envío), con el valor total de ventas y productos vendidos, 
sólo para aquellos países donde se enviaron más de 15 mil productos.*/

-- salesorderheader(ShiptoAddressID) - address(AddressID) (StateProvinceID) - stateprovince(StateProvinceID) (CountryRegionCode) - countryregion(CountryRegionCode) (Name)
-- salesorderheader(SalesOrderID) - salesorderdetal(SalesOrderID)

SELECT 
    cr.Name AS 'País',
    SUM(sd.OrderQty) AS 'Cantidad',
    ROUND(SUM(sd.LineTotal), 2) AS 'Total'
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
GROUP BY 1
HAVING SUM(sd.OrderQty) > 15000
ORDER BY cr.Name;

/*6. Obtener un listado de las cohortes que no tienen alumnos asignados, utilizando la base de datos henry, desarrollada en el módulo anterior.*/
USE HENRY;




