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
total_gastado decimal(10,2) default 0
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

CREATE TABLE carritos (
    id_carrito INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('Activo', 'Comprado', 'Abandonado') DEFAULT 'Activo',
    FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
);

CREATE TABLE detalle_carrito (
    id_detalle_carrito INT AUTO_INCREMENT PRIMARY KEY,
    id_carrito INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK(cantidad > 0),
    FOREIGN KEY (id_carrito)
        REFERENCES carritos(id_carrito),
    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);

CREATE TABLE promociones (
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_producto INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    descuento DECIMAL(5,2) NOT NULL CHECK(descuento > 0),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);


CREATE TABLE vistas_productos (
    id_vista INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_cliente INT,
    fecha_vista DATETIME NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE auditoria_precios (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 5 
CREATE TABLE auditoria_clientes (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    nombres VARCHAR(100),
    apellidos VARCHAR(100),
    email VARCHAR(100),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO clientes
(nombres, apellidos, fecha_nacimiento, ciudad, region, email, contrasenia, direccion_envio, total_gastado)
VALUES
('Ana', 'Gomez', '1998-05-12', 'Bucaramanga', 'Santander', 'ana.gomez@gmail.com', 'ana123', 'Calle 45 #12-30',10000),
('Luis', 'Martinez', '1995-08-20', 'Bogota', 'Cundinamarca', 'luis.martinez@gmail.com', 'luis123', 'Carrera 10 #20-15',213131),
('Marta', 'Rodriguez', '2000-02-10', 'Medellin', 'Antioquia', 'marta.rodriguez@gmail.com', 'marta123', 'Calle 50 #30-20',111123),
('Carlos', 'Perez', '1997-11-25', 'Cali', 'Valle del Cauca', 'carlos.perez@gmail.com', 'carlos123', 'Carrera 5 #15-40',1999999),
('Sofia', 'Torres', '2001-07-18', 'Barranquilla', 'Atlantico', 'sofia.torres@gmail.com', 'sofia123', 'Calle 80 #10-25',200000),
('Diego', 'Hernandez', '1994-03-30', 'Cartagena', 'Bolivar', 'diego.hernandez@gmail.com', 'diego123', 'Carrera 2 #30-10',3021232);

INSERT INTO categorias
(id_categoria, nombre, descripcion)
VALUES
(1, 'Computadores', 'Computadores y equipos de escritorio'),
(2, 'Perifericos', 'Accesorios para computador'),
(3, 'Celulares', 'Telefonos celulares y smartphones'),
(4, 'Audio', 'Audifonos, parlantes y equipos de audio'),
(5, 'Almacenamiento', 'Discos, memorias y dispositivos de almacenamiento');

INSERT INTO proveedores
(id_proveedor, nombre, email_contacto, telefono_contacto)
VALUES
(1, 'Tech Colombia', 'contacto@techcolombia.com', '3001234567'),
(2, 'Digital Store', 'ventas@digitalstore.com', '3012345678'),
(3, 'Mega Electronica', 'contacto@megaelectronica.com', '3023456789'),
(4, 'Importaciones JD', 'ventas@importacionesjd.com', '3034567890'),
(5, 'Global Tech', 'info@globaltech.com', '3045678901');

INSERT INTO productos
(nombre, descripcion, precio, costo, stock, sku, activo, id_categoria, id_proveedor, stock_minimo, ubicacion, peso, fecha_creacion, fecha_modificacion)
VALUES
('Laptop Lenovo IdeaPad', 'Laptop Lenovo para trabajo y estudio', 2500000.00, 2000000.00, 15, 'LAP-001', TRUE, 1, 1, 5, 'A1', 1.80, NOW(), NOW()),

('Laptop HP Pavilion', 'Laptop HP para uso profesional', 3200000.00, 2700000.00, 10, 'LAP-002', TRUE, 1, 2, 3, 'A2', 1.70, NOW(), NOW()),

('Mouse Logitech', 'Mouse inalambrico Logitech', 85000.00, 50000.00, 50, 'MOU-001', TRUE, 2, 1, 10, 'B1', 0.10, NOW(), NOW()),

('Teclado Redragon', 'Teclado mecanico para gaming', 220000.00, 150000.00, 30, 'TEC-001', TRUE, 2, 3, 5, 'B2', 0.80, NOW(), NOW()),

('iPhone 15', 'Smartphone Apple iPhone 15', 4200000.00, 3500000.00, 8, 'IPH-001', TRUE, 3, 4, 2, 'C1', 0.17, NOW(), NOW()),

('Samsung Galaxy S24', 'Smartphone Samsung Galaxy S24', 3500000.00, 2900000.00, 12, 'SAM-001', TRUE, 3, 4, 3, 'C2', 0.16, NOW(), NOW()),

('Audifonos Sony', 'Audifonos inalambricos Sony', 450000.00, 320000.00, 25, 'AUD-001', TRUE, 4, 5, 5, 'D1', 0.25, NOW(), NOW()),

('Parlante JBL', 'Parlante Bluetooth JBL', 380000.00, 280000.00, 20, 'PAR-001', TRUE, 4, 5, 4, 'D2', 0.70, NOW(), NOW()),

('SSD Kingston 1TB', 'Unidad de almacenamiento SSD de 1TB', 350000.00, 250000.00, 35, 'SSD-001', TRUE, 5, 2, 8, 'E1', 0.10, NOW(), NOW()),

('Memoria USB 128GB', 'Memoria USB de 128GB', 70000.00, 40000.00, 60, 'USB-001', TRUE, 5, 3, 15, 'E2', 0.02, NOW(), NOW());
INSERT INTO ventas
(id_venta, fecha_venta, estado, total, id_cliente)
VALUES
(1, '2026-01-15 10:30:00', 'Entregado', 2585000.00, 1),
(2, '2026-02-10 14:20:00', 'Procesando', 4420000.00, 2),
(3, '2026-03-05 09:15:00', 'Enviado', 3950000.00, 3),
(4, '2026-03-20 16:40:00', 'Pendiente de Pago', 730000.00, 4),
(5, '2026-04-12 11:10:00', 'Entregado', 420000.00, 5),
(6, '2026-05-25 18:30:00', 'Cancelado', 2500000.00, 6),
(7, '2026-06-10 10:00:00', 'Entregado', 500000.00, 1),
(8, '2026-07-15 15:30:00', 'Entregado', 850000.00, 2),
(9,  '2026-01-05 09:20:00', 'Entregado', 2500000.00, 1),
(10, '2026-01-18 11:45:00', 'Entregado', 5000000.00, 2),
(11, '2026-01-28 16:10:00', 'Entregado', 3200000.00, 3),
(12, '2026-02-05 10:15:00', 'Entregado', 170000.00, 4),
(13, '2026-02-14 18:40:00', 'Entregado', 4200000.00, 5),
(14, '2026-02-25 14:30:00', 'Entregado', 440000.00, 6),
(15, '2026-03-08 12:00:00', 'Entregado', 3500000.00, 1),
(16, '2026-03-18 17:25:00', 'Entregado', 900000.00, 2),
(17, '2026-03-28 19:10:00', 'Entregado', 760000.00, 3),
(18, '2026-04-08 08:45:00', 'Entregado', 700000.00, 4),
(19, '2026-04-18 13:35:00', 'Entregado', 140000.00, 5),
(20, '2026-04-28 20:15:00', 'Entregado', 350000.00, 6),
(21, '2026-05-10 10:20:00', 'Entregado', 2500000.00, 1),
(22, '2026-05-20 15:40:00', 'Entregado', 5000000.00, 2),
(23, '2026-05-30 18:10:00', 'Cancelado', 220000.00, 3),
(24, '2026-06-05 09:30:00', 'Entregado', 440000.00, 4),
(25, '2026-06-15 12:50:00', 'Entregado', 900000.00, 5),
(26, '2026-06-28 16:20:00', 'Entregado', 700000.00, 6),
(27, '2026-07-05 11:00:00', 'Entregado', 760000.00, 1),
(28, '2026-07-18 17:45:00', 'Entregado', 1050000.00, 2),
(29, '2026-07-28 19:30:00', 'Entregado', 140000.00, 3),
(30, '2026-08-05 08:15:00', 'Entregado', 3200000.00, 4),
(31, '2026-08-15 14:10:00', 'Entregado', 4200000.00, 5),
(32, '2026-08-25 18:55:00', 'Entregado', 3500000.00, 6);

INSERT INTO detalle_ventas
(id_detalle, cantidad, precio_unitario_congelado, id_producto, id_venta)
VALUES
(1, 1, 2500000.00, 1, 1),
(2, 1, 85000.00, 3, 1),
(3, 1, 4200000.00, 5, 2),
(4, 1, 220000.00, 4, 2),
(5, 1, 3500000.00, 6, 3),
(6, 1, 450000.00, 7, 3),
(7, 1, 350000.00, 9, 4),
(8, 1, 380000.00, 8, 4),
(9, 1, 350000.00, 9, 5),
(10, 1, 70000.00, 10, 5),
(11, 1, 2500000.00, 1, 6),
(12, 1, 280000.00, 8, 7),
(13, 1, 220000.00, 4, 7),
(14, 1, 450000.00, 7, 8),
(15, 1, 400000.00, 8, 8),
(16, 1, 2500000.00, 1, 9),
(17, 2, 2500000.00, 1, 10),
(18, 1, 3200000.00, 2, 11),
(19, 2, 85000.00, 3, 12),
(20, 1, 4200000.00, 5, 13),
(21, 2, 220000.00, 4, 14),
(22, 1, 3500000.00, 6, 15),
(23, 2, 450000.00, 7, 16),
(24, 2, 380000.00, 8, 17),
(25, 2, 350000.00, 9, 18),
(26, 2, 70000.00, 10, 19),
(27, 1, 350000.00, 9, 20),
(28, 1, 2500000.00, 1, 21),
(29, 2, 2500000.00, 1, 22),
(30, 1, 220000.00, 4, 23),
(31, 2, 220000.00, 4, 24),
(32, 2, 450000.00, 7, 25),
(33, 2, 350000.00, 9, 26),
(34, 2, 380000.00, 8, 27),
(35, 3, 350000.00, 9, 28),
(36, 2, 70000.00, 10, 29),
(37, 1, 3200000.00, 2, 30),
(38, 1, 4200000.00, 5, 31),
(39, 1, 3500000.00, 6, 32);

INSERT INTO carritos
(id_cliente, fecha_creacion, estado)
VALUES
(1, '2026-09-10 10:00:00', 'Abandonado'),
(2, '2026-09-12 12:00:00', 'Comprado'),
(3, '2026-09-11 09:30:00', 'Abandonado'),
(4, '2026-09-13 08:00:00', 'Activo'),
(5, '2026-09-09 15:45:00', 'Abandonado');

INSERT INTO detalle_carrito
(id_carrito, id_producto, cantidad)
VALUES
(1, 3, 2),
(1, 4, 1),
(2, 5, 1),
(3, 7, 2),
(3, 10, 3),
(4, 1, 1),
(5, 9, 2);

INSERT INTO promociones
(nombre, id_producto, fecha_inicio, fecha_fin, descuento)
VALUES
('Promo HP Pavilion', 2, '2026-01-25 00:00:00', '2026-02-12 23:59:59', 12.00),
('Promo Teclado Redragon', 4, '2026-02-20 00:00:00', '2026-03-10 23:59:59', 10.00),
('Promo Samsung Galaxy S24', 6, '2026-02-25 00:00:00', '2026-03-12 23:59:59', 18.00),
('Promo Audifonos Sony', 7, '2026-03-10 00:00:00', '2026-03-25 23:59:59', 15.00),
('Promo Parlante JBL', 8, '2026-03-15 00:00:00', '2026-03-30 23:59:59', 20.00),
('Promo SSD Kingston', 9, '2026-04-01 00:00:00', '2026-04-20 23:59:59', 10.00),
('Promo Memoria USB', 10, '2026-04-05 00:00:00', '2026-04-25 23:59:59', 25.00),
('Promo Regreso a Clases Lenovo', 1, '2026-05-15 00:00:00', '2026-05-31 23:59:59', 15.00),
('Promo Gamer Redragon', 4, '2026-06-01 00:00:00', '2026-06-20 23:59:59', 20.00),
('Promo Audio Sony', 7, '2026-06-20 00:00:00', '2026-07-05 23:59:59', 12.00),
('Promo JBL Julio', 8, '2026-07-01 00:00:00', '2026-07-20 23:59:59', 15.00),
('Promo SSD Julio', 9, '2026-07-10 00:00:00', '2026-07-25 23:59:59', 18.00);

INSERT INTO vistas_productos
(id_producto, id_cliente, fecha_vista)
VALUES
(1, 1, '2026-01-03 10:00:00'),
(1, 2, '2026-01-04 11:15:00'),
(1, 3, '2026-01-05 14:20:00'),
(1, 4, '2026-01-06 16:30:00'),
(1, 5, '2026-01-07 18:00:00'),
(2, 1, '2026-01-10 09:10:00'),
(2, 2, '2026-01-11 10:45:00'),
(2, 3, '2026-01-12 12:20:00'),
(3, 1, '2026-02-01 08:30:00'),
(3, 2, '2026-02-02 09:40:00'),
(3, 3, '2026-02-03 10:50:00'),
(3, 4, '2026-02-04 11:10:00'),
(3, 5, '2026-02-05 15:35:00'),
(3, 6, '2026-02-06 17:25:00'),
(4, 1, '2026-02-10 13:00:00'),
(4, 2, '2026-02-11 14:10:00'),
(5, 1, '2026-03-01 09:20:00'),
(5, 2, '2026-03-02 10:40:00'),
(5, 3, '2026-03-03 11:50:00'),
(5, 4, '2026-03-04 13:15:00'),
(5, 5, '2026-03-05 15:30:00'),
(5, 6, '2026-03-06 16:45:00'),
(5, 1, '2026-03-07 18:10:00'),
(6, 2, '2026-03-10 08:10:00'),
(6, 3, '2026-03-11 09:25:00'),
(6, 4, '2026-03-12 10:35:00'),
(7, 1, '2026-04-01 11:00:00'),
(7, 2, '2026-04-02 12:15:00'),
(7, 3, '2026-04-03 13:30:00'),
(7, 4, '2026-04-04 15:40:00'),
(7, 5, '2026-04-05 17:00:00'),
(8, 1, '2026-04-10 09:30:00'),
(8, 2, '2026-04-11 10:20:00'),
(9, 1, '2026-05-01 08:50:00'),
(9, 2, '2026-05-02 09:55:00'),
(9, 3, '2026-05-03 11:05:00'),
(9, 4, '2026-05-04 12:10:00'),
(9, 5, '2026-05-05 13:15:00'),
(10, 3, '2026-05-10 10:00:00'),
(10, 4, '2026-05-11 11:20:00'),
(10, 5, '2026-05-12 12:40:00');


