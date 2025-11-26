/*

Actividad: Control de transacciones en MySQL - Caso Luis
Diego Jaziel Olmos Aguilera
Descripción: Simulación de compra fallida por falta de stock (ROLLBACK)

*/

USE tienda_ida;

-- 1. Iniciar la transacción
START TRANSACTION;

-- 2. Verificación de stock y bloqueo
-- Stock actual: 2 (después de la compra de Ana). Luis pide 4.
SELECT stock FROM productos WHERE id = 1 FOR UPDATE;

-- 3. Simulación de operaciones (Intento de compra)
-- Insertamos la orden aunque no haya stock suficiente
INSERT INTO ordenes (cliente, producto_id, cantidad, total, estado) 
VALUES ('Luis', 1, 4, 4800.00, 'Pendiente');

-- Intentamos descontar el stock (Resultaría en -2)
UPDATE productos 
SET stock = stock - 4 
WHERE id = 1;

-- VERIFICACIÓN INTERMEDIA 
SELECT * FROM productos WHERE id = 1;

-- 4. Reversión de cambios (ROLLBACK)
-- Al detectar inconsistencia (stock negativo), deshacemos todo.
ROLLBACK;

-- ==========================================================
-- 5. VERIFICACIÓN FINAL
-- ==========================================================

-- 5. Verificación de resultados
-- Esperado: Stock se mantiene en 2. La orden de Luis NO existe.
SELECT * FROM productos;
SELECT * FROM ordenes;
