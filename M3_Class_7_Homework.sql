/*A partir del conjunto de datos elaborado en clases anteriores, 
genere las PK de cada una de las tablas a partir del campo que cumpla con los requisitos correspondientes.*/

/*Genere la indexación de los campos que representen fechas o ID en las tablas:
venta.
canal_venta.
producto.
tipo_producto.
sucursal.
empleado.
localidad.
proveedor.
gasto.
cliente.
compra.
*/


/*ALTER TABLE aux_clientes ADD PRIMARY KEY(clienteID); -- no la he hecho porque es lo de las latitudes
ALTER TABLE aux_localidad ADD PRIMARY KEY(localidadID); -- borrar una de las 56 
ALTER TABLE aux_venta ADD PRIMARY KEY(IdVenta); -- hay muchisimos duplicados */
/*SELECT localidadID, COUNT(*) 
FROM aux_Localidad
GROUP BY localidadID
HAVING COUNT(*) > 1;

SELECT *
FROM aux_Localidad
WHERE localidadID = 56;

DELETE FROM aux_localidad WHERE Localidad_Original = 'Boca De Atencion Monte Castro' AND localidadID = 56;

SELECT IdVenta, COUNT(*) 
FROM aux_venta
GROUP BY IdVenta
HAVING COUNT(*) > 1;*/


ALTER TABLE clientes ADD PRIMARY KEY(clienteID); 
ALTER TABLE clientes ADD INDEX(localidadID);
ALTER TABLE clientes ADD INDEX(localidadID);
ALTER TABLE clientes ADD CONSTRAINT clientes_fk_localidad FOREIGN KEY (localidadID) REFERENCES localidad(localidadID) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE empleados ADD PRIMARY KEY(empleadoID);
ALTER TABLE empleados ADD INDEX(sucursalID);
ALTER TABLE empleados ADD INDEX(cargoID);
ALTER TABLE empleados ADD INDEX(sectorID);
ALTER TABLE empleados ADD CONSTRAINT empleado_fk_sucursal FOREIGN KEY (sucursalID) REFERENCES sucursales(sucursalID) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE empleados ADD CONSTRAINT empleado_fk_cargo FOREIGN KEY (cargoID) REFERENCES cargo(cargoID) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE empleados ADD CONSTRAINT empleado_fk_sector FOREIGN KEY (sectorID) REFERENCES sector(sectorID) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE gastos ADD PRIMARY KEY(gastoID);
ALTER TABLE gastos ADD INDEX(sucursalID);
ALTER TABLE gastos ADD INDEX(tipoGastoID);
ALTER TABLE gastos ADD INDEX(fecha);
ALTER TABLE gastos ADD CONSTRAINT gastos_fk_sucursal FOREIGN KEY (sucursalID) REFERENCES sucursales(sucursalID) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE gastos ADD CONSTRAINT gastos_fk_tipogasto FOREIGN KEY (tipoGastoID) REFERENCES tipogasto(tipoGastoID) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE localidad ADD PRIMARY KEY(localidadID);
ALTER TABLE localidad ADD INDEX(provinciaID);
ALTER TABLE localidad ADD CONSTRAINT localidad_fk_provincia FOREIGN KEY (provinciaID) REFERENCES provincia(provinciaID) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE productos ADD PRIMARY KEY(productoID);
ALTER TABLE productos ADD INDEX(tipoProductoID);
ALTER TABLE productos ADD CONSTRAINT producto_fk_tipoproducto FOREIGN KEY (tipoProductoID) REFERENCES tipoproducto(tipoProductoID) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE proveedores ADD PRIMARY KEY(proveedorID);
ALTER TABLE proveedores ADD INDEX(localidadID);
ALTER TABLE proveedores ADD CONSTRAINT proveedores_fk_localidad FOREIGN KEY (localidadID) REFERENCES localidad(localidadID) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE provincia ADD PRIMARY KEY(provinciaID);

ALTER TABLE sector ADD PRIMARY KEY(sectorID);

ALTER TABLE sucursales ADD PRIMARY KEY(sucursalID);
ALTER TABLE sucursales ADD INDEX(localidadID);
ALTER TABLE sucursales ADD CONSTRAINT sucursales_fk_localidad FOREIGN KEY (localidadID) REFERENCES localidad(localidadID) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE tipoProducto ADD PRIMARY KEY(productoid);

ALTER TABLE tipogasto ADD PRIMARY KEY(tipoGastoID);

ALTER TABLE ventas ADD PRIMARY KEY(ventaID);
ALTER TABLE ventas ADD INDEX(fecha);
ALTER TABLE ventas ADD INDEX(fechaEntrega);
ALTER TABLE ventas ADD INDEX(canalID);
ALTER TABLE ventas ADD INDEX(clienteID);
ALTER TABLE ventas ADD INDEX(sucursalID);
ALTER TABLE ventas ADD INDEX(empleadoID);
ALTER TABLE ventas ADD INDEX(productoID);
ALTER TABLE ventas ADD CONSTRAINT ventas_fk_canal FOREIGN KEY (canalID) REFERENCES canalventas(canalID) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE ventas ADD CONSTRAINT ventas_fk_cliente FOREIGN KEY (clienteID) REFERENCES clientes(clienteID) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE ventas ADD CONSTRAINT ventas_fk_sucursal FOREIGN KEY (sucursalID) REFERENCES sucursales(sucursalID) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE ventas ADD CONSTRAINT ventas_fk_empleado FOREIGN KEY (empleadoID) REFERENCES empleados(empleadoID) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE ventas ADD CONSTRAINT ventas_fk_producto FOREIGN KEY (productoID) REFERENCES productos(productoID) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE canalventas ADD PRIMARY KEY(canalID); 

ALTER TABLE compras ADD INDEX(fecha);
ALTER TABLE compras ADD INDEX(productoID);
ALTER TABLE compras ADD INDEX(proveedorID);
ALTER TABLE compras ADD CONSTRAINT compras_fk_producto FOREIGN KEY (productoID) REFERENCES productos(productoID) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE compras ADD CONSTRAINT compras_fk_proveedor FOREIGN KEY (proveedorID) REFERENCES proveedores(proveedorID) ON DELETE RESTRICT ON UPDATE RESTRICT;

/*Genere una nueva tabla que lleve el nombre fact_venta (modelo estrella) que pueda agrupar los hechos relevantes de la tabla venta, los campos a considerar deben ser los siguientes:
IdVenta
Fecha
Fecha_Entrega
IdCanal
IdCliente
IdEmpleado
IdProducto
Precio
Cantidad*/

CREATE TABLE fact_ventas (
ventaID INT NOT NULL DEFAULT 0,
fecha DATE,
fechaEntrega DATE,
canalID INT NOT NULL DEFAULT 0,
clienteID INT NOT NULL DEFAULT 0,
empleadoID INT NOT NULL DEFAULT 0,
productoID INT NOT NULL DEFAULT 0,
precio DECIMAL(15,3),
cantidad INTEGER
) ENGINE InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_spanish_ci;

-- 9061 rows affected
INSERT INTO fact_ventas
SELECT ventaID, fecha, fechaEntrega, canalID, clienteID, empleadoID, productoID, precio, cantidad
FROM ventas
WHERE YEAR(Fecha) = 2020 AND outlier = 1;


ALTER TABLE fact_venta ADD PRIMARY KEY(ventaID);
ALTER TABLE fact_venta ADD INDEX(productoID);
ALTER TABLE fact_venta ADD INDEX(empleadoID);
ALTER TABLE fact_venta ADD INDEX(fecha);
ALTER TABLE fact_venta ADD INDEX(fechaEntregaID);
ALTER TABLE fact_venta ADD INDEX(clienteID);
ALTER TABLE fact_venta ADD INDEX(canalID);