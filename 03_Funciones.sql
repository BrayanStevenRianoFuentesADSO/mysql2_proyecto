DELIMITER //

CREATE FUNCTION fn_CalcularTotalVenta(p_id_venta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_venta DECIMAL(10,2);

    SELECT SUM(cantidad * precio_unitario_congelado)
    INTO total_venta
    FROM detalle_ventas
    WHERE id_venta = p_id_venta;

    RETURN total_venta;
END //

-- fn_VerificarDisponibilidadStock: Valida si hay stock suficiente para un producto.

CREATE FUNCTION fn_VerificarDisponibilidadStock(
    p_id_producto INT,
    p_stock_solicitado INT
)

RETURNS Varchar(50)
DETERMINISTIC

BEGIN
    DECLARE stock_total INT;

    SELECT stock
    INTO stock_total
    FROM productos
    WHERE id_producto = p_id_producto;

    if p_stock_solicitado <=stock_total then
    return concat("stock suficiente, el stock total disponible es de ", stock_total);
    
    else
    return concat("stock insuficiente el stock total disponible es de ", stock_total);
    end if;
END //


-- fn_ObtenerPrecioProducto: Devuelve el precio actual de un producto.

CREATE FUNCTION fn_ObtenerPrecioProducto(
p_id_producto int
)
returns decimal(10,2)
deterministic 


begin
	declare precio_producto decimal(10,2);
	select precio 
	into precio_producto
	from productos
	where id_producto=p_id_producto;
	
return precio_producto;
end //

CREATE FUNCTION fn_CalcularEdadCliente(
    p_id_cliente INT
)
RETURNS INT
DETERMINISTIC
BEGIN

    DECLARE anio_nacimiento INT;
    DECLARE mes_nacimiento INT;
    DECLARE dia_nacimiento INT;
    DECLARE anio_actual INT;
    DECLARE mes_actual INT;
    DECLARE dia_actual INT;
    DECLARE edad_cliente INT;

    SELECT YEAR(fecha_nacimiento),
           MONTH(fecha_nacimiento),
           DAY(fecha_nacimiento)
    INTO anio_nacimiento,
         mes_nacimiento,
         dia_nacimiento
    FROM clientes
    WHERE id_cliente = p_id_cliente;

    SELECT YEAR(CURDATE()),
           MONTH(CURDATE()),
           DAY(CURDATE())
    INTO anio_actual,
         mes_actual,
         dia_actual;

    IF mes_actual > mes_nacimiento
       OR (mes_actual = mes_nacimiento AND dia_actual >= dia_nacimiento) THEN

        RETURN anio_actual - anio_nacimiento;

    ELSE

        RETURN anio_actual - anio_nacimiento - 1;

    END IF;

END //
DELIMITER ;


SELECT fn_CalcularEdadCliente(4);