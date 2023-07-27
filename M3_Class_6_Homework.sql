use henry_m3;

/*Es necesario contar con una tabla de localidades del país con el fin de evaluar la apertura de una nueva sucursal y mejorar nuestros datos. 
A partir de los datos en las tablas cliente, sucursal y proveedor hay que generar una tabla definitiva de Localidades y Provincias. 
Utilizando la nueva tabla de Localidades controlar y corregir (Normalizar) los campos Localidad y Provincia de las tablas cliente, sucursal y proveedor.*/

-- hacer UNION de las tres tablas: clientes, sucursales y proveedores para tomar todas los posibles casos 
-- creo una tabla auxiliar
DROP TABLE IF EXISTS aux_Localidad;
CREATE TABLE IF NOT EXISTS aux_Localidad (
	Localidad_Original	VARCHAR(80),
	Provincia_Original	VARCHAR(50),
	Localidad_Normalizada	VARCHAR(80),
	Provincia_Normalizada	VARCHAR(50),
	localidadID			INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;	

-- Insertar el union de las tablas. Tener en cuenta que UNION solo toma distincts y UNION ALL no discrimina por duplicados
-- Para resolver el error de MIX COLLATION hay que cambiarle el encoding a las columnas a unir
/*ALTER TABLE proveedores MODIFY COLUMN provincia VARCHAR(255) COLLATE utf8mb4_spanish_ci;
ALTER TABLE proveedores MODIFY COLUMN ciudad VARCHAR(255) COLLATE utf8mb4_spanish_ci;
ALTER TABLE clientes MODIFY COLUMN provincia VARCHAR(255) COLLATE utf8mb4_spanish_ci;
ALTER TABLE clientes MODIFY COLUMN localidad VARCHAR(255) COLLATE utf8mb4_spanish_ci;
ALTER TABLE sucursales MODIFY COLUMN provincia VARCHAR(255) COLLATE utf8mb4_spanish_ci;
ALTER TABLE sucursales MODIFY COLUMN localidad VARCHAR(255) COLLATE utf8mb4_spanish_ci;*/
/*SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM clientes where Localidad = 'Avellaneda'
UNION
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM sucursales where Localidad = 'Avellaneda'
UNION
SELECT DISTINCT Ciudad, Provincia, Ciudad, Provincia, 0 FROM proveedores where Ciudad = 'Avellaneda'
ORDER BY 2, 1;

SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM clientes where Localidad = 'Avellaneda'
UNION ALL
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM sucursales where Localidad = 'Avellaneda'
UNION ALL
SELECT DISTINCT Ciudad, Provincia, Ciudad, Provincia, 0 FROM proveedores where Ciudad = 'Avellaneda'
ORDER BY 2, 1;*/

INSERT INTO aux_Localidad (Localidad_Original, Provincia_Original, Localidad_Normalizada, Provincia_Normalizada, localidadID)
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM clientes 
UNION
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM sucursales
UNION
SELECT DISTINCT Ciudad, Provincia, Ciudad, Provincia, 0 FROM proveedores
ORDER BY 2, 1;

SELECT DISTINCT Provincia_Original, Localidad_Original 
FROM aux_Localidad;

-- Normalizamos las localidades y provincias
UPDATE aux_localidad SET Provincia_Normalizada = 'Buenos Aires'  -- 3 rows affected
WHERE Provincia_Original IN ('B. Aires',
                            'B.Aires',
                            'Bs As',
                            'Bs.As.',
                            'Buenos Aires',
                            'C Debuenos Aires',
                            'Caba',
                            'Ciudad De Buenos Aires',
                            'Pcia Bs As',
                            'Prov De Bs As.',
                            'Provincia De Buenos Aires');

UPDATE aux_localidad SET Localidad_Normalizada = 'Capital Federal' -- 2 rows affected
WHERE Localidad_Original IN ('Boca De Atencion Monte Castro',
                            'Caba',
                            'Cap.   Federal',
                            'Cap. Fed.',
                            'Capfed',
                            'Capital',
                            'Capital Federal',
                            'Cdad De Buenos Aires',
                            'Ciudad De Buenos Aires')
AND Provincia_Normalizada = 'Buenos Aires';

UPDATE aux_localidad SET Localidad_Normalizada = 'Córdoba' -- 1 rows affected
WHERE Localidad_Original IN ('Coroba',
                            'Cordoba',
							'Cã³rdoba')
AND Provincia_Normalizada = 'Córdoba';

-- Creo otra tabla para pasar en limpio los distincts de las provincias y localidades normalizadas y asignales un ID
DROP TABLE IF EXISTS localidad;
CREATE TABLE IF NOT EXISTS localidad (
  localidadID int(11) NOT NULL AUTO_INCREMENT,
  localidad varchar(80) NOT NULL,
  provincia varchar(80) NOT NULL,
  provinciaID int(11) NOT NULL,
  PRIMARY KEY (localidadID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS provincia;
CREATE TABLE IF NOT EXISTS provincia (
  provinciaID int(11) NOT NULL AUTO_INCREMENT,
  provincia varchar(50) NOT NULL,
  PRIMARY KEY (provinciaID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- Insertamos la tabla nueva con los distincts. 
INSERT INTO localidad (localidad, provincia, provinciaID)  -- 587 rows affected
SELECT DISTINCT Localidad_Normalizada, Provincia_Normalizada, 0
FROM aux_Localidad
ORDER BY Provincia_Normalizada, Localidad_Normalizada;

INSERT INTO provincia (provincia) -- 9 rows affected
SELECT DISTINCT Provincia_Normalizada
FROM aux_Localidad
ORDER BY Provincia_Normalizada;

SELECT * FROM localidad;
SELECT * FROM provincia;

-- Relleno los id de provincia en la tabla localidad nueva
UPDATE localidad l 
JOIN provincia p ON l.provincia = p.provincia
SET l.provinciaID = p.provinciaID;

-- Relleno los id de localidad en la tabla aux_localidad
UPDATE aux_Localidad a
JOIN localidad l ON (a.Localidad_Normalizada = l.localidad AND a.Provincia_Normalizada = l.provincia)
SET a.localidadID = l.localidadID;
-- Acá en la tarea le agregan un AND con provinciaID pero no entiendo para qué -- jeje porque hay localidades que pueden estar en mas de una provincia

-- Agrego columnas nuevas a las tablas de clientes, proveedores y sucursales para el Id de localidad
ALTER TABLE clientes
ADD COLUMN localidadID INT NOT NULL DEFAULT 0 AFTER localidad;

ALTER TABLE proveedores
ADD COLUMN localidadID INT NOT NULL DEFAULT 0 AFTER departamento;

ALTER TABLE sucursales
ADD COLUMN localidadID INT NOT NULL DEFAULT 0 AFTER provincia;

-- Ahora llenarlas con el id correspondiente haciendo join con aux_localidad 
UPDATE clientes c
JOIN aux_localidad a ON (c.localidad = a.Localidad_Original AND c.provincia = a.Provincia_Original) -- 3407 rows affected
SET c.localidadID = a.localidadID;

UPDATE proveedores p
JOIN aux_localidad a ON (p.ciudad = a.Localidad_Original AND p.provincia = a.Provincia_Original) -- 14 rows affected
SET p.localidadID = a.localidadID;

UPDATE sucursales s
JOIN aux_localidad a ON (s.localidad = a.Localidad_Original AND s.provincia = a.Provincia_Original) -- 31 rows affected
SET s.localidadID = a.localidadID;

-- Finalmente, elimino las columnas que ya normalizamos
ALTER TABLE clientes
DROP localidad,
DROP provincia;

ALTER TABLE proveedores
DROP ciudad,
DROP provincia,
DROP pais,
DROP departamento;

ALTER TABLE sucursales
DROP localidad,
DROP provincia;


-- Es necesario discretizar el campo edad en la tabla cliente.
ALTER TABLE clientes ADD rangoEtario VARCHAR(75) NOT NULL DEFAULT '-' AFTER edad;

UPDATE clientes SET rangoEtario = 'Hasta 18' WHERE edad <= 18;
UPDATE clientes SET rangoEtario = '19 hasta 30' WHERE edad <= 30 and rangoEtario = '-';
UPDATE clientes SET rangoEtario = '31 hasta 40' WHERE edad <= 40 and rangoEtario = '-';
UPDATE clientes SET rangoEtario = '41 hasta 50' WHERE edad <= 50 and rangoEtario = '-';
UPDATE clientes SET rangoEtario = '51 hasta 60' WHERE edad <= 60 and rangoEtario = '-';
UPDATE clientes SET rangoEtario = 'Mayor de 60' WHERE edad > 60 and rangoEtario = '-';

SELECT rangoEtario, COUNT(*) as conteo
FROM clientes
GROUP BY rangoEtario
ORDER BY 2 DESC;

/*Aplicar alguna técnica de detección de Outliers en la tabla ventas, sobre los campos Precio y Cantidad. 
Realizar diversas consultas para verificar la importancia de haber detectado Outliers. 
Por ejemplo ventas por sucursal en un período teniendo en cuenta outliers y descartándolos.*/

-- Usaré la regla de las 3 sigmas pero deberíamos verificar la distribución de los datos y asegurarnos que sean normales.
-- De no ser normales, lo ideal sería usar el rango intercuartil IQR para calcular outliers
/*Deteccion y corrección de Outliers sobre ventas*/
/*Motivos:
2-Outlier de Cantidad
3-Outlier de Precio
*/
-- Detección de outliers
SELECT IdProducto, avg(Precio) as promedio, avg(Precio) + (3 * stddev(Precio)) as maximo
from venta
GROUP BY IdProducto;

SELECT IdProducto, avg(Precio) as promedio, avg(Precio) - (3 * stddev(Precio)) as minimo
from venta
GROUP BY IdProducto;

-- Detección de Outliers

SELECT v.*, o.promedio, o.maximo, o.minimo
from ventas v
JOIN (SELECT productoID, avg(precio) as promedio, avg(precio) + (3 * stddev(precio)) as maximo,
						avg(precio) - (3 * stddev(precio)) as minimo
	FROM ventas
	GROUP BY productoID) o
ON (v.productoID = o.productoID)
WHERE v.precio > o.maximo OR v.precio < minimo;


SELECT *
FROM ventas
WHERE productoID = 42890;

SELECT v.*, o.promedio, o.maximo, o.minimo
from ventas v
JOIN (SELECT productoID, avg(cantidad) as promedio, avg(cantidad) + (3 * stddev(cantidad)) as maximo,
						avg(cantidad) - (3 * stddev(cantidad)) as minimo
	FROM ventas
	GROUP BY productoID) o
ON (v.productoID = o.productoID)
WHERE v.cantidad > o.maximo OR v.cantidad < o.minimo;

-- Introducimos los outliers de cantidad en la tabla aux_venta - 794 rows affected
INSERT into aux_venta
SELECT v.ventaID, v.fecha, v.fechaEntrega, v.clienteID, v.sucursalID, v.empleadoID,
v.productoID, v.precio, v.cantidad, 2
FROM ventas v
JOIN (SELECT productoID, avg(cantidad) as promedio, stddev(cantidad) as desv
	FROM ventas
	GROUP BY productoID) v2
ON (v.productoID = v2.productoID)
WHERE v.cantidad > (v2.Promedio + (3*v2.Desv)) OR v.Cantidad < (v2.Promedio - (3*v2.Desv)) OR v.Cantidad < 0;

-- Introducimos los outliers de precio en la tabla aux_venta
INSERT into aux_venta
select v.ventaID, v.fecha, v.fechaEntrega, v.clienteID, v.sucursalID,
v.empleadoID, v.productoID, v.precio, v.cantidad, 3
from ventas v
JOIN (SELECT productoID, avg(Precio) as promedio, stddev(Precio) as Desv
	from ventas
	GROUP BY productoID) v2
ON (v.productoID = v2.productoID)
WHERE v.Precio > (v2.Promedio + (3*v2.Desv)) OR v.Precio < (v2.Promedio - (3*v2.Desv)) OR v.Precio < 0;

select * from aux_venta where Motivo = 2; -- outliers de cantidad
select * from aux_venta where Motivo = 3; -- outliers de precio

ALTER TABLE ventas ADD outlier TINYINT NOT NULL DEFAULT '1' AFTER cantidad;

UPDATE ventas v JOIN aux_venta a
	ON (v.ventaID = a.IdVenta AND a.Motivo IN (2,3))
SET v.Outlier = 0;

SELECT 	co.TipoProducto,
		co.PromedioVentaConOutliers,
        so.PromedioVentaSinOutliers
FROM
	(SELECT 	tp.TipoProducto,
			AVG(v.Precio * v.Cantidad) as PromedioVentaConOutliers
	FROM 	ventas v JOIN productos p
		ON (v.productoID = p.productoID)
			JOIN tipoproducto tp
		ON (p.tipoProductoID = tp.tipoProductoID)
	GROUP BY tp.tipoProducto) co
JOIN
	(SELECT 	tp.tipoProducto,
			AVG(v.Precio * v.Cantidad) as PromedioVentaSinOutliers
	FROM 	ventas v JOIN productos p
		ON (v.productoID = p.productoID and v.Outlier = 1)
			JOIN tipoproducto tp
		ON (p.tipoProductoID = tp.tipoProductoID)
	GROUP BY tp.tipoProducto) so
ON co.tipoProducto = so.TipoProducto;





-- KPIS

-- corrección de coordenadas


