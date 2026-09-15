USE Ecommerce;

SET GLOBAL event_scheduler = ON;

-- 1. Genera un reporte de ventas semanal
CREATE EVENT evt_generate_weekly_sales_report
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO reporte_ventas_semanal(fecha_inicio, fecha_fin, total_ventas)
SELECT
    DATE_SUB(CURDATE(), INTERVAL 6 DAY),
    CURDATE(),
    COALESCE(SUM(total), 0)
FROM ventas
WHERE DATE(fecha) BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 DAY) AND CURDATE();


-- 2. Borra los datos de las tablas temporales diariamente
CREATE EVENT evt_cleanup_temp_tables_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
DELETE FROM datos_temporales;


-- 3. Archiva logs de más de 6 meses
DELIMITER //

CREATE EVENT evt_archive_old_logs_monthly
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO logs_historicos
    SELECT *
    FROM logs
    WHERE fecha < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

    DELETE FROM logs
    WHERE fecha < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
END//

DELIMITER ;


-- 4. Desactiva códigos de descuento que han expirado
CREATE EVENT evt_deactivate_expired_promotions_hourly
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
UPDATE promociones
SET estado = 'INACTIVA'
WHERE fecha_fin < CURRENT_TIMESTAMP
AND estado = 'ACTIVA';


-- 5. Recalcula el nivel de lealtad de los clientes cada noche
DELIMITER //

CREATE EVENT evt_recalculate_customer_loyalty_tiers_nightly
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 23 HOUR
DO
BEGIN
    UPDATE clientes c
    SET categoria = CASE
        WHEN (
            SELECT COALESCE(SUM(v.total), 0)
            FROM ventas v
            WHERE v.id_cliente = c.id_cliente
        ) >= 5000 THEN 'VIP'
        WHEN (
            SELECT COALESCE(SUM(v.total), 0)
            FROM ventas v
            WHERE v.id_cliente = c.id_cliente
        ) >= 2000 THEN 'PREMIUM'
        ELSE 'NORMAL'
    END;
END//

DELIMITER ;


-- 6. Crea una lista de productos que necesitan reabastecimiento
DELIMITER //

CREATE EVENT evt_generate_reorder_list_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM lista_reabastecimiento;

    INSERT INTO lista_reabastecimiento(id_producto, stock_actual, fecha)
    SELECT
        p.id_producto,
        i.stock,
        CURRENT_DATE
    FROM productos p
    INNER JOIN inventario i
        ON p.id_producto = i.id_producto
    WHERE i.stock <= i.stock_minimo;
END//

DELIMITER ;


-- 7. Optimiza semanalmente las tablas más utilizadas
DELIMITER //

CREATE EVENT evt_rebuild_indexes_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    OPTIMIZE TABLE clientes;
    OPTIMIZE TABLE productos;
    OPTIMIZE TABLE ventas;
END//

DELIMITER ;


-- 8. Desactiva cuentas sin actividad durante más de un año
CREATE EVENT evt_suspend_inactive_accounts_quarterly
ON SCHEDULE EVERY 3 MONTH
STARTS CURRENT_TIMESTAMP
DO
UPDATE clientes
SET estado = 'INACTIVO'
WHERE ultima_actividad < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
AND estado = 'ACTIVO';


-- 9. Agrega las ventas del día en una tabla de resumen
CREATE EVENT evt_aggregate_daily_sales_data
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO resumen_ventas_diarias(fecha, cantidad_ventas, total_ventas)
SELECT
    CURDATE(),
    COUNT(*),
    COALESCE(SUM(total), 0)
FROM ventas
WHERE DATE(fecha) = CURDATE();


-- 10. Busca inconsistencias en los datos
CREATE EVENT evt_check_data_consistency_nightly
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 23 HOUR
DO
INSERT INTO inconsistencias(fecha, descripcion)
SELECT
    CURRENT_TIMESTAMP,
    CONCAT('La venta ', v.id_venta, ' no tiene detalles')
FROM ventas v
LEFT JOIN detalle_ventas d
    ON v.id_venta = d.id_venta
WHERE d.id_venta IS NULL;