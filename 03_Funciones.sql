DELIMITER //

-- 1. fn_CalcularTotalVenta: Calcula el monto total de una venta específica.
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


-- 2. fn_VerificarDisponibilidadStock: Valida si hay stock suficiente para un producto.
CREATE FUNCTION fn_VerificarDisponibilidadStock(
    p_id_producto INT,
    p_stock_solicitado INT
)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE stock_total INT;

    SELECT stock
    INTO stock_total
    FROM productos
    WHERE id_producto = p_id_producto;

    IF p_stock_solicitado <= stock_total THEN
        RETURN CONCAT('Stock suficiente, el stock total disponible es de ', stock_total);
    ELSE
        RETURN CONCAT('Stock insuficiente, el stock total disponible es de ', stock_total);
    END IF;
END //


-- 3. fn_ObtenerPrecioProducto: Devuelve el precio actual de un producto.
CREATE FUNCTION fn_ObtenerPrecioProducto(
    p_id_producto INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE precio_producto DECIMAL(10,2);

    SELECT precio
    INTO precio_producto
    FROM productos
    WHERE id_producto = p_id_producto;

    RETURN precio_producto;
END //


-- 4. fn_CalcularEdadCliente: Calcula la edad de un cliente a partir de su fecha de nacimiento.
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


-- 5. fn_FormatearNombreCompleto: Devuelve el nombre y apellido de un cliente en un formato estandarizado.
CREATE FUNCTION fn_FormatearNombreCompleto(
    p_id_cliente INT
)
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(200);

    SELECT CONCAT(nombres, ' ', apellidos)
    INTO nombre_completo
    FROM clientes
    WHERE id_cliente = p_id_cliente;

    RETURN nombre_completo;
END //


-- 6. fn_EsClienteNuevo: Devuelve VERDADERO si un cliente realizó su primera compra en los últimos 30 días.
CREATE FUNCTION fn_EsClienteNuevo(
    p_id_cliente INT
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE primera_compra DATETIME;

    SELECT MIN(fecha_venta)
    INTO primera_compra
    FROM ventas
    WHERE id_cliente = p_id_cliente;

    IF primera_compra >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //


-- 7. fn_CalcularCostoEnvio: Calcula el costo de envío basado en el peso total de los productos de una venta.
CREATE FUNCTION fn_CalcularCostoEnvio(
    p_id_venta INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE peso_total DECIMAL(10,2);
    DECLARE costo_envio DECIMAL(10,2);

    SELECT SUM(d.cantidad * p.peso)
    INTO peso_total
    FROM detalle_ventas d
    JOIN productos p
        ON d.id_producto = p.id_producto
    WHERE d.id_venta = p_id_venta;

    IF peso_total <= 1 THEN
        SET costo_envio = 5000;
    ELSE
        SET costo_envio = 5000 + ((peso_total - 1) * 2000);
    END IF;

    RETURN costo_envio;
END //


-- 8. fn_AplicarDescuento: Aplica un porcentaje de descuento a un monto dado.
CREATE FUNCTION fn_AplicarDescuento(
    p_monto DECIMAL(10,2),
    p_porcentaje DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE monto_final DECIMAL(10,2);

    SET monto_final = p_monto - (p_monto * p_porcentaje / 100);

    RETURN monto_final;
END //


-- 9. fn_ObtenerUltimaFechaCompra: Devuelve la fecha de la última compra de un cliente.
CREATE FUNCTION fn_ObtenerUltimaFechaCompra(
    p_id_cliente INT
)
RETURNS DATETIME
DETERMINISTIC
BEGIN
    DECLARE ultima_compra DATETIME;

    SELECT MAX(fecha_venta)
    INTO ultima_compra
    FROM ventas
    WHERE id_cliente = p_id_cliente;

    RETURN ultima_compra;
END //


-- 16. fn_CalcularIVA: Calcula el impuesto (IVA) sobre el total de una venta.
CREATE FUNCTION fn_CalcularIVA(
    p_total_venta DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_total_venta * 0.19;
END //

DELIMITER ;