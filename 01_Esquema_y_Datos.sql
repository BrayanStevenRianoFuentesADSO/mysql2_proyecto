drop database if exists Ecommerce;

create DATABASE Ecommerce;

use Ecommerce;

CREATE table clientes(
id_cliente int AUTO_INCREMENT PRIMARY KEY,
nombres varchar(100) not null,
apellidos varchar(100) not null,
fecha_nacimiento date not null,
ciudad varchar(100) not null,
region varchar(100) not null,
email varchar(100) not null UNIQUE,
contrasenia varchar(100) not null,
direccion_envio varchar(100),
fecha_registro datetime DEFAULT CURRENT_TIMESTAMP,
total_gastado decimal(10,2) default 0,
nivel_lealtad ENUM('Bronce', 'Plata', 'Oro', 'Platino') DEFAULT 'Bronce',
activo BOOLEAN DEFAULT TRUE,
ultima_actividad DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE table categorias(
id_categoria int primary key,
nombre varchar(50) not null unique,
descripcion varchar(255)
);

CREATE table proveedores(
id_proveedor int primary key,
nombre varchar(100) not null,
email_contacto varchar(100) unique,
telefono_contacto varchar(15)
);

CREATE table productos(
id_producto int AUTO_INCREMENT PRIMARY KEY,
nombre varchar(50) not null UNIQUE,
descripcion text,
precio decimal(10,2) not null check(precio > 0),
costo decimal(10,2) not null check(costo>=0),
stock int DEFAULT 0 CHECK(stock>=0),
sku varchar(50) not null unique,
fecha_creacion datetime default current_timestamp,
fecha_modificacion datetime default current_timestamp,
activo boolean default True,
id_categoria int not null,
id_proveedor int not null,
stock_minimo int check (stock_minimo>0),
ubicacion varchar(50),
peso decimal(10,2) check (peso > 0),
foreign key (id_proveedor) references proveedores(id_proveedor),
foreign key (id_categoria) references categorias(id_categoria)
);

CREATE table ventas(
id_venta int primary key auto_increment,
fecha_venta datetime default current_timestamp,
estado enum('Pendiente de Pago', 'Procesando', 'Enviado', 'Entregado', 'Cancelado'),
total decimal(10,2),
id_cliente int,
foreign key (id_cliente) references clientes(id_cliente)
);

CREATE table detalle_ventas(
id_detalle int primary key auto_increment,
cantidad int check(cantidad>0),
precio_unitario_congelado decimal(10,2) check(precio_unitario_congelado >0),
id_producto int,
id_venta int,
foreign key (id_producto) references productos(id_producto),
foreign key (id_venta) references ventas(id_venta)
);

CREATE TABLE carritos(
id_carrito INT AUTO_INCREMENT PRIMARY KEY,
id_cliente INT NOT NULL,
fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
estado ENUM('Activo', 'Comprado', 'Abandonado') DEFAULT 'Activo',
FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE detalle_carrito(
id_detalle_carrito INT AUTO_INCREMENT PRIMARY KEY,
id_carrito INT NOT NULL,
id_producto INT NOT NULL,
cantidad INT NOT NULL CHECK(cantidad > 0),
FOREIGN KEY (id_carrito) REFERENCES carritos(id_carrito),
FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE promociones(
id_promocion INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
id_producto INT NOT NULL,
fecha_inicio DATETIME NOT NULL,
fecha_fin DATETIME NOT NULL,
descuento DECIMAL(5,2) NOT NULL CHECK(descuento > 0),
activo BOOLEAN DEFAULT TRUE,
FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE vistas_productos(
id_vista INT AUTO_INCREMENT PRIMARY KEY,
id_producto INT NOT NULL,
id_cliente INT,
fecha_vista DATETIME NOT NULL,
FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE auditoria_precios(
id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
id_producto INT,
precio_anterior DECIMAL(10,2),
precio_nuevo DECIMAL(10,2),
fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 5

CREATE TABLE auditoria_clientes(
id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
id_cliente INT,
nombres VARCHAR(100),
apellidos VARCHAR(100),
email VARCHAR(100),
fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reporte_ventas_semanal(
id_reporte INT AUTO_INCREMENT PRIMARY KEY,
fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP,
fecha_inicio DATE NOT NULL,
fecha_fin DATE NOT NULL,
cantidad_ventas INT DEFAULT 0,
total_vendido DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE productos_reabastecimiento(
id_reabastecimiento INT AUTO_INCREMENT PRIMARY KEY,
id_producto INT NOT NULL,
stock_actual INT NOT NULL,
stock_minimo INT NOT NULL,
fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE resumen_ventas_diarias(
id_resumen INT AUTO_INCREMENT PRIMARY KEY,
fecha DATE NOT NULL UNIQUE,
cantidad_ventas INT DEFAULT 0,
total_vendido DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE inconsistencias_datos(
id_inconsistencia INT AUTO_INCREMENT PRIMARY KEY,
tipo VARCHAR(100) NOT NULL,
descripcion VARCHAR(255),
fecha_detectada DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 
CREATE TABLE auditoria_precios_historica(
id_auditoria INT,
id_producto INT,
precio_anterior DECIMAL(10,2),
precio_nuevo DECIMAL(10,2),
fecha_modificacion DATETIME,
fecha_archivo DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE datos_temporales(
id INT AUTO_INCREMENT PRIMARY KEY,
informacion VARCHAR(255),
fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- "tablas por eventos"

CREATE TABLE auditoria_stock(
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    stock_anterior INT NOT NULL,
    stock_nuevo INT NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    fecha_ajuste DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);


CREATE TABLE notificaciones(
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    mensaje VARCHAR(255) NOT NULL,
    fecha_notificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
);

CREATE TABLE devoluciones (
    id_devolucion INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK(cantidad > 0),
    monto_credito DECIMAL(10,2) NOT NULL,
    fecha_devolucion DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_venta)
        REFERENCES ventas(id_venta),

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);

INSERT INTO categorias(id_categoria,nombre,descripcion) VALUES
(1,'Computadores','Computadores de escritorio y portatiles'),
(2,'Celulares','Telefonos inteligentes'),
(3,'Monitores','Monitores para trabajo y gaming'),
(4,'Teclados','Teclados mecanicos y de membrana'),
(5,'Mouse','Mouse para oficina y gaming'),
(6,'Audifonos','Audifonos alambricos e inalambricos'),
(7,'Impresoras','Impresoras para hogar y oficina'),
(8,'Camaras','Camaras digitales y webcams'),
(9,'Almacenamiento','Discos duros y unidades SSD'),
(10,'Memorias RAM','Memorias para computadores'),
(11,'Tarjetas graficas','Tarjetas de video'),
(12,'Procesadores','Procesadores para computadores'),
(13,'Motherboards','Placas madre'),
(14,'Fuentes','Fuentes de poder'),
(15,'Gabinetes','Gabinetes para computadores'),
(16,'Parlantes','Parlantes y altavoces'),
(17,'Tablets','Tablets y dispositivos tactiles'),
(18,'Accesorios','Accesorios tecnologicos'),
(19,'Cables','Cables y adaptadores'),
(20,'Routers','Routers y dispositivos de red');

INSERT INTO proveedores(id_proveedor,nombre,email_contacto,telefono_contacto) VALUES
(1,'Tech Colombia','ventas@techcolombia.com','3001111111'),
(2,'Digital Store','contacto@digitalstore.com','3002222222'),
(3,'CompuMarket','ventas@compumarket.com','3003333333'),
(4,'Electronica SAS','contacto@electronica.com','3004444444'),
(5,'MegaTech','ventas@megatech.com','3005555555'),
(6,'TecnoWorld','info@teknoworld.com','3006666666'),
(7,'Importaciones JD','ventas@importacionesjd.com','3007777777'),
(8,'Smart Solutions','contacto@smartsolutions.com','3008888888'),
(9,'Global Technology','ventas@globaltech.com','3009999999'),
(10,'PC Express','contacto@pcexpress.com','3011111111'),
(11,'Data Center','ventas@datacenter.com','3012222222'),
(12,'HardTech','info@hardtech.com','3013333333'),
(13,'Pro Gaming','ventas@progaming.com','3014444444'),
(14,'Office Tech','contacto@officetech.com','3015555555'),
(15,'Net Colombia','ventas@netcolombia.com','3016666666'),
(16,'TecnoPlus','info@tecnoplus.com','3017777777'),
(17,'CompuZone','ventas@compuzone.com','3018888888'),
(18,'Digital Pro','contacto@digitalpro.com','3019999999'),
(19,'InnovaTech','ventas@innovatech.com','3021111111'),
(20,'Master Electronics','info@masterelectronics.com','3022222222');

INSERT INTO clientes(nombres,apellidos,fecha_nacimiento,ciudad,region,email,contrasenia,direccion_envio,nivel_lealtad,activo) VALUES
('Juan','Perez','1998-03-15','Bucaramanga','Santander','juan.perez@email.com','123456','Calle 10 #20-30','Oro',TRUE),
('Maria','Gomez','1995-07-21','Bogota','Cundinamarca','maria.gomez@email.com','123456','Carrera 15 #45-20','Plata',TRUE),
('Carlos','Rodriguez','2000-01-10','Medellin','Antioquia','carlos.rodriguez@email.com','123456','Calle 50 #30-15','Bronce',TRUE),
('Laura','Martinez','1997-11-25','Cali','Valle del Cauca','laura.martinez@email.com','123456','Carrera 5 #20-10','Oro',TRUE),
('Andres','Lopez','1994-06-18','Barranquilla','Atlantico','andres.lopez@email.com','123456','Calle 80 #40-25','Platino',TRUE),
('Sofia','Hernandez','2001-09-12','Cartagena','Bolivar','sofia.hernandez@email.com','123456','Carrera 2 #10-15','Plata',TRUE),
('Daniel','Torres','1999-04-30','Pereira','Risaralda','daniel.torres@email.com','123456','Calle 25 #15-40','Bronce',TRUE),
('Valentina','Ramirez','1996-12-05','Manizales','Caldas','valentina.ramirez@email.com','123456','Carrera 10 #30-20','Oro',TRUE),
('Sebastian','Castro','1993-08-17','Cucuta','Norte de Santander','sebastian.castro@email.com','123456','Calle 12 #8-50','Plata',TRUE),
('Camila','Moreno','2002-02-28','Bucaramanga','Santander','camila.moreno@email.com','123456','Carrera 27 #35-60','Bronce',TRUE),
('Mateo','Vargas','1998-10-14','Bogota','Cundinamarca','mateo.vargas@email.com','123456','Calle 90 #15-25','Oro',TRUE),
('Isabella','Rojas','1995-05-19','Medellin','Antioquia','isabella.rojas@email.com','123456','Carrera 43 #20-30','Plata',TRUE),
('Nicolas','Jimenez','2000-07-07','Cali','Valle del Cauca','nicolas.jimenez@email.com','123456','Calle 8 #12-45','Bronce',TRUE),
('Gabriela','Diaz','1997-03-22','Barranquilla','Atlantico','gabriela.diaz@email.com','123456','Carrera 50 #70-15','Oro',TRUE),
('Samuel','Ruiz','1992-11-11','Cartagena','Bolivar','samuel.ruiz@email.com','123456','Calle 30 #5-20','Platino',TRUE),
('Natalia','Mendoza','1999-01-26','Pereira','Risaralda','natalia.mendoza@email.com','123456','Carrera 7 #18-35','Plata',TRUE),
('Alejandro','Silva','1996-09-09','Manizales','Caldas','alejandro.silva@email.com','123456','Calle 22 #10-40','Bronce',TRUE),
('Paula','Cortes','2001-06-03','Cucuta','Norte de Santander','paula.cortes@email.com','123456','Carrera 6 #14-20','Oro',TRUE),
('David','Navarro','1994-12-16','Bucaramanga','Santander','david.navarro@email.com','123456','Calle 45 #20-10','Plata',TRUE),
('Juliana','Molina','1998-04-24','Bogota','Cundinamarca','juliana.molina@email.com','123456','Carrera 11 #80-30','Bronce',TRUE);

INSERT INTO productos(nombre,descripcion,precio,costo,stock,sku,id_categoria,id_proveedor,stock_minimo,ubicacion,peso) VALUES
('Laptop Lenovo','Laptop para trabajo y estudio',2500000,1800000,30,'SKU-LAP-001',1,1,5,'A1',2.10),
('iPhone 15','Telefono inteligente Apple',4200000,3300000,20,'SKU-CEL-002',2,2,5,'A2',0.50),
('Monitor Samsung 24','Monitor Full HD de 24 pulgadas',850000,600000,25,'SKU-MON-003',3,3,5,'A3',3.20),
('Teclado Mecanico','Teclado mecanico RGB',280000,180000,40,'SKU-TEC-004',4,4,8,'A4',0.90),
('Mouse Logitech','Mouse inalambrico Logitech',120000,70000,50,'SKU-MOU-005',5,5,10,'A5',0.30),
('Audifonos Sony','Audifonos inalambricos',450000,300000,35,'SKU-AUD-006',6,6,7,'A6',0.40),
('Impresora HP','Impresora multifuncional',700000,500000,15,'SKU-IMP-007',7,7,3,'B1',5.50),
('Webcam Logitech','Webcam Full HD',320000,220000,25,'SKU-CAM-008',8,8,5,'B2',0.35),
('SSD Kingston 1TB','Unidad SSD de 1TB',390000,280000,30,'SKU-SSD-009',9,9,6,'B3',0.10),
('RAM Corsair 16GB','Memoria RAM DDR4 16GB',240000,160000,45,'SKU-RAM-010',10,10,10,'B4',0.08),
('RTX 4060','Tarjeta grafica Nvidia RTX 4060',1800000,1400000,12,'SKU-GPU-011',11,11,3,'B5',1.20),
('Ryzen 7','Procesador AMD Ryzen 7',1350000,1000000,18,'SKU-CPU-012',12,12,4,'B6',0.45),
('B550M','Motherboard AMD B550M',650000,450000,20,'SKU-MOB-013',13,13,4,'C1',0.70),
('Fuente 650W','Fuente de poder 650W',350000,230000,25,'SKU-FUE-014',14,14,5,'C2',1.50),
('Gabinete Gamer','Gabinete ATX RGB',420000,280000,20,'SKU-GAB-015',15,15,4,'C3',6.00),
('Parlante JBL','Parlante bluetooth JBL',380000,250000,22,'SKU-PAR-016',16,16,5,'C4',1.00),
('Tablet Samsung','Tablet Samsung 10 pulgadas',1100000,800000,16,'SKU-TAB-017',17,17,4,'C5',0.60),
('Hub USB','Hub USB de 4 puertos',90000,50000,60,'SKU-HUB-018',18,18,12,'C6',0.20),
('Cable HDMI','Cable HDMI 2 metros',45000,20000,80,'SKU-CAB-019',19,19,15,'C7',0.15),
('Router TP-Link','Router WiFi doble banda',220000,140000,35,'SKU-ROU-020',20,20,7,'C8',0.50);

INSERT INTO ventas(fecha_venta,estado,total,id_cliente) VALUES
('2026-09-01 09:15:00','Entregado',2500000,1),
('2026-09-01 10:20:00','Entregado',4200000,2),
('2026-09-02 11:30:00','Enviado',850000,3),
('2026-09-02 14:10:00','Procesando',280000,4),
('2026-09-03 09:45:00','Entregado',120000,5),
('2026-09-03 16:20:00','Entregado',450000,6),
('2026-09-04 10:00:00','Enviado',700000,7),
('2026-09-04 13:30:00','Pendiente de Pago',320000,8),
('2026-09-05 08:50:00','Entregado',390000,9),
('2026-09-05 15:40:00','Entregado',240000,10),
('2026-09-06 09:10:00','Cancelado',1800000,11),
('2026-09-06 12:25:00','Entregado',1350000,12),
('2026-09-07 11:00:00','Enviado',650000,13),
('2026-09-08 14:45:00','Procesando',350000,14),
('2026-09-09 10:30:00','Entregado',420000,15),
('2026-09-10 16:00:00','Entregado',380000,16),
('2026-09-11 09:25:00','Enviado',1100000,17),
('2026-09-12 13:15:00','Entregado',90000,18),
('2026-09-13 11:40:00','Pendiente de Pago',45000,19),
('2026-09-14 17:20:00','Procesando',220000,20);

INSERT INTO detalle_ventas(cantidad,precio_unitario_congelado,id_producto,id_venta) VALUES
(1,2500000,1,1),
(1,4200000,2,2),
(1,850000,3,3),
(1,280000,4,4),
(1,120000,5,5),
(1,450000,6,6),
(1,700000,7,7),
(1,320000,8,8),
(1,390000,9,9),
(1,240000,10,10),
(1,1800000,11,11),
(1,1350000,12,12),
(1,650000,13,13),
(1,350000,14,14),
(1,420000,15,15),
(1,380000,16,16),
(1,1100000,17,17),
(1,90000,18,18),
(1,45000,19,19),
(1,220000,20,20);

INSERT INTO carritos(id_cliente,estado) VALUES
(1,'Comprado'),
(2,'Comprado'),
(3,'Comprado'),
(4,'Comprado'),
(5,'Comprado'),
(6,'Comprado'),
(7,'Comprado'),
(8,'Activo'),
(9,'Comprado'),
(10,'Comprado'),
(11,'Abandonado'),
(12,'Comprado'),
(13,'Comprado'),
(14,'Activo'),
(15,'Comprado'),
(16,'Comprado'),
(17,'Comprado'),
(18,'Comprado'),
(19,'Activo'),
(20,'Comprado');

INSERT INTO detalle_carrito(id_carrito,id_producto,cantidad) VALUES
(1,1,1),
(2,2,1),
(3,3,1),
(4,4,1),
(5,5,1),
(6,6,1),
(7,7,1),
(8,8,2),
(9,9,1),
(10,10,1),
(11,11,1),
(12,12,1),
(13,13,1),
(14,14,2),
(15,15,1),
(16,16,1),
(17,17,1),
(18,18,1),
(19,19,3),
(20,20,1);

INSERT INTO promociones(nombre,id_producto,fecha_inicio,fecha_fin,descuento,activo) VALUES
('Oferta Laptop',1,'2026-09-01 00:00:00','2026-09-30 23:59:59',10,TRUE),
('Oferta iPhone',2,'2026-09-01 00:00:00','2026-09-20 23:59:59',5,TRUE),
('Monitor Septiembre',3,'2026-09-05 00:00:00','2026-09-30 23:59:59',15,TRUE),
('Teclado Gamer',4,'2026-09-01 00:00:00','2026-09-15 23:59:59',20,FALSE),
('Mouse Oferta',5,'2026-09-01 00:00:00','2026-09-30 23:59:59',10,TRUE),
('Audifonos Sony',6,'2026-09-01 00:00:00','2026-09-25 23:59:59',12,TRUE),
('Impresora HP',7,'2026-09-10 00:00:00','2026-09-30 23:59:59',8,TRUE),
('Webcam',8,'2026-09-01 00:00:00','2026-09-30 23:59:59',10,TRUE),
('SSD Oferta',9,'2026-09-01 00:00:00','2026-09-30 23:59:59',15,TRUE),
('RAM Oferta',10,'2026-09-01 00:00:00','2026-09-20 23:59:59',10,TRUE),
('RTX Oferta',11,'2026-09-01 00:00:00','2026-09-30 23:59:59',5,TRUE),
('Ryzen Oferta',12,'2026-09-05 00:00:00','2026-09-25 23:59:59',7,TRUE),
('Motherboard',13,'2026-09-01 00:00:00','2026-09-30 23:59:59',10,TRUE),
('Fuente 650W',14,'2026-09-01 00:00:00','2026-09-15 23:59:59',12,FALSE),
('Gabinete Gamer',15,'2026-09-01 00:00:00','2026-09-30 23:59:59',15,TRUE),
('Parlante JBL',16,'2026-09-01 00:00:00','2026-09-30 23:59:59',10,TRUE),
('Tablet Samsung',17,'2026-09-01 00:00:00','2026-09-30 23:59:59',8,TRUE),
('Hub USB',18,'2026-09-01 00:00:00','2026-09-30 23:59:59',20,TRUE),
('Cable HDMI',19,'2026-09-01 00:00:00','2026-09-30 23:59:59',25,TRUE),
('Router Oferta',20,'2026-09-01 00:00:00','2026-09-30 23:59:59',10,TRUE);

INSERT INTO vistas_productos(id_producto,id_cliente,fecha_vista) VALUES
(1,1,'2026-09-01 08:30:00'),
(2,2,'2026-09-01 09:00:00'),
(3,3,'2026-09-02 10:00:00'),
(4,4,'2026-09-02 12:00:00'),
(5,5,'2026-09-03 08:30:00'),
(6,6,'2026-09-03 14:00:00'),
(7,7,'2026-09-04 09:20:00'),
(8,8,'2026-09-04 12:30:00'),
(9,9,'2026-09-05 08:00:00'),
(10,10,'2026-09-05 13:00:00'),
(11,11,'2026-09-06 08:30:00'),
(12,12,'2026-09-06 11:00:00'),
(13,13,'2026-09-07 10:30:00'),
(14,14,'2026-09-08 13:00:00'),
(15,15,'2026-09-09 09:30:00'),
(16,16,'2026-09-10 15:00:00'),
(17,17,'2026-09-11 08:45:00'),
(18,18,'2026-09-12 12:00:00'),
(19,19,'2026-09-13 10:30:00'),
(20,20,'2026-09-14 16:30:00');




INSERT INTO reporte_ventas_semanal(fecha_inicio,fecha_fin,cantidad_ventas,total_vendido) VALUES
('2026-08-24','2026-08-30',18,12500000),
('2026-08-31','2026-09-06',11,11640000),
('2026-09-07','2026-09-13',12,5345000),
('2026-09-14','2026-09-20',1,220000),
('2026-08-17','2026-08-23',15,9800000);

INSERT INTO productos_reabastecimiento(id_producto,stock_actual,stock_minimo) VALUES
(11,12,3),
(12,18,4),
(13,20,4),
(14,25,5),
(15,20,4);

INSERT INTO resumen_ventas_diarias(fecha,cantidad_ventas,total_vendido) VALUES
('2026-09-01',2,6700000),
('2026-09-02',2,1130000),
('2026-09-03',2,570000),
('2026-09-04',2,1020000),
('2026-09-05',2,630000),
('2026-09-06',2,3150000),
('2026-09-07',1,650000),
('2026-09-08',1,350000),
('2026-09-09',1,420000),
('2026-09-10',1,380000),
('2026-09-11',1,1100000),
('2026-09-12',1,90000),
('2026-09-13',1,45000),
('2026-09-14',1,220000),
('2026-08-31',3,780000),
('2026-08-30',4,920000),
('2026-08-29',5,1250000),
('2026-08-28',2,560000),
('2026-08-27',6,1800000),
('2026-08-26',3,750000);

INSERT INTO inconsistencias_datos(tipo,descripcion) VALUES
('Stock','Producto con stock cercano al minimo'),
('Email','Cliente con correo pendiente de verificacion'),
('Precio','Precio actualizado recientemente'),
('Venta','Venta cancelada'),
('Cliente','Cliente con actividad inactiva');


INSERT INTO datos_temporales(informacion) VALUES
('Proceso temporal de importacion'),
('Validacion temporal de productos'),
('Calculo temporal de ventas'),
('Revision temporal de clientes'),
('Proceso temporal de inventario');

