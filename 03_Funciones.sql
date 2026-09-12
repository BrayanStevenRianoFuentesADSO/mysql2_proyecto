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

    RETURN COALESCE(total_venta, 0);
END //

DELIMITER ;
