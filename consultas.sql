
-- =======================================================
-- 				CONSULTAS AVANZADAS
-- =======================================================

-- 1. Top 10 Productos Más Vendidos: Generar un ranking con los 10 productos que han generado más ingresos.

select p.nombre, sum(dv.cantidad * dv.precio_unitario_congelado) as ingreso_totales from productos p  join detalle_ventas dv
on p.id_producto = dv.id_producto join ventas v on v.id_venta= dv.id_venta where v.estado != "Cancelado" 
group by p.nombre order by ingreso_totales desc limit 10;


-- 2. Productos con Bajas Ventas: Identificar los productos en el 10% inferior de ventas para considerar su descontinuación

SELECT CEIL(COUNT(*) * 0.10)
FROM productos;


SELECT
    p.nombre,
    ifnull(SUM(dv.cantidad),0) AS cantidad_vendida
FROM productos p
left JOIN detalle_ventas dv
    ON p.id_producto = dv.id_producto
left join ventas v
	on v.id_venta = dv.id_venta 
	and v.estado != "Cancelado"
GROUP BY p.nombre
ORDER by cantidad_vendida asc
limit 1;



-- 3. Clientes VIP: Listar los 5 clientes con el mayor valor de vida (LTV), basado en su gasto total histórico.

select c.nombres,sum(v.total) as total_gastado from clientes c join ventas v on v.id_cliente = c.id_cliente
where v.estado != "Cancelado" group by c.nombres 
order by total_gastado desc limit 5;

-- 4. Análisis de Ventas Mensuales: Mostrar las ventas totales agrupadas por mes y año

select year(fecha_venta) as anio, month(fecha_venta) as mes, sum(total) as total_ventas from ventas 
where estado != "Cancelado" group by anio, mes order by anio, mes;

-- 5. Crecimiento de Clientes: Calcular el número de nuevos clientes registrados por trimestre.
select year(fecha_registro) as anio,QUARTER(fecha_registro) as trimestre , count(*) as nuevos_clientes from clientes 
group by anio,trimestre order by trimestre;

-- 6. Tasa de Compra Repetida: Determinar qué porcentaje de clientes ha realizado más de una compra.

SELECT
    (
        SELECT COUNT(*)
        FROM (
            SELECT id_cliente
            FROM ventas
            WHERE estado != 'Cancelado'
            GROUP BY id_cliente
            HAVING COUNT(id_venta) > 1
        ) AS repetidos
    )
    /
    (
        SELECT COUNT(DISTINCT id_cliente)
        FROM ventas
        WHERE estado != 'Cancelado'
    )
    * 100 AS tasa_recompra;

-- 7. Productos Comprados Juntos Frecuentemente: Identificar pares de productos que a menudo se compran en la misma transacción.

SELECT
    p1.nombre AS producto_1,
    p2.nombre AS producto_2,
    COUNT(*) AS veces_juntos
FROM detalle_ventas d1
JOIN detalle_ventas d2
    ON d1.id_venta = d2.id_venta
    AND d1.id_producto < d2.id_producto
JOIN productos p1
    ON p1.id_producto = d1.id_producto
JOIN productos p2
    ON p2.id_producto = d2.id_producto
join ventas v
	on v.id_venta = d1.id_venta 
where v.estado != "Cancelado"
GROUP BY p1.nombre, p2.nombre
order by veces_juntos desc;

-- 8. Rotación de Inventario: Calcular la tasa de rotación de stock para cada categoría de producto
select
    c.nombre as categoria,
    sum(p.stock) as stock_actual,
   sum(ifnull(ventas_producto.unidades_vendidas, 0)) as total_unidades_vendidas,
    round(
        sum(ventas_producto.unidades_vendidas) / sum(p.stock),
        2
    ) as rotacion
from categorias c
join productos p
    on p.id_categoria = c.id_categoria
left join (
    select
        dv.id_producto,
        sum(dv.cantidad) as unidades_vendidas
    from detalle_ventas dv
    join ventas v
        on v.id_venta = dv.id_venta
    where v.estado != 'Cancelado'
    group by dv.id_producto
) as ventas_producto
    on ventas_producto.id_producto = p.id_producto
group by c.nombre;



-- 9. Productos que Necesitan Reabastecimiento: Listar productos cuyo stock actual está por debajo de su umbral mínimo.

select nombre, stock, stock_minimo from productos where stock<stock_minimo;

-- 10. Análisis de Carrito Abandonado (Simulado): Identificar clientes que agregaron productos pero no completaron una venta en un período determinado.

select c.nombres,ca.id_carrito, ca.fecha_creacion, ca.estado, dc.cantidad from clientes c join carritos ca on c.id_cliente = ca.id_cliente
join detalle_carrito dc on ca.id_carrito = dc.id_carrito
where ca.estado= "Abandonado" and ca.fecha_creacion BETWEEN '2026-09-01 00:00:00' AND '2026-09-12 23:59:59';

-- 11. Rendimiento de Proveedores: Clasificar a los proveedores según el volumen de ventas de sus productos.

select pr.nombre, sum(dv.cantidad) as volumen_ventas from productos p join detalle_ventas dv on p.id_producto = dv.id_producto 
join proveedores pr on p.id_proveedor = pr.id_proveedor 
join ventas v on dv.id_venta = v.id_venta 
where v.estado != "Cancelado"
group by pr.nombre
order by volumen_ventas desc;

-- 12. Análisis Geográfico de Ventas: Agrupar las ventas por ciudad o región del cliente.

select c.ciudad, sum(v.total) as ventas  from clientes c join ventas v on v.id_cliente = c.id_cliente where v.estado != "Cancelado" group by c.ciudad order by ventas desc;

-- 13. Ventas por Hora del Día: Determinar las horas pico de compras para optimizar campañas de marketing.

select HOUR(fecha_venta ) as hora, count(id_venta) as cantidad_venta from ventas where estado != "Cancelado" group by hora order by cantidad_venta desc;

-- 14. Impacto de Promociones: Comparar las ventas de un producto antes, durante y después de una campaña de descuento.

select p.nombre,case when v.fecha_venta< pr.fecha_inicio then "Antes" when v.fecha_venta between pr.fecha_inicio and pr.fecha_fin then "Durante"
else "Despues"end as periodo,sum(dv.cantidad) as total_unidades from productos p join promociones pr on pr.id_producto = p.id_producto 
join detalle_ventas dv on dv.id_producto = p.id_producto 
join ventas v on v.id_venta = dv.id_venta where v.estado != "Cancelado" and pr.id_promocion = 1
group by p.nombre, periodo;



-- 15. Análisis de Cohort: Analizar la retención de clientes mes a mes desde su primera compra.


-- pruebas
select cohorte.mes_inicio, month(v.fecha_venta) - cohorte.mes_inicio as meses_desde_inicio, count(distinct cohorte.id_cliente) as clientes from (select id_cliente,MONTH(MIN(fecha_venta)) AS mes_inicio FROM ventas GROUP BY id_cliente) as cohorte
join ventas v on cohorte.id_cliente = v.id_cliente group by cohorte.mes_inicio,meses_desde_inicio;

SELECT
    mes_inicio,
    COUNT(*) AS clientes_iniciales
FROM (
  SELECT 
    id_cliente,
    DATE_FORMAT(MIN(fecha_venta), "%Y-%m") AS mes_inicio
FROM ventas
GROUP BY id_cliente
) AS cohorte
GROUP BY mes_inicio;


-- la real REPA


SELECT
    actividad.mes_inicio,
    actividad.meses_desde_inicio,
    actividad.clientes,
    iniciales.clientes_iniciales,
    ROUND(
        actividad.clientes / iniciales.clientes_iniciales * 100,
        2
    ) AS porcentaje_retencion
FROM (
    SELECT
        cohorte.mes_inicio,
        TIMESTAMPDIFF(
            MONTH,
            cohorte.mes_inicio,
            v.fecha_venta
        ) AS meses_desde_inicio,
        COUNT(DISTINCT cohorte.id_cliente) AS clientes
    FROM (
        SELECT
            id_cliente,
            DATE_FORMAT(
                MIN(fecha_venta),
                '%Y-%m-01'
            ) AS mes_inicio
        FROM ventas
        WHERE estado != 'Cancelado'
        GROUP BY id_cliente
    ) AS cohorte
    JOIN ventas v
        ON cohorte.id_cliente = v.id_cliente
    WHERE v.estado != 'Cancelado'
    GROUP BY
        cohorte.mes_inicio,
        meses_desde_inicio
) AS actividad
JOIN (
    SELECT
        mes_inicio,
        COUNT(*) AS clientes_iniciales
    FROM (
        SELECT
            id_cliente,
            DATE_FORMAT(
                MIN(fecha_venta),
                '%Y-%m-01'
            ) AS mes_inicio
        FROM ventas
        WHERE estado != 'Cancelado'
        GROUP BY id_cliente
    ) AS cohorte
    GROUP BY mes_inicio
) AS iniciales
ON actividad.mes_inicio = iniciales.mes_inicio
ORDER BY
    actividad.mes_inicio,
    actividad.meses_desde_inicio;


-- 16. Margen de Beneficio por Producto: Calcular el margen de beneficio para cada producto (requiere añadir un campo costo a la tabla productos).

select p.nombre, sum((dv.precio_unitario_congelado- p.costo)*dv.cantidad) as beneficio_venta, round(sum((dv.precio_unitario_congelado- p.costo)*dv.cantidad)
/sum(dv.precio_unitario_congelado * dv.cantidad)*100,2) as margen_beneficio
from productos p join detalle_ventas dv on dv.id_producto = p.id_producto join ventas v on v.id_venta = dv.id_venta
where v.estado != "Cancelado" group by p.nombre order by beneficio_venta desc; 

-- 17. Tiempo Promedio Entre Compras: Calcular el tiempo medio que tarda un cliente en volver a comprar.

-- prueba
SELECT
    id_cliente,
    fecha_venta,
    LAG(fecha_venta) OVER (
        PARTITION BY id_cliente
        ORDER BY fecha_venta
    ) AS fecha_anterior,
        DATEDIFF(
        fecha_venta,
        LAG(fecha_venta) OVER (
            PARTITION BY id_cliente
            ORDER BY fecha_venta
        )
    ) AS dias_entre_compras
FROM ventas;

-- real
SELECT
    id_cliente,
    ifnull(AVG(dias_entre_compras),0) AS promedio_dias
FROM (
    SELECT
        id_cliente,
        DATEDIFF(
            fecha_venta,
            LAG(fecha_venta) OVER (
                PARTITION BY id_cliente
                ORDER BY fecha_venta
            )
        ) AS dias_entre_compras
    FROM ventas where estado != "Cancelado"
) AS tiempos
GROUP BY id_cliente;

-- 18. Productos Más Vistos vs. Comprados: Comparar los productos más visitados con los más comprados.

-- pruebas
select p.nombre, count(vp.fecha_vista) as total_visitas from productos p join vistas_productos vp 
on vp.id_producto = p.id_producto group by p.nombre;

select p.nombre, sum(dv.cantidad ) as cantidad_unidades from productos p join detalle_ventas dv 
on p.id_producto = dv.id_producto group by p.nombre;

-- real 
select vistas.nombre, vistas.total_visitas, compras.total_compras , ROUND(compras.total_compras  / vistas.total_visitas* 100,2)
as porcentaje_conversion
from (
	select p.id_producto, p.nombre,count(vp.fecha_vista) as total_visitas 
	from productos p join vistas_productos vp on vp.id_producto = p.id_producto 
	group by p.id_producto, p.nombre) as vistas
join (select p.id_producto, p.nombre, COUNT(dv.id_detalle) AS total_compras  
	from productos p join detalle_ventas dv on dv.id_producto =p.id_producto
	join ventas v on v.id_venta = dv.id_venta where v.estado != "Cancelado"
	group by p.id_producto, p.nombre) as compras
	on vistas.id_producto = compras.id_producto; 

-- 19. Segmentación de Clientes (RFM): Clasificar a los clientes en segmentos (Recencia, Frecuencia, Monetario).

-- La estructura de la RFM = recency, frequency, monetary
select id_cliente, max(fecha_venta) as ultima_compra ,DATEDIFF("2026-08-31",max(fecha_venta))as recency from ventas where estado != "Cancelado" group by id_cliente;

select id_cliente ,count(id_venta) as frequency from  ventas where estado != "Cancelado" group by id_cliente;

select id_cliente,SUM(total) AS monetary FROM ventas WHERE estado != 'Cancelado' GROUP BY id_cliente;

select id_cliente, DATEDIFF("2026-08-31", max(fecha_venta)) as recency, count(id_venta) as frequency, 
sum(total) as monetary from ventas where estado != "Cancelado" group by id_cliente ;

-- 20. Predicción de Demanda Simple: Utilizar datos de ventas pasadas para proyectar las ventas del próximo mes para una categoría específica.
-- prueba
select p.nombre, MONTH(v.fecha_venta) as mes, sum(dv.cantidad) as unidades_vendidas from productos p join detalle_ventas dv 
on dv.id_producto = p.id_producto join ventas v on v.id_venta = dv.id_venta group by p.nombre, mes;

-- real
select categoria,avg(unidades_vendidas)  as demanda_promedio from 
(select c.nombre as categoria,MONTH(v.fecha_venta) AS mes, sum(dv.cantidad) as unidades_vendidas from categorias c 
join productos p  on p.id_categoria  = c.id_categoria join detalle_ventas dv  on dv.id_producto = p.id_producto 
join ventas v on v.id_venta = dv.id_venta where v.estado != "Cancelado" and c.nombre = "Perifericos"
 group by c.nombre,mes) as ventas_mensuales group by categoria;