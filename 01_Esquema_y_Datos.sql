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
