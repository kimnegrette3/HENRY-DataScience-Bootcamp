/*Homework
Crear una tabla que permita realizar el seguimiento de los usuarios que ingresan nuevos registros en fact_venta.
Crear una acción que permita la carga de datos en la tabla anterior.
Crear una tabla que permita registrar la cantidad total registros, luego de cada ingreso la tabla fact_venta.
Crear una acción que permita la carga de datos en la tabla anterior.
Crear una tabla que agrupe los datos de la tabla del item 3, a su vez crear un proceso de carga de los datos agrupados.
Crear una tabla que permita realizar el seguimiento de la actualización de registros de la tabla fact_venta.
Crear una acción que permita la carga de datos en la tabla anterior, para su actualización.*/

USE henry_m3;
-- tabla para el seguimiento de ingresos nuevos 
CREATE TABLE fact_ventas_auditoria (
auditoriaID INT,
ventaID INT,
fecha DATE,
fechaEntrega DATE,
canalID INT,
clienteID INT,
empleadoID INT,
productoID INT,
usuario VARCHAR(50),
fechaModificacion DATETIME
) ENGINE InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_spanish_ci;


ALTER TABLE fact_ventas_auditoria ADD PRIMARY KEY (auditoriaID);
ALTER TABLE fact_ventas_auditoria MODIFY COLUMN auditoriaID INT NOT NULL AUTO_INCREMENT;

-- creamos el trigger
DROP TRIGGER fact_ventas_auditoria;
CREATE TRIGGER fact_ventas_auditoria AFTER INSERT ON fact_ventas
FOR EACH ROW
INSERT INTO fact_ventas_auditoria (ventaID, fecha, fechaEntrega, canalID, clienteID, empleadoID, productoID, usuario, fechaModificacion)
VALUES (NEW.ventaID, NEW.fecha, NEW.fechaEntrega, NEW.canalID, NEW.clienteID, NEW.empleadoID, NEW.productoID, current_user(), NOW());


-- Tabla para llevar la cantidad de registros
DROP TABLE IF EXISTS fact_ventas_registros;
CREATE TABLE IF NOT EXISTS fact_ventas_registros (
Id INT NOT NULL AUTO_INCREMENT,
fecha DATE,
usuario VARCHAR(50),
conteo INT,
PRIMARY KEY (Id)
) ENGINE InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_spanish_ci;

DROP TRIGGER IF EXISTS fact_ventas_registros;
CREATE TRIGGER fact_ventas_registros AFTER INSERT ON fact_ventas
FOR EACH ROW
INSERT INTO fact_ventas_registros (fecha, usuario, conteo)
VALUES (NOW(), current_user(), (SELECT COUNT(*) FROM fact_ventas));


-- Tabla para registrar la actualización (updates) de la tabla fact_ventas
DROP TABLE IF EXISTS fact_venta_updates;
CREATE TABLE IF NOT EXISTS fact_venta_updates (
updateID INT NOT NULL AUTO_INCREMENT,
fechaModificacion DATETIME,
usuario VARCHAR(50),
ventaID INT,
fecha DATE,
fechaEntrega DATE,
canalID INT,
clienteID INT,
empleadoID INT,
productoID INT,
precio DECIMAL(15,2),
cantidad INT,
PRIMARY KEY (updateID)
) ENGINE InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_spanish_ci;

DROP TRIGGER IF EXISTS fact_venta_updates;
CREATE TRIGGER fact_venta_updates AFTER UPDATE ON fact_ventas 
FOR EACH ROW
INSERT INTO fact_venta_updates(fechaModificacion, usuario, ventaID, fecha, fechaEntrega, canalID, clienteID, empleadoID, productoID, precio, cantidad)
VALUES (NOW(), CURRENT_USER(), OLD.ventaID, OLD.fecha, OLD.fechaEntrega, OLD.canalID, OLD.clienteID, OLD.empleadoID, OLD.productoID, OLD.cantidad);


/*Carga Incremental
En este punto, ya contamos con toda la información de los datasets originales cargada en el DataWarehouse diseñado. 
Sin embargo, la gerencia, requiere la posibilidad de evaluar agregar a esa información la operatoria diara comenzando por la información de Ventas. 
Para lo cual, en la carpeta "Carga_Incremental" se disponibilizaron los archivos:

Ventas_Actualizado.csv: Tiene una estructura idéntica al original, pero con los registros del día 01/01/2021.
Clientes_Actializado.csv: Tiena una estructura idéntica al original, pero actualizado al día 01/01/2021.

Es necesario diseñar un proceso que permita ingestar al DataWarehouse las novedades diarias, tanto de la tabla de ventas como de la tabla de clientes. 
Se debe tener en cuenta, que dichas fuentes actualizadas, contienen la información original más las novedades, por lo tanto, 
en la tabla de "ventas" es necesario identificar qué registros son nuevos y cuales ya estaban cargados anteriormente, y en la tabla de clientes tambien, 
con el agregado de que en ésta última, pueden haber además registros modificados, con lo que hay que hacer uso de los campos de auditoría de esa tabla, 
por ejemplo, Fecha_Modificación.*/ 

/*El paso a paso sería a grandes rasgos así:
1- Crear tablas nuevas de novedades para almacenar temporalmente los nuevos csv
2- Realizar las normalizaciones que se hizo a las tablas originales, como corregir nulos, outliers, formato, eliminar o añadir columnas, etc.
	para que queden iguales a las tablas ya creadas en la BD
3- Identificar los datos que son updates (no ingresos) de información, usando Ids. Estos registros se actualizan en la tabla final con un SET
	y son borrados de la tabla novedades
4- Ingresar los datos restantes que serían los nuevos a las tablas finales. 
*/
