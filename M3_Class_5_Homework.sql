
 USE henry_m3;
 
-- fechas maximas para ver si esta actualizado
SELECT max(fecha) FROM ventas;
SELECT max(fecha) FROM compras;
SELECT max(fecha) FROM gastos;
SELECT max(fechaUltMod) FROM clientes;

-- Ver si existen id duplicados
SELECT id, COUNT(id) AS count
FROM tu_tabla
GROUP BY id
HAVING count > 1;

-- Crear tabla calendario
DROP TABLE IF EXISTS `calendario`;
CREATE TABLE calendario (
        id                      INTEGER PRIMARY KEY,  -- year*10000+month*100+day
        fecha                 	DATE NOT NULL,
        anio                    INTEGER NOT NULL,
        mes                   	INTEGER NOT NULL, -- 1 to 12
        dia                     INTEGER NOT NULL, -- 1 to 31
        trimestre               INTEGER NOT NULL, -- 1 to 4
        semana                  INTEGER NOT NULL, -- 1 to 52/53
        dia_nombre              VARCHAR(9) NOT NULL, -- 'Monday', 'Tuesday'...
        mes_nombre              VARCHAR(9) NOT NULL -- 'January', 'February'...
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- Se crea el procedure para poblar la tabla calendario
DROP PROCEDURE IF EXISTS `Llenar_dimension_calendario`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Llenar_dimension_calendario`(IN `startdate` DATE, IN `stopdate` DATE)
BEGIN
    DECLARE currentdate DATE;
    SET currentdate = startdate;
    WHILE currentdate < stopdate DO
        INSERT INTO calendario VALUES (
                        YEAR(currentdate)*10000+MONTH(currentdate)*100 + DAY(currentdate),
                        currentdate,
                        YEAR(currentdate),
                        MONTH(currentdate),
                        DAY(currentdate),
                        QUARTER(currentdate),
                        WEEKOFYEAR(currentdate),
                        DATE_FORMAT(currentdate,'%W'),
                        DATE_FORMAT(currentdate,'%M'));
        SET currentdate = ADDDATE(currentdate,INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

-- Se llama al procedure para poblar la tabla calendario
ALTER TABLE `calendario` ADD UNIQUE(`fecha`);
CALL Llenar_dimension_calendario('2015-01-01', '2020-12-31');

-- Eliminar columnas no relevantes
ALTER TABLE clientes -- Esta columna está totalmente vacía
DROP COLUMN col10;

-- Normalizar los nombres de los campos y colocar el tipo de dato adecuado para cada uno en cada una de las tablas. 
ALTER TABLE `tipogasto` CHANGE `descripcion` `tipoGasto` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL;
ALTER TABLE tipogasto CHANGE montoAprox monto DECIMAL(13,2) NOT NULL;

ALTER TABLE `productos` CHANGE `concepto` `producto` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NULL DEFAULT NULL;
ALTER TABLE productos RENAME COLUMN tipo TO tipoProducto;
ALTER TABLE productos CHANGE precio precio DECIMAL(13,2) NOT NULL;

ALTER TABLE proveedores RENAME COLUMN direccion TO domicilio;
ALTER TABLE proveedores RENAME COLUMN estado TO provincia;

ALTER TABLE sucursales RENAME COLUMN direccion TO domicilio;
ALTER TABLE sucursales RENAME COLUMN nombre TO sucursal;

-- La tabla clientes tiene longitud y latitud con una coma en vez de punto y valores nulos. 
-- También están en data type varchar y hay que pasarla a decimal

ALTER TABLE clientes 	ADD latitud DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER Y,  
						ADD longitud DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER latitud;
                        
UPDATE clientes SET Y = '0' WHERE Y = '';
UPDATE clientes SET X = '0' WHERE X = '';
UPDATE clientes SET latitud = REPLACE(Y,',','.');
UPDATE clientes SET longitud = REPLACE(X,',','.');

ALTER TABLE clientes DROP X;
ALTER TABLE clientes DROP Y;	

-- La tabla sucursales tiene longitud y latitud con coma y data type LONG, hay que cambiarla a decimal
UPDATE sucursales SET latitud = REPLACE(latitud, ',','.');
UPDATE sucursales SET longitud = REPLACE(longitud, ',', '.');

ALTER TABLE sucursales
MODIFY COLUMN latitud DECIMAL(13,10),
MODIFY COLUMN longitud DECIMAL(13,10); -- Esto añadió ceros al final de las coordenadas para completar los 10 dígitos. no creo que esté bien eso 


-- Corregir inconsistencias en tablas sucursal, proveedor, empleado y cliente -- NO ERA PARA ESTA HOMEWORK JAJA 
Select * from sucursales
where (provincia like '%Bue%') or (provincia like 'Bs%') or (provincia like 'CA%') or (provincia like 'C de%') or (provincia like 'B%') or (provincia like 'Pcia%');

UPDATE sucursales
SET provincia = 'Buenos Aires'
WHERE (provincia like '%Bue%') or (provincia like 'Bs%') or (provincia like 'CA%') or (provincia like 'C de%') or (provincia like 'B%') or (provincia like 'Pcia%');

Select * from sucursales
WHERE (Localidad like 'CAB%') or (Localidad like 'Ciu%') or (Localidad like 'CAp%') or (Localidad like '%buen%');

UPDATE sucursales
SET localidad = 'Buenos Aires' 
WHERE (Localidad like 'CAB%') or (Localidad like 'Ciu%') or (Localidad like 'CAp%') or (Localidad like '%buen%');

UPDATE sucursales
SET localidad = 'Córdoba'
WHERE localidad LIKE 'Cor%ba';

UPDATE sucursales
SET provincia = 'Córdoba'
WHERE provincia LIKE 'Cor%ba';

-- Imputar Valores Faltantes a las columnas cualitativas
UPDATE `clientes` SET domicilio = 'Sin Dato' WHERE TRIM(domicilio) = "" OR ISNULL(domicilio);
UPDATE `clientes` SET localidad = 'Sin Dato' WHERE TRIM(localidad) = "" OR ISNULL(localidad);
UPDATE `clientes` SET nombreApellido = 'Sin Dato' WHERE TRIM(nombreApellido) = "" OR ISNULL(nombreApellido);
UPDATE `clientes` SET provincia = 'Sin Dato' WHERE TRIM(provincia) = "" OR ISNULL(provincia);

UPDATE `empleados` SET apellido = 'Sin Dato' WHERE TRIM(apellido) = "" OR ISNULL(apellido);
UPDATE `empleados` SET nombre = 'Sin Dato' WHERE TRIM(nombre) = "" OR ISNULL(nombre);
UPDATE `empleados` SET sucursal = 'Sin Dato' WHERE TRIM(sucursal) = "" OR ISNULL(sucursal);
UPDATE `empleados` SET sector = 'Sin Dato' WHERE TRIM(sector) = "" OR ISNULL(sector);
UPDATE `empleados` SET cargo = 'Sin Dato' WHERE TRIM(cargo) = "" OR ISNULL(cargo);

UPDATE `productos` SET producto = 'Sin Dato' WHERE TRIM(producto) = "" OR ISNULL(producto);
UPDATE `productos` SET tipo = 'Sin Dato' WHERE TRIM(tipo) = "" OR ISNULL(tipo);

UPDATE `proveedores` SET nombre = 'Sin Dato' WHERE TRIM(nombre) = "" OR ISNULL(nombre);
UPDATE `proveedores` SET direccion = 'Sin Dato' WHERE TRIM(domicilio) = "" OR ISNULL(domicilio);
UPDATE `proveedores` SET ciudad = 'Sin Dato' WHERE TRIM(ciudad) = "" OR ISNULL(ciudad);
UPDATE `proveedores` SET provincia = 'Sin Dato' WHERE TRIM(provincia) = "" OR ISNULL(provincia);
UPDATE `proveedores` SET pais = 'Sin Dato' WHERE TRIM(pais) = "" OR ISNULL(pais);
UPDATE `proveedores` SET departamento = 'Sin Dato' WHERE TRIM(departamento) = "" OR ISNULL(departamento);

UPDATE `sucursales` SET domicilio = 'Sin Dato' WHERE TRIM(domicilio) = "" OR ISNULL(domicilio);
UPDATE `sucursales` SET sucursal = 'Sin Dato' WHERE TRIM(sucursal) = "" OR ISNULL(sucursal);
UPDATE `sucursales` SET provincia = 'Sin Dato' WHERE TRIM(provincia) = "" OR ISNULL(provincia);
UPDATE `sucursales` SET localidad = 'Sin Dato' WHERE TRIM(localidad) = "" OR ISNULL(localidad);

/*ALTER TABLE clientes CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci; -- Intenté de todas estas formas cambiar el encoding para la ñ y no resultó
SHOW VARIABLES LIKE 'character_set_connection'; -- utf8mb4
SHOW CREATE DATABASE henry_m3;
SHOW CREATE TABLE clientes;
ALTER DATABASE henry_m3 COLLATE utf8mb4_spanish_ci;*/


-- Normalizacion a Letra Capital
-- Función y Procedimientos provistos
DROP FUNCTION IF EXISTS `UC_Words`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `UC_Words`( str VARCHAR(255) ) RETURNS varchar(255) CHARSET utf8
BEGIN  
  DECLARE c CHAR(1);  
  DECLARE s VARCHAR(255);  
  DECLARE i INT DEFAULT 1;  
  DECLARE bool INT DEFAULT 1;  
  DECLARE punct CHAR(17) DEFAULT ' ()[]{},.-_!@;:?/';  
  SET s = LCASE( str );  
  WHILE i < LENGTH( str ) DO  
     BEGIN  
       SET c = SUBSTRING( s, i, 1 );  
       IF LOCATE( c, punct ) > 0 THEN  
        SET bool = 1;  
      ELSEIF bool=1 THEN  
        BEGIN  
          IF c >= 'a' AND c <= 'z' THEN  
             BEGIN  
               SET s = CONCAT(LEFT(s,i-1),UCASE(c),SUBSTRING(s,i+1));  
               SET bool = 0;  
             END;  
           ELSEIF c >= '0' AND c <= '9' THEN  
            SET bool = 0;  
          END IF;  
        END;  
      END IF;  
      SET i = i+1;  
    END;  
  END WHILE;  
  RETURN s;  
END$$
DELIMITER ;


UPDATE clientes SET  domicilio = UC_Words(TRIM(domicilio)),
					localidad = UC_Words(TRIM(localidad)),
                    nombreApellido = UC_Words(TRIM(nombreApellido));
					
UPDATE sucursales SET domicilio = UC_Words(TRIM(domicilio)),
                    sucursal = UC_Words(TRIM(sucursal));
					
UPDATE proveedores SET nombre = UC_Words(TRIM(nombre)),
                    domicilio = UC_Words(TRIM(domicilio)),
                    ciudad = UC_Words(TRIM(ciudad)),
                    provincia = UC_Words(TRIM(provincia)),
                    pais = UC_Words(TRIM(pais)),
                    departamento = UC_Words(TRIM(departamento));

UPDATE productos SET producto = UC_Words(TRIM(producto));

UPDATE productos SET tipoProducto = UC_Words(TRIM(tipoProducto));
					
UPDATE empleados SET nombre = UC_Words(TRIM(nombre)),
                    apellido = UC_Words(TRIM(apellido));
                    

-- Chequear la consistencia de los campos precio y cantidad de la tabla de ventas.
/*
select * from venta where Precio = '' or Cantidad = ''; -- Esto devuelve 1800 records
select count(*) from venta;
*/
-- trato de rescatar de la tabla producto los precios para los registros en blanco de la tabla ventas
UPDATE ventas v JOIN productos p ON (v.productoID = p.productoID) -- 924 rows affected
SET v.precio = p.precio
WHERE v.precio = 0;

-- Tabla auxiliar donde se guardarán registros con problemas:
-- Se asignará 1 a los registros con Cantidad en Cero

DROP TABLE IF EXISTS `aux_venta`;
CREATE TABLE IF NOT EXISTS `aux_venta` (
  `IdVenta`				INTEGER,
  `Fecha` 				DATE NOT NULL,
  `Fecha_Entrega` 		DATE NOT NULL,
  `IdCliente`			INTEGER, 
  `IdSucursal`			INTEGER,
  `IdEmpleado`			INTEGER,
  `IdProducto`			INTEGER,
  `Precio`				FLOAT,
  `Cantidad`			INTEGER,
  `Motivo`				INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- Por si existen carriage return characters,
SELECT *
FROM ventas
WHERE cantidad = '\r'; -- OR cantidad IS NULL;
UPDATE ventas SET cantidad = REPLACE(cantidad, '\r', '');

-- Se rellena la tabla auxiliar con los datos faltantes de cantidad
INSERT INTO aux_venta (IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Motivo)
SELECT ventaID, fecha, fechaEntrega, clienteID, sucursalID, empleadoID, productoID, precio, 0, 1
FROM ventas WHERE cantidad = '' or cantidad is null;

-- Se asigna 1 a las cantidades nulas en la tabla ventas, pues es la mínima cantidad requerida para registrar una venta
UPDATE ventas SET cantidad = '1' WHERE cantidad = '' or cantidad is null;
ALTER TABLE ventas CHANGE cantidad cantidad INTEGER NOT NULL DEFAULT '0';

-- Hay que hacer algo con los precios desorbitantes que hay por error


-- hay claves duplicadas?
SELECT clienteID, COUNT(*) FROM clientes GROUP BY clienteID HAVING COUNT(*) > 1;
SELECT sucursalID, COUNT(*) FROM sucursales GROUP BY sucursalID HAVING COUNT(*) > 1;
SELECT empleadoID, COUNT(*) FROM empleados GROUP BY empleadoID HAVING COUNT(*) > 1; -- Hay muchas claves duplicadas!
SELECT proveedorID, COUNT(*) FROM proveedores GROUP BY proveedorID HAVING COUNT(*) > 1;
SELECT productoID, COUNT(*) FROM productos GROUP BY productoID HAVING COUNT(*) > 1;

-- Generar una nueva clave id única para empleados, se puede usar el id de la sucursal como combinación
SELECT e.*, s.sucursalID
FROM empleados e JOIN sucursales s
	ON e.sucursal = s.sucursal;

-- Verificar que no haya nombres de sucursales en la tabla empleado que no existan en la tabla sucursales
-- Aparece que Mendoza 1 y Mendoza 2 no existen, porque tienen un espacio en blanco que no está en la tabla sucursales
SELECT DISTINCT sucursal 
FROM empleados
WHERE sucursal NOT IN (SELECT sucursal FROM sucursales); 

-- Corregir estos nombres de sucursales para que coincidan
UPDATE empleados
SET sucursal = 'Mendoza1' 
WHERE sucursal = 'Mendoza 1';

UPDATE empleados
SET sucursal = 'Mendoza2' 
WHERE sucursal = 'Mendoza 2';


-- Ahora si agrego una columna nueva a empleados con el Id de las sucursales
ALTER TABLE empleados 
ADD COLUMN sucursalID INT NULL DEFAULT 0 AFTER sucursal;

-- Inserto los id con un join desde sucursales
UPDATE empleados e JOIN sucursales s
	ON e.sucursal = s.sucursal
SET e.sucursalID = s.sucursalID;

-- Elimino la columna antigua de sucursales 
ALTER TABLE empleados
DROP COLUMN sucursal;

-- Creo una nueva columna auxiliar donde guardaré el id antiguo
ALTER TABLE empleados
ADD COLUMN codigoEmpleado INT NULL DEFAULT 0 AFTER empleadoID;

UPDATE empleados
SET codigoEmpleado = empleadoID;

-- Ahora creo un id nuevo multiplicando el id de la sucursal por 10000 sumado al id de empleado
UPDATE empleados
SET empleadoID = (sucursalID*10000) + codigoEmpleado;

-- Chequeo que no hayan quedado claves duplicadas
-- No resultan duplicados
SELECT empleadoID, COUNT(*) 
FROM empleadoS
GROUP BY empleadoID
HAVING COUNT(*) > 1;


-- Ahora debemos modificar la clave foránea de empleadoID en la tabla de ventas. Lo haré con la misma fórmula
UPDATE ventas
SET empleadoID = (sucursalID*10000) + empleadoID;


-- Generar dos nuevas tablas a partir de la tabla 'empleado' que contengan las entidades Cargo y Sector.

DROP TABLE IF EXISTS cargo;
CREATE TABLE IF NOT EXISTS cargo (
cargoID INT NOT NULL AUTO_INCREMENT,
cargo VARCHAR(75) NOT NULL,
PRIMARY KEY (cargoID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;


DROP TABLE IF EXISTS sector;
CREATE TABLE IF NOT EXISTS sector (
sectorID INT NOT NULL AUTO_INCREMENT,
sector VARCHAR(75) NOT NULL,
PRIMARY KEY (sectorID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- Poblar la tabla con los cargos de empleados
-- Acá apareció el cargo 'Vendedor' dos veces, lo que puede significar que tiene blank spaces
-- No voy a hacer drop ni normalizar empleados para corregirlo después
INSERT INTO cargo (cargo)
SELECT DISTINCT cargo FROM empleados ORDER BY cargo;

INSERT INTO sector (sector)
SELECT DISTINCT sector FROM empleados ORDER BY sector;

ALTER TABLE empleados
ADD COLUMN cargoID INT NOT NULL DEFAULT 0 AFTER sucursalID,
ADD COLUMN sectorID INT NOT NULL DEFAULT 0 AFTER cargoID;

UPDATE empleados e
JOIN cargo c ON e.cargo = c.cargo
SET e.cargoID = c.cargoID;

UPDATE empleados e
JOIN sector s ON e.sector = s.sector
SET e.sectorID = s.sectorID;

ALTER TABLE empleados
MODIFY COLUMN cargo VARCHAR(75)COLLATE utf8mb4_spanish_ci,
MODIFY COLUMN sector VARCHAR(75)COLLATE utf8mb4_spanish_ci;

ALTER TABLE empleados
DROP sector,
DROP cargo;

SELECT * FROM cargo;

DELETE FROM cargo WHERE cargoID=6;

UPDATE empleados
SET cargoID = 5
WHERE cargoID=6;


-- Generar una nueva tabla a partir de la tabla 'producto' que contenga la entidad Tipo de Producto.

DROP TABLE IF EXISTS tipoproducto;
CREATE TABLE IF NOT EXISTS tipoproducto (
tipoProductoID INT NOT NULL AUTO_INCREMENT,
tipoProducto VARCHAR(75) NOT NULL,
PRIMARY KEY (tipoProductoID)
) ENGINE InnoDB DEFAULT CHARSET utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO tipoProducto (tipoProducto)
SELECT DISTINCT tipoProducto FROM productos ORDER BY tipoProducto;

ALTER TABLE productos
ADD COLUMN tipoProductoID INT NOT NULL DEFAULT 0 AFTER tipoProducto;

UPDATE productos p
JOIN tipoproducto t ON p.tipoProducto = t.tipoProducto
SET p.tipoProductoID = t.tipoProductoID; -- Sale un error de mix of collations. 

/*ALTER TABLE productos
MODIFY COLUMN tipoProducto VARCHAR(75)COLLATE utf8mb4_spanish_ci;*/

ALTER TABLE productos
DROP COLUMN tipoProducto;








