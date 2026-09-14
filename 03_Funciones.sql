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

CREATE function fn_ObtenerPrecioProducto(

p_id_producto int
)

deterministic

begin
	select precio from 
end

DELIMITER ;


SELECT fn_VerificarDisponibilidadStock(1, 16);


