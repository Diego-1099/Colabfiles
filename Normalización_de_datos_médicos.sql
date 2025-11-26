/*

Actividad práctica: Normalización de datos médicos
Diego Jaziel Olmos Aguilera

*/

-- =====================================================
-- 1. Creación de base de datos
-- =====================================================

DROP DATABASE IF EXISTS normalizacion_medicina;
CREATE DATABASE IF NOT EXISTS normalizacion_medicina
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE normalizacion_medicina;

-- =====================================================
-- 2. Creación de tabla temporal (Data Staging)
-- =====================================================

CREATE TABLE IF NOT EXISTS staging_pacientes (
    id_paciente VARCHAR(10),
    nombre VARCHAR(100),
    telefono VARCHAR(255),
    diagnostico VARCHAR(255),
    medico VARCHAR(100)
);

TRUNCATE TABLE staging_pacientes;

INSERT INTO staging_pacientes (id_paciente, nombre, telefono, diagnostico, medico) VALUES
('P001', 'Ana Torres', '111-111|222-222', 'Diabetes|Hipertensión', 'Dr. López'),
('P002', 'Juan Pérez', '333-333', 'Asma', 'Dra. Ruiz'),
('P003', 'María Gómez', '444-444|555-555', 'Hipertensión|Obesidad', 'Dr. López'),
('P004', 'Luis Fernández', '666-666', 'Diabetes', 'Dr. Torres'),
('P005', 'Laura Martínez', '777-777', 'Hipertensión|Asma', 'Dra. Ruiz'),
('P006', 'Pedro Ramírez', '888-888|999-999', 'Obesidad', 'Dr. López');

SELECT * FROM staging_pacientes;

-- =====================================================
-- 3. Creación de las tablas normalizadas (1FN, 2FN, 3FN)
-- =====================================================

CREATE TABLE paciente (
id_paciente VARCHAR(10) PRIMARY KEY,
nombre VARCHAR(100)
);

CREATE TABLE telefono (
id_telefono INT AUTO_INCREMENT PRIMARY KEY,
id_paciente VARCHAR(10),
telefono VARCHAR(50),
FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
);

CREATE TABLE diagnostico (
id_diagnostico INT AUTO_INCREMENT PRIMARY KEY,
nombre_diagnostico VARCHAR(100) UNIQUE
);

CREATE TABLE paciente_diagnostico (
id_paciente VARCHAR(10),
id_diagnostico INT,
PRIMARY KEY (id_paciente, id_diagnostico),
FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
FOREIGN KEY (id_diagnostico) REFERENCES diagnostico(id_diagnostico)
);

CREATE TABLE medico (
id_medico INT AUTO_INCREMENT PRIMARY KEY,
nombre_medico VARCHAR(100) UNIQUE
);

CREATE TABLE consulta (
id_consulta INT AUTO_INCREMENT PRIMARY KEY,
id_paciente VARCHAR(10),
id_medico INT,
FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);

-- =====================================================
-- 4. Alimentación de las tablas normalizadas
-- =====================================================

INSERT IGNORE INTO paciente (id_paciente, nombre)
SELECT DISTINCT id_paciente, nombre FROM staging_pacientes;

INSERT IGNORE INTO medico(nombre_medico)
SELECT DISTINCT medico FROM staging_pacientes;

INSERT IGNORE INTO consulta (id_paciente, id_medico)
SELECT s.id_paciente, m.id_medico
FROM staging_pacientes s
JOIN medico m ON m.nombre_medico = s.medico;

INSERT IGNORE INTO telefono (id_paciente, telefono)
SELECT DISTINCT id_paciente, TRIM(SUBSTRING_INDEX(telefono, '|', 1)) AS phone
FROM staging_pacientes
WHERE TRIM(SUBSTRING_INDEX(telefono, '|', 1)) <> '';

INSERT IGNORE INTO telefono (id_paciente, telefono)
SELECT DISTINCT id_paciente, TRIM(SUBSTRING_INDEX(telefono, '|', -1)) AS phone
FROM staging_pacientes
WHERE telefono LIKE '%|%';

INSERT IGNORE INTO diagnostico (nombre_diagnostico)
SELECT DISTINCT TRIM(SUBSTRING_INDEX(diagnostico, '|', 1)) AS diag
FROM staging_pacientes
WHERE TRIM(SUBSTRING_INDEX(diagnostico, '|', 1)) <> '';

INSERT IGNORE INTO diagnostico (nombre_diagnostico)
SELECT DISTINCT TRIM(SUBSTRING_INDEX(diagnostico, '|', -1)) AS diag
FROM staging_pacientes
WHERE diagnostico LIKE '%|%';

INSERT IGNORE INTO paciente_diagnostico (id_paciente, id_diagnostico)
SELECT s.id_paciente, d.id_diagnostico
FROM staging_pacientes s
JOIN diagnostico d ON d.nombre_diagnostico = TRIM(SUBSTRING_INDEX(s.diagnostico, '|', 1))
WHERE TRIM(SUBSTRING_INDEX(s.diagnostico, '|', 1)) <> '';

INSERT IGNORE INTO paciente_diagnostico (id_paciente, id_diagnostico)
SELECT s.id_paciente, d.id_diagnostico
FROM staging_pacientes s
JOIN diagnostico d ON d.nombre_diagnostico = TRIM(SUBSTRING_INDEX(s.diagnostico, '|', -1))
WHERE s.diagnostico LIKE '%|%';

-- =====================================================
-- 5. Verificación final de los datos normalizados
-- =====================================================

SELECT * FROM paciente;

SELECT * FROM telefono ORDER BY id_paciente;

SELECT * FROM medico;

SELECT * FROM diagnostico;

SELECT p.id_paciente, p.nombre, d.nombre_diagnostico
FROM paciente p
JOIN paciente_diagnostico pd ON p.id_paciente = pd.id_paciente
JOIN diagnostico d ON pd.id_diagnostico = d.id_diagnostico
ORDER BY p.id_paciente, d.id_diagnostico;

SELECT c.id_consulta, p.nombre AS paciente, m.nombre_medico AS medico
FROM consulta c
JOIN paciente p ON c.id_paciente = p.id_paciente
JOIN medico m ON c.id_medico = m.id_medico
ORDER BY c.id_consulta;

/*
-- =====================================================
-- 6. Explicación de las formas normales aplicadas
-- =====================================================
  
  1. Primera Forma Normal (1FN) - Atomicidad:
     - Problema: Las columnas 'telefono' y 'diagnostico' contenían múltiples 
       valores separados por el delimitador '|'.
     - Solución: Se atomizaron los datos mediante funciones de cadena (SUBSTRING_INDEX),
       moviendo los teléfonos a la tabla 'telefono' y los diagnósticos a 
       'paciente_diagnostico', asegurando un solo valor por celda.

  2. Segunda Forma Normal (2FN) - Dependencia Funcional Total:
     - Problema: Existía redundancia al repetir datos del paciente junto con 
       sus múltiples diagnósticos.
     - Solución: Se aislaron los datos del paciente en su propia tabla. 
       Para la relación paciente-enfermedad, se creó una tabla puente 
       'paciente_diagnostico' que depende de la clave compuesta completa, 
       permitiendo una relación M:N eficiente.

  3. Tercera Forma Normal (3FN) - Dependencia Transitiva:
     - Problema: Los atributos descriptivos (nombre del médico, nombre del diagnóstico) 
       dependían transitivamente de la consulta, no de la llave primaria.
     - Solución: Se crearon catálogos independientes ('medico', 'diagnostico'). 
       La tabla transaccional 'consulta' ahora solo almacena llaves foráneas, 
       evitando anomalías de actualización y redundancia de texto.
*/

