-- =============================================
-- Pre-entrega 4: Consultas SQL de negocio
-- Autora: Ambar Caucigh
-- Motor utilizado: SQL Server 2025 Express
-- Base: Ventas_Tech_DB (creada en M3)
-- =============================================

USE Ventas_Tech_DB;
GO

-- === CONSULTA 1: Resumen ejecutivo mensual ===
-- Total facturado, cantidad de pedidos y ticket promedio por mes
SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- === CONSULTA 2: Ranking de productos (Top 5) ===
-- Productos con mayor facturación, con unidades vendidas
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- === CONSULTA 3: Clientes recurrentes ===
-- Clientes con más de un pedido, cantidad de pedidos y total gastado
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- === CONSULTA 4: Productos por encima / por debajo del promedio ===
-- Se calcula primero el total por producto (WITH) y luego se compara
-- cada total contra el promedio de esos totales (no de las filas de ventas)
WITH facturacion_por_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_por_producto)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM facturacion_por_producto
ORDER BY total_facturado DESC;

-- =============================================
-- HALLAZGOS
-- =============================================
-- 1. El producto 1 es el que más factura (3600.00), aunque vendió solo
--    3 unidades. Es un producto de ticket alto: el producto 2 tuvo la misma
--    cantidad de pedidos y vendió 13 unidades, pero facturó apenas 364.00.
-- 2. Los productos 1 y 3 son los únicos que tienen una facturación por
--    encima del promedio por producto; los otros 4 quedan por debajo.
-- 3. Los 5 clientes realizaron 2 pedidos cada uno, es decir, todos son
--    clientes recurrentes. Los clientes 1 y 5 son los que más gastaron
--    (2640.00 y 2100.00).

