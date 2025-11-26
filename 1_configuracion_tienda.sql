/*

Actividad: Control de transacciones en MySQL
Diego Jaziel Olmos Aguilera
Descripción: Creación de BD, tablas y carga inicial.

*/
-- ==========================================================
-- Configuración Inicial de la Tienda
-- ==========================================================

-- 1. Crear base de datos
DROP DATABASE IF EXISTS tienda_ida;
CREATE DATABASE tienda_ida;
USE tienda_ida;

-- 2. Definición de Tablas (Motor InnoDB)

-- Tabla productos: Inventario disponible
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    stock INT,
    precio DECIMAL(10,2)
) ENGINE=InnoDB;

-- Tabla ordenes: Registro de ventas
CREATE TABLE ordenes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente VARCHAR(50),
    producto_id INT,
    cantidad INT,
    total DECIMAL(10,2),
    estado VARCHAR(20),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
) ENGINE=InnoDB;

-- 3. Carga de datos iniciales
-- Insertamos el producto 'Laptop' con 5 unidades y precio 1200.00
INSERT INTO productos (nombre, stock, precio) 
VALUES ('Laptop', 5, 1200.00);

-- 4. Verificación
-- Mostramos el estado inicial del inventario
SELECT * FROM productos;