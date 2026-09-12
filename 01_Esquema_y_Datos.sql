drop database if exists Ecommerce;

create DATABASE Ecomerce;

use Ecomerce;

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
    fecha_registro datetime DEFAULT CURRENT_TIMESTAMP
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
id_venta int primary key,
fecha_venta datetime default current_timestamp,
estado enum('Pendiente de Pago', 'Procesando', 'Enviado', 'Entregado', 'Cancelado'),
total decimal(10,2),
id_cliente int,
foreign key (id_cliente) references clientes(id_cliente)
);

CREATE table detalle_ventas(
id_detalle int primary key,
cantidad int check(cantidad>0),
precio_unitario_congelado decimal(10,2) check(precio_unitario_congelado >0),
id_producto int,
id_venta int,
foreign key (id_producto) references productos(id_producto),
foreign key (id_venta) references ventas(id_venta)
);

INSERT INTO clientes
(nombres, apellidos, fecha_nacimiento, ciudad, region, email, contrasenia, direccion_envio)
VALUES
('Ana', 'Gomez', '1998-05-12', 'Bucaramanga', 'Santander', 'ana.gomez@gmail.com', 'ana123', 'Calle 45 #12-30'),
('Luis', 'Martinez', '1995-08-20', 'Bogota', 'Cundinamarca', 'luis.martinez@gmail.com', 'luis123', 'Carrera 10 #20-15'),
('Marta', 'Rodriguez', '2000-02-10', 'Medellin', 'Antioquia', 'marta.rodriguez@gmail.com', 'marta123', 'Calle 50 #30-20'),
('Carlos', 'Perez', '1997-11-25', 'Cali', 'Valle del Cauca', 'carlos.perez@gmail.com', 'carlos123', 'Carrera 5 #15-40'),
('Sofia', 'Torres', '2001-07-18', 'Barranquilla', 'Atlantico', 'sofia.torres@gmail.com', 'sofia123', 'Calle 80 #10-25'),
('Diego', 'Hernandez', '1994-03-30', 'Cartagena', 'Bolivar', 'diego.hernandez@gmail.com', 'diego123', 'Carrera 2 #30-10');

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
(nombre, descripcion, precio, costo, stock, sku, activo, id_categoria, id_proveedor, stock_minimo, ubicacion, peso)
VALUES
('Laptop Lenovo IdeaPad', 'Laptop Lenovo para trabajo y estudio', 2500000.00, 2000000.00, 15, 'LAP-001', TRUE, 1, 1, 5, 'A1', 1.80),
('Laptop HP Pavilion', 'Laptop HP para uso profesional', 3200000.00, 2700000.00, 10, 'LAP-002', TRUE, 1, 2, 3, 'A2', 1.70),
('Mouse Logitech', 'Mouse inalambrico Logitech', 85000.00, 50000.00, 50, 'MOU-001', TRUE, 2, 1, 10, 'B1', 0.10),
('Teclado Redragon', 'Teclado mecanico para gaming', 220000.00, 150000.00, 30, 'TEC-001', TRUE, 2, 3, 5, 'B2', 0.80),
('iPhone 15', 'Smartphone Apple iPhone 15', 4200000.00, 3500000.00, 8, 'IPH-001', TRUE, 3, 4, 2, 'C1', 0.17),
('Samsung Galaxy S24', 'Smartphone Samsung Galaxy S24', 3500000.00, 2900000.00, 12, 'SAM-001', TRUE, 3, 4, 3, 'C2', 0.16),
('Audifonos Sony', 'Audifonos inalambricos Sony', 450000.00, 320000.00, 25, 'AUD-001', TRUE, 4, 5, 5, 'D1', 0.25),
('Parlante JBL', 'Parlante Bluetooth JBL', 380000.00, 280000.00, 20, 'PAR-001', TRUE, 4, 5, 4, 'D2', 0.70),
('SSD Kingston 1TB', 'Unidad de almacenamiento SSD de 1TB', 350000.00, 250000.00, 35, 'SSD-001', TRUE, 5, 2, 8, 'E1', 0.10),
('Memoria USB 128GB', 'Memoria USB de 128GB', 70000.00, 40000.00, 60, 'USB-001', TRUE, 5, 3, 15, 'E2', 0.02);

INSERT INTO ventas
(id_venta, estado, total, id_cliente)
VALUES
(1, 'Entregado', 2585000.00, 1),
(2, 'Procesando', 4420000.00, 2),
(3, 'Enviado', 3950000.00, 3),
(4, 'Pendiente de Pago', 730000.00, 4),
(5, 'Entregado', 420000.00, 5),
(6, 'Cancelado', 2500000.00, 6);

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

(11, 1, 2500000.00, 1, 6);


