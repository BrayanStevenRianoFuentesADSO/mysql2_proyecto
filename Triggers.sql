-- =======================================================
-- 				Creacion de los triggers
-- =======================================================

delimiter //
-- 1. trg_audit_precio_producto_after_update: Guarda un log de cambios de precios.
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

-- 3,trg_update_stock_after_insert_venta: Decrementa el stock después de una venta.
create trigger trg_update_stock_after_insert_venta
after insert on detalle_ventas
for each row
begin
	UPDATE productos SET stock = stock - NEW.cantidad
	WHERE id_producto = NEW.id_producto;
end // 


delimiter ;