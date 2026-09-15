-- =======================================================
-- 				Creacion de los triggers
-- =======================================================
delimiter //

-- 1.trg_audit_precio_producto_after_update: Guarda un log de cambios de precios.
create trigger tr_trg_audit_precio_producto_after_update
after update on productos
for each row
begin
	if new.precio <> old.precio then
	insert into auditoria_precios (id_producto, precio_anterior, precio_nuevo, fecha_modificacion)
	values (old.id_producto, old.precio, new.precio, now());
	end if;
end //

-- 2.trg_check_stock_before_insert_venta: Verifica el stock antes de registrar una venta.
create trigger trg_check_stock_before_insert_venta
before insert on detalle_ventas
for each row
begin
	declare v_stock int;

	select stock into v_stock from productos where id_producto = new.id_producto;
	
	if new.cantidad > v_stock then
	signal sqlstate "45000"
	set message_text= "stock insuficiente verifica la cantidad y el stock disponible";
	end if;
end //

-- 3. trg_update_stock_after_insert_venta: Decrementa el stock después de una venta.
create trigger trg_update_stock_after_insert_venta
after insert on detalle_ventas
for each row
begin
	UPDATE productos SET stock = stock - NEW.cantidad
	WHERE id_producto = NEW.id_producto;
end // 


-- 4. trg_prevent_delete_categoria_with_products: Impide eliminar una categoría si tiene productos asociados.
CREATE TRIGGER trg_prevent_delete_categoria_with_products
BEFORE DELETE ON categorias
FOR EACH ROW
BEGIN
    DECLARE v_cantidad INT;
    SELECT COUNT(*)
    INTO v_cantidad
    FROM productos
    WHERE id_categoria = old.id_categoria;

    IF  v_cantidad > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar la categoria porque tiene productos asociados';
    END IF;
end //


-- 5. trg_log_new_customer_after_insert: Registra en una tabla de auditoría cada vez que se crea un nuevo cliente


create trigger trg_log_new_customer_after_insert
after insert on clientes
for each row
begin
	insert into auditoria_clientes (id_cliente, nombres, apellidos, email, fecha_registro)
	values (new.id_cliente, new.nombres, new.apellidos, new.email, now());
end //
-- 6. trg_update_total_gastado_cliente: Actualiza un campo total_gastado en la tabla clientes después de cada compra.
create trigger trg_update_total_gastado_cliente
after insert on ventas
for each row
begin
	update clientes set total_gastado = ifnull(total_gastado,0) + new.total
	where id_cliente = new.id_cliente;
end // 

-- 7. trg_set_fecha_modificacion_producto: Actualiza automáticamente la fecha de última modificación de un producto.
create trigger trg_set_fecha_modificacion_producto 
before update on productos
for each row
begin
	set new.fecha_modificacion = now();
end //

-- 8. trg_prevent_negative_stock: Impide que el stock de un producto se actualice a un valor negativo.
create trigger trg_prevent_negative_stock
before update on productos
for each row
begin
	if new.stock < 0 then 
	signal sqlstate "45000"
	set message_text = "el stock que quieres ingresar debe ser mayor de 0 y no negativo";
	end if;
end //

-- 9. trg_capitalize_nombre_cliente: Convierte a mayúscula la primera letra del nombre y apellido de un cliente al insertarlo.
create trigger trg_capitalize_nombre_cliente
before insert on clientes
for each row
begin
	set new.nombres = concat(upper(left(new.nombres,1)), lower(substring(new.nombres,2)));
	set new.apellidos = concat(upper(left(new.apellidos,1)), lower(substring(new.apellidos,2)));
end //

-- 10. trg_recalculate_total_venta_on_detalle_change: Recalcula el total en la tabla ventas si se modifica un detalle_venta.
CREATE TRIGGER trg_recalculate_total_venta_on_detalle_change
AFTER UPDATE ON detalle_ventas
FOR EACH ROW
BEGIN

    DECLARE v_total DECIMAL(12,2);

    SELECT SUM(cantidad * precio_unitario_congelado)
    INTO v_total
    FROM detalle_ventas
    WHERE id_venta = NEW.id_venta;

    UPDATE ventas
    SET total = v_total
    WHERE id_venta = NEW.id_venta;
END 

delimiter ;