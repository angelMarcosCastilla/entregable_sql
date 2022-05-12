-- AUTOR :	MARCOS CASTILLA ANGEL JOEL -- III SEMESTRE - INGENIERIA DE SOFTWARE

USE master
GO

DROP DATABASE dbboleta

CREATE DATABASE dbboleta
GO

USE dbboleta
GO

-- TABLA IMPUESTOS

CREATE TABLE impuestos(
	id_impuesto			INT IDENTITY(1,1) PRIMARY KEY NOT NULL ,
	nombre				VARCHAR(100) NOT NULL,
	siglas				VARCHAR(10) NOT NULL,
	porcentaje			DECIMAL(4,2) NOT NULL,
	fecha_registro		DATE DEFAULT GETDATE(),

	CONSTRAINT uk_nombre_imp UNIQUE(nombre) ,
	CONSTRAINT uk_siglas_imp UNIQUE(siglas),
	CONSTRAINT ck_porcentaje_imp CHECK (porcentaje > 0)
)
GO

INSERT INTO impuestos(nombre, siglas, porcentaje) VALUES ('Impuesto General a la Ventas','IGV', 18.00)
GO

SELECT *  FROM impuestos
GO


-- Tabla cliente
CREATE TABLE clientes (
	id_cliente			INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombres				VARCHAR(50) NOT NULL,
	apellidos			VARCHAR(50) NOT NULL,
	direccion			VARCHAR(100) NOT NULL,
	ruc					VARCHAR(11) NOT NULL,
	telefono			CHAR(9) NOT NULL,
	fecha_registro		DATE DEFAULT GETDATE(),

	CONSTRAINT uk_ruc_clt UNIQUE(ruc),
	CONSTRAINT ck_telefono_clt CHECK (telefono LIKE ('[9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')),
	CONSTRAINT ck_ruc_clt CHECK (ruc LIKE ('[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
)
GO

INSERT INTO clientes(nombres, apellidos, direccion, ruc, telefono,fecha_registro) VALUES 
	('Mauro', 'Rojas', 'Lima', '92345008910', '928963095', '2022-05-10'),
	('Linda', 'Magdalena ', 'Jupiter', '01345008910', '928963990', '2022-05-06')
GO
INSERT INTO clientes(nombres, apellidos, direccion, ruc, telefono) VALUES 
	('Angel Joel', 'Marcos Castilla', 'Calle san juan 7ma cuadra', '92345678910', '924463095'),
	('Maria ', ' Castilla Quispe', 'Calle san Luis', '02345670910', '962463098')
GO

SELECT * FROM clientes
GO

--tabla producto
CREATE TABLE productos(
	id_producto			INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	id_impuesto			INT NOT NULL,
	precio				DECIMAL(7,2) NOT NULL,
	nombres				VARCHAR(50) NOT NULL,
	stock				INT NOT NULL,
	descripcion			VARCHAR(150) NULL,
	fecha_registro		DATE DEFAULT GETDATE(),

	CONSTRAINT ck_precio_prd CHECK (precio > 0),
	CONSTRAINT fk_id_impuesto_prd FOREIGN KEY (id_impuesto) REFERENCES impuestos(id_impuesto)
)
GO

INSERT INTO productos(id_impuesto, precio, stock,nombres, descripcion) VALUES 
	(1, 50.00, 1000, 'chompas', 'Chompas de dralon'),
	(1, 10.00, 900, 'camisas', 'camisas de dralon'),
	(1, 90.00, 900, 'pantalon', 'pantalon diseño raro'),
	(1, 45.00, 900, 'chompas', 'chompas de orlon')
GO

SELECT * FROM productos

-- tabla factura

CREATE TABLE facturas(
	id_factura			INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	id_cliente			INT NOT NULL,
	Fecha_emision		DATE DEFAULT GETDATE(),
	esta_cancelado		BIT DEFAULT 0,
	dias_vencimiento	TINYINT NOT NULL,

	CONSTRAINT fk_id_fac FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
	CONSTRAINT ck_dias_vencimiento_fac CHECK (dias_vencimiento > 0)
)
GO

INSERT INTO facturas (id_cliente, Fecha_emision, esta_cancelado,dias_vencimiento) VALUES
	(1,'2022-04-26', 0,7),
	(1,'2022-02-23',1,5),
	(2,'2022-04-06',1,3),
	(3,'2022-04-11',1,5),
	(2,'2022-04-10',1,5),
	(4,'2022-04-01',1,2),
	(1,'2022-03-24',0,6),
	(2,'2022-04-15',0,8),
	(3,'2022-05-10',1,6),
	(4,'2022-03-06',1,6)
GO

INSERT INTO facturas (id_cliente,dias_vencimiento) VALUES
	(3,6),
	(2,4)	
GO

SELECT * FROM facturas

-- tabla detalles facturas

CREATE TABLE detalles_facturas(
	id_detalle_factura			INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	id_producto					INT NOT NULL,
	id_factura					INT NOT NULL,
	cantidad					INT NOT NULL,

	CONSTRAINT fk_id_producto_dtf FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
	CONSTRAINT fk_id_factura_dtf  FOREIGN KEY (id_factura) REFERENCES facturas(id_factura)
)

INSERT INTO detalles_facturas (id_factura, id_producto, cantidad) VALUES
	(1, 1, 10) ,
	(1, 2, 2),
	(2, 1, 3) ,
	(2, 3, 5) ,
	(3, 1, 2),
	(1, 1, 6) ,
	(4, 3, 7) ,
	(4, 1, 10),
	(5, 1, 5) ,
	(5, 3, 5) ,
	(5, 2, 2),
	(6, 3, 10) ,
	(7, 1, 10) ,
	(8, 2, 1),
	(8, 1, 4) ,
	(9, 3, 10) ,
	(10, 2, 1),
	(10, 1, 4),
	(11, 2, 13),
	(12, 1, 12)
GO

SELECT * from detalles_facturas


-- algunos ejemplos de ejecicios

--  1)se desea saber los productos que se han adquirido en la factura 1, 
-- el precio normal del producto, el precio del producto con impuesto id=1 que es IGV, nombre del cliente,
--	nombre y descripcion de productos, cantidad, y total por productos
	
SELECT	clientes.nombres AS 'Cliente',
		productos.precio  AS 'Precio Normal',
		productos.precio,
		((productos.precio * impuestos.porcentaje)/100) + productos.precio AS precio_total,
		detalles_facturas.cantidad,
		(((productos.precio * impuestos.porcentaje)/100) + productos.precio )  * detalles_facturas.cantidad AS 'total',
		productos.nombres,
		productos.descripcion
		FROM detalles_facturas 
		JOIN  facturas ON detalles_facturas.id_factura = facturas.id_factura
			JOIN clientes ON facturas.id_cliente = clientes.id_cliente
		JOIN  productos ON detalles_facturas.id_producto =productos.id_producto
			JOIN impuestos ON productos.id_impuesto = impuestos.id_impuesto
		WHERE detalles_facturas.id_factura = 1
GO

/*
	2) mostrar el monto total, por cada factura y el nombre del cliente con su ruc , de forma decreciente por el total
*/

SELECT	facturas.id_factura,
		sum((((productos.precio * impuestos.porcentaje)/100) + productos.precio )  * detalles_facturas.cantidad) AS 'total de la factura',
		clientes.nombres,
		clientes.ruc
		FROM detalles_facturas 
		JOIN  facturas ON detalles_facturas.id_factura = facturas.id_factura
			JOIN clientes ON facturas.id_cliente = clientes.id_cliente
		JOIN  productos ON detalles_facturas.id_producto =productos.id_producto
			JOIN impuestos ON productos.id_impuesto = impuestos.id_impuesto
		GROUP BY clientes.nombres,clientes.ruc, facturas.id_factura 
		ORDER BY 'total de la factura' DESC
GO


/* 3)mostrar la factura que esten pagadas , mostrar tambien el nombre y apellido del cliente*/

SELECT	facturas.id_factura,
		sum((((productos.precio * impuestos.porcentaje)/100) + productos.precio )  * detalles_facturas.cantidad) AS 'total de la factura',
		clientes.nombres,
		clientes.apellidos,
		facturas.esta_cancelado
		FROM detalles_facturas 
		JOIN  facturas ON detalles_facturas.id_factura = facturas.id_factura
			JOIN clientes ON facturas.id_cliente = clientes.id_cliente
		JOIN  productos ON detalles_facturas.id_producto =productos.id_producto
			JOIN impuestos ON productos.id_impuesto = impuestos.id_impuesto
		GROUP BY clientes.nombres,clientes.apellidos,facturas.esta_cancelado, facturas.id_factura 
		HAVING facturas.esta_cancelado = 1
		
GO

/*
	mostrar toda las facturas que esten vencidas
*/

SELECT	facturas.id_factura,
		sum((((productos.precio * impuestos.porcentaje)/100) + productos.precio )  * detalles_facturas.cantidad) AS 'total de la factura',
		clientes.nombres,
		clientes.apellidos,
		facturas.Fecha_emision,
		facturas.dias_vencimiento AS 'Dias de plazo',
		DATEADD(DAY, facturas.dias_vencimiento,facturas.Fecha_emision ) AS 'fecha de vencimiento'
		FROM detalles_facturas 
		JOIN  facturas ON detalles_facturas.id_factura = facturas.id_factura
			JOIN clientes ON facturas.id_cliente = clientes.id_cliente
		JOIN  productos ON detalles_facturas.id_producto =productos.id_producto
			JOIN impuestos ON productos.id_impuesto = impuestos.id_impuesto
		GROUP BY clientes.nombres,clientes.apellidos,facturas.dias_vencimiento, facturas.Fecha_emision, facturas.id_factura 
		HAVING  GETDATE()  > DATEADD(DAY, facturas.dias_vencimiento,facturas.Fecha_emision ) 	
GO
