-- =======================================================
-- 				procesos del 1-10 
-- =======================================================

DELIMITER //
-- 1. REALIZAR NUEVA VENTA

CREATE PROCEDURE sp_RealizarNuevaVenta(
    IN p_id_cliente INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_id_venta INT;

    SELECT stock, precio
    INTO v_stock, v_precio
    FROM productos
    WHERE id_producto = p_id_producto;
    IF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay suficiente stock';
    END IF;
    SET v_total = v_precio * p_cantidad;

    START TRANSACTION;

    INSERT INTO ventas(estado, total, id_cliente)
    VALUES('Procesando', v_total, p_id_cliente);

    SET v_id_venta = LAST_INSERT_ID();

    INSERT INTO detalle_ventas(
        cantidad,
        precio_unitario_congelado,
        id_producto,
        id_venta
    )
    VALUES(
        p_cantidad,
        v_precio,
        p_id_producto,
        v_id_venta
    );
    UPDATE productos
    SET stock = stock - p_cantidad
    WHERE id_producto = p_id_producto;
    COMMIT;
END //



-- 2. AGREGAR NUEVO PRODUCTO


CREATE PROCEDURE sp_AgregarNuevoProducto(
    IN p_nombre VARCHAR(50),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_costo DECIMAL(10,2),
    IN p_stock INT,
    IN p_sku VARCHAR(50),
    IN p_id_categoria INT,
    IN p_id_proveedor INT,
    IN p_stock_minimo INT,
    IN p_ubicacion VARCHAR(50),
    IN p_peso DECIMAL(10,2)
)
BEGIN
    INSERT INTO productos(
        nombre,
        descripcion,
        precio,
        costo,
        stock,
        sku,
        activo,
        id_categoria,
        id_proveedor,
        stock_minimo,
        ubicacion,
        peso
    )
    VALUES(
        p_nombre,
        p_descripcion,
        p_precio,
        p_costo,
        p_stock,
        p_sku,
        TRUE,
        p_id_categoria,
        p_id_proveedor,
        p_stock_minimo,
        p_ubicacion,
        p_peso
    );
END //


-- 3. ACTUALIZAR DIRECCION CLIENTE
CREATE PROCEDURE sp_ActualizarDireccionCliente(
    IN p_id_cliente INT,
    IN p_nueva_direccion VARCHAR(100)
)
BEGIN
    UPDATE clientes
    SET direccion_envio = p_nueva_direccion
    WHERE id_cliente = p_id_cliente;
END //



-- 4. PROCESAR DEVOLUCION


CREATE PROCEDURE sp_ProcesarDevolucion(
    IN p_id_venta INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_credito DECIMAL(10,2);
    SELECT precio_unitario_congelado
    INTO v_precio
    FROM detalle_ventas
    WHERE id_venta = p_id_venta
    AND id_producto = p_id_producto;
    SET v_credito = v_precio * p_cantidad;
    START TRANSACTION;
    INSERT INTO devoluciones(
        id_venta,
        id_producto,
        cantidad,
        monto_credito
    )
    VALUES(
        p_id_venta,
        p_id_producto,
        p_cantidad,
        v_credito
    );
    UPDATE productos
    SET stock = stock + p_cantidad
    WHERE id_producto = p_id_producto;
    COMMIT;
END //



-- 5. OBTENER HISTORIAL DE COMPRAS DEL CLIENTE


CREATE PROCEDURE sp_ObtenerHistorialComprasCliente(
    IN p_id_cliente INT
)
BEGIN
    SELECT
        v.id_venta,
        v.fecha_venta,
        v.estado,
        p.nombre AS producto,
        dv.cantidad,
        dv.precio_unitario_congelado,
        (dv.cantidad * dv.precio_unitario_congelado) AS subtotal,
        v.total
    FROM ventas v
    JOIN detalle_ventas dv
        ON v.id_venta = dv.id_venta
    JOIN productos p
        ON dv.id_producto = p.id_producto
    WHERE v.id_cliente = p_id_cliente
    ORDER BY v.fecha_venta DESC;
END //




-- 6. sp_AjustarNivelStock
-- Permite ajustar manualmente el stock de un producto
-- registrando el motivo del cambio

CREATE PROCEDURE sp_AjustarNivelStock(
    IN p_id_producto INT,
    IN p_nuevo_stock INT,
    IN p_motivo VARCHAR(255)
)
BEGIN
    DECLARE v_stock_anterior INT;

    IF p_nuevo_stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;

    SELECT stock
    INTO v_stock_anterior
    FROM productos
    WHERE id_producto = p_id_producto;

    IF v_stock_anterior IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto no existe';
    END IF;

    UPDATE productos
    SET stock = p_nuevo_stock,
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_producto = p_id_producto;

    INSERT INTO auditoria_stock(
        id_producto,
        stock_anterior,
        stock_nuevo,
        motivo
    )
    VALUES(
        p_id_producto,
        v_stock_anterior,
        p_nuevo_stock,
        p_motivo
    );
END//


-- 7. sp_EliminarClienteDeFormaSegura
-- Anonimiza los datos del cliente en lugar de eliminarlo
-- para mantener la integridad referencial

CREATE PROCEDURE sp_EliminarClienteDeFormaSegura(
    IN p_id_cliente INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM clientes
        WHERE id_cliente = p_id_cliente
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no existe';
    END IF;

    UPDATE clientes
    SET nombres = 'Cliente',
        apellidos = 'Anonimizado',
        fecha_nacimiento = '1900-01-01',
        ciudad = 'Anonimizada',
        region = 'Anonimizada',
        email = CONCAT('anonimizado_', id_cliente, '@correo.com'),
        contrasenia = 'ANONIMIZADA',
        direccion_envio = NULL,
        total_gastado = 0,
        nivel_lealtad = 'Bronce',
        activo = FALSE,
        ultima_actividad = NULL
    WHERE id_cliente = p_id_cliente;
END//


-- 8. sp_AplicarDescuentoPorCategoria
-- Crea una promoción para todos los productos
-- pertenecientes a una categoría específica

CREATE PROCEDURE sp_AplicarDescuentoPorCategoria(
    IN p_id_categoria INT,
    IN p_descuento DECIMAL(5,2),
    IN p_fecha_inicio DATETIME,
    IN p_fecha_fin DATETIME
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM categorias
        WHERE id_categoria = p_id_categoria
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La categoría no existe';
    END IF;

    IF p_descuento <= 0 OR p_descuento >= 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El descuento debe estar entre 0 y 100';
    END IF;

    IF p_fecha_fin <= p_fecha_inicio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha final debe ser posterior a la fecha inicial';
    END IF;

    INSERT INTO promociones(
        nombre,
        id_producto,
        fecha_inicio,
        fecha_fin,
        descuento,
        activo
    )
    SELECT
        CONCAT('Descuento categoría ', p_id_categoria),
        id_producto,
        p_fecha_inicio,
        p_fecha_fin,
        p_descuento,
        TRUE
    FROM productos
    WHERE id_categoria = p_id_categoria
    AND activo = TRUE;
END//


-- 9. sp_GenerarReporteMensualVentas
-- Genera un reporte de ventas para un mes y año específicos

CREATE PROCEDURE sp_GenerarReporteMensualVentas(
    IN p_mes INT,
    IN p_anio INT
)
BEGIN
    IF p_mes < 1 OR p_mes > 12 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El mes debe estar entre 1 y 12';
    END IF;

    SELECT
        YEAR(v.fecha_venta) AS anio,
        MONTH(v.fecha_venta) AS mes,
        COUNT(v.id_venta) AS cantidad_ventas,
        COALESCE(SUM(v.total), 0) AS total_vendido
    FROM ventas v
    WHERE MONTH(v.fecha_venta) = p_mes
    AND YEAR(v.fecha_venta) = p_anio
    AND v.estado <> 'Cancelado'
    GROUP BY YEAR(v.fecha_venta), MONTH(v.fecha_venta);
END//


-- 10. sp_CambiarEstadoPedido
-- Cambia el estado de una venta/pedido
-- y registra una notificación para otros sistemas

CREATE PROCEDURE sp_CambiarEstadoPedido(
    IN p_id_venta INT,
    IN p_nuevo_estado VARCHAR(30)
)
BEGIN
    DECLARE v_estado_actual VARCHAR(30);

    SELECT estado
    INTO v_estado_actual
    FROM ventas
    WHERE id_venta = p_id_venta;

    IF v_estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La venta no existe';
    END IF;

    IF p_nuevo_estado NOT IN (
        'Pendiente de Pago',
        'Procesando',
        'Enviado',
        'Entregado',
        'Cancelado'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado no válido';
    END IF;

    UPDATE ventas
    SET estado = p_nuevo_estado
    WHERE id_venta = p_id_venta;

    INSERT INTO notificaciones(
        id_venta,
        mensaje
    )
    VALUES(
        p_id_venta,
        CONCAT(
            'La venta ',
            p_id_venta,
            ' cambió de estado de ',
            v_estado_actual,
            ' a ',
            p_nuevo_estado
        )
    );
END//

DELIMITER ;
