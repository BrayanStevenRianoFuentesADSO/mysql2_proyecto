-- =======================================================
-- 				creacion de usuarios
-- =======================================================

create user 'admin_user'@'localhost'
identified by 'admin123';

create user 'marketing_user'@'localhost'
identified by 'marketing123';

create user  'inventory_user'@'localhost'
identified by 'inventory123';

create user 'support_user'@'localhost'
identified by 'support123';

create user 'analist_data'@'localhost'
identified by 'analist123'
with
MAX_QUERIES_PER_HOUR 100;

-- =======================================================
-- 				creacion de roles
-- =======================================================

create role 'Administrador_Sistema';

create role 'Gerente_Marketing';
 
create role 'Analista_Datos';

create role 'Empleado_Inventario';

create role 'Atencion_Cliente';

create role 'Auditor_Financiero';

create role 'Visitante';

-- =======================================================
-- 				asignar usuarios a los roles
-- =======================================================

grant 'Administrador_Sistema' to 'admin_user'@'localhost';
grant 'Gerente_Marketing' to 'marketing_user'@'localhost';
grant 'Empleado_Inventario' to 'inventory_user'@'localhost';
grant 'Atencion_Cliente' to 'support_user'@'localhost';
grant 'Analista_Datos' to 'analist_data'@'localhost';


-- =======================================================
--                  ROLES POR DEFECTO
-- =======================================================

SET DEFAULT ROLE 'Administrador_Sistema'
TO 'admin_user'@'localhost';

SET DEFAULT ROLE 'Gerente_Marketing'
TO 'marketing_user'@'localhost';

SET DEFAULT ROLE 'Empleado_Inventario'
TO 'inventory_user'@'localhost';

SET DEFAULT ROLE 'Atencion_Cliente'
TO 'support_user'@'localhost';

set default role 'Analista_Datos'
to 'analist_data'@'localhost';
-- =======================================================
-- 				asignar privilegios a los roles
-- =======================================================

grant all privileges on Ecommerce.* to 'Administrador_Sistema';

grant select on Ecommerce.ventas to 'Gerente_Marketing';
grant select on  Ecommerce.clientes to 'Gerente_Marketing';

grant select on ecommerce.* to 'Analista_Datos';
revoke select on ecommerce.auditoria from 'Analista_Datos'; -- esperar hasta saber cuantas tablas de auditoria se requieren

grant update (stock, ubicacion) on ecommerce.productos to 'Empleado_Inventario';

grant select on  ecommerce.v_info_clientes_basica to 'Atencion_Cliente'; 
-- cambie el grant select on  ecommerce.cliente to 'Atencion_Cliente'; ya que si lo dejaba asi mostraria toda la tabla 
-- incluyendo datos sencibles para el cliente

grant select on ecommerce.ventas to 'Atencion_Cliente';

grant select on ecommerce.ventas to 'Auditor_Financiero';
grant select on ecommerce.productos to 'Auditor_Financiero';
grant select on ecommerce.logs_precio to 'Auditor_Financiero'; -- pendiente la tabla de logs_precio
-- 17. crear rol visitante
grant select on ecommerce.productos to 'Visitante'; 
-- 1-10 terminados
-- =======================================================
-- 			otros permisos y seguridad
-- =======================================================
-- 11 ya con los privilegios le quito la opcion de delete para el rol de analista_datos
-- ya que solo hace select

-- 12.pendiente hasta crear procedimiento reporte marketing

-- 13. v_info_clientes_basica y colocarlo a atencion al cliente
create view v_info_clientes_basica as
select
id_cliente,
nombres,
apellidos,
fecha_registro,
email
from clientes;


-- 15. ADVERTENCIA: pendiente
-- Implementar politica de contraseÃ±as seguras para todos los usuarios.
-- validate_password no se encuentra habilitado actualmente.


-- 16. verificar que root solo pueda usarse localmente
select user, host
from mysql.user
where user = 'root';