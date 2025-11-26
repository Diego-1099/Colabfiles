/*

Actividad: Control de transacciones en MySQL - Caso Ana
Diego Jaziel Olmos Aguilera
Descripción: Simulación de compra exitosa (COMMIT).

*/

USE tienda_ida;

-- 1. Iniciar la transacción
START TRANSACTION;

-- 2. Verificación de stock
-- Usamos FOR UPDATE para asegurar que nadie modifique el stock mientras leemos
SELECT stock, precio FROM productos WHERE id = 1 FOR UPDATE;

-- 3. Procesamiento de la orden (Stock suficiente: 5 >= 3)
-- Insertamos la orden de Ana
INSERT INTO ordenes (cliente, producto_id, cantidad, total, estado) 
VALUES ('Ana', 1, 3, 3600.00, 'Confirmada');

-- Descontamos el stock del producto
UPDATE productos 
SET stock = stock - 3 
WHERE id = 1;

-- 4. Confirmación de cambios
-- El stock baja a 2 y la venta se guarda permanentemente.
COMMIT;

-- 5. Verificación de resultados
-- Esperado: Stock = 2, Orden de Ana registrada.
SELECT * FROM productos;
SELECT * FROM ordenes;
