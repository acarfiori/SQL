-- USE master;
-- GO
-- Creación de la base de datos
	CREATE DATABASE Refaccion;
	USE Refaccion;

-- Tabla: Proyectos
	CREATE TABLE Proyectos (
    ID_Proyecto INT PRIMARY KEY,
    Nombre_Proyecto VARCHAR(100) NOT NULL,
    Fecha_Inicio DATE NOT NULL,
    Fecha_Fin_Estimada DATE NOT NULL,
    Fecha_Fin_Real DATE,
    Costo_Total_Estimado DECIMAL(10, 2),
    Costo_Total_Real DECIMAL(10, 2),
    Diferencia_Tiempo_Días INT,
    Diferencia_Costo DECIMAL(10, 2),
    Estado VARCHAR(50)
	);

-- Tabla: Computo_Materiales
CREATE TABLE Computo_Materiales (
    ID_Material INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Cantidad_Necesaria VARCHAR(100) NOT NULL,
    Precio_Unitario DECIMAL(10, 2) NOT NULL,
    Costo_Total_Estimado DECIMAL(10, 2) NOT NULL,
    ID_Proyecto INT NOT NULL,
    FOREIGN KEY (ID_Proyecto) REFERENCES Proyectos(ID_Proyecto)
        ON DELETE CASCADE ON UPDATE CASCADE
	);

-- Tabla: Computo_Mano_de_Obra
	CREATE TABLE Computo_Mano_de_Obra (
    ID_Mano_Obra INT PRIMARY KEY,
    Especialidad VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255),
    Costo_Estimado DECIMAL(10, 2) NOT NULL,
    ID_Proyecto INT NOT NULL,
    FOREIGN KEY (ID_Proyecto) REFERENCES Proyectos(ID_Proyecto)
        ON DELETE CASCADE ON UPDATE CASCADE
	);

-- Tabla: Gastos_Ahorros
	CREATE TABLE Gastos_Ahorros (
    ID_Registro INT PRIMARY KEY,
    Fecha DATE NOT NULL,
    Tipo_Registro VARCHAR(50) NOT NULL,
    Categoria VARCHAR(100),
    Descripcion VARCHAR(255),
    Monto DECIMAL(10, 2) NOT NULL,
    ID_Proyecto INT,
    FOREIGN KEY (ID_Proyecto) REFERENCES Proyectos(ID_Proyecto)
        ON DELETE CASCADE ON UPDATE CASCADE
	);

-- Tabla: Inspecciones
CREATE TABLE Inspecciones (
    ID_Inspeccion INT PRIMARY KEY,
    ID_Proyecto INT,
    Fecha DATE NOT NULL,
    Responsable VARCHAR(100) NOT NULL,
    Observaciones VARCHAR(100),
    Estado VARCHAR(50),
    CONSTRAINT FK_Inspecciones_Proyectos FOREIGN KEY (ID_Proyecto) REFERENCES Proyectos(ID_Proyecto)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Importo desde Csv

-- Tabla Proyectos
BULK INSERT Proyectos
FROM 'C:\Users\sperl\Documents\Carla\Refaccion\Proyectos.csv'
WITH 
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 
);
-- Verifico Datos
SELECT * FROM Proyectos;

-- Tabla Computo Materiales
BULK INSERT Computo_Materiales
FROM 'C:\Users\sperl\Documents\Carla\Refaccion\Computo_Materiales.csv'
WITH 
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 
);
-- Verifico Datos
SELECT * FROM Computo_Materiales;

-- Tabla Computo Mano de Obra
BULK INSERT Computo_Mano_de_Obra
FROM 'C:\Users\sperl\Documents\Carla\Refaccion\Computo_Mano_Obra.csv'
WITH 
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 
);
-- Verifico Datos
SELECT * FROM Computo_Mano_de_Obra;

-- Tabla Gastos_Ahorros
BULK INSERT Gastos_Ahorros
FROM 'C:\Users\sperl\Documents\Carla\Refaccion\Gastos_Ahorros.csv'
WITH 
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 
);
-- Verifico Datos
SELECT * FROM Gastos_Ahorros;

-- Tabla Inspecciones
BULK INSERT Inspecciones
FROM 'C:\Users\sperl\Documents\Carla\Refaccion\Inspecciones.csv'
WITH 
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 
);
-- Verifico Datos
SELECT * FROM Inspecciones;

-- Script de Vistas, Funciones, Stored Procedures y Triggers.

-- 1.Vista: Gastos por Proyecto
CREATE VIEW Vista_Gastos_Proyecto AS
SELECT 
    ga.ID_Proyecto,
    p.Nombre_Proyecto,
    SUM(CASE WHEN ga.Tipo_Registro = 'Gasto' THEN ga.Monto ELSE 0 END) AS Total_Gastado,
    SUM(CASE WHEN ga.Tipo_Registro = 'Ahorro' THEN ga.Monto ELSE 0 END) AS Total_Ahorrado
FROM Gastos_Ahorros ga
JOIN Proyectos p ON ga.ID_Proyecto = p.ID_Proyecto
GROUP BY ga.ID_Proyecto, p.Nombre_Proyecto;

-- 2. Vista: Costo total de Mano de Obra por Proyecto
CREATE VIEW Vista_Costo_Mano_Obra_Proyecto AS
SELECT 
    cmo.ID_Proyecto,
    p.Nombre_Proyecto,
    SUM(cmo.Costo_Estimado) AS Costo_Total_Mano_Obra
FROM Computo_Mano_de_Obra cmo
JOIN Proyectos p ON cmo.ID_Proyecto = p.ID_Proyecto
GROUP BY cmo.ID_Proyecto, p.Nombre_Proyecto;

-- 3. Vista: Costo total de Materiales por Proyecto
CREATE VIEW Vista_Costo_Materiales_Proyecto AS
SELECT 
    cm.ID_Proyecto,
    p.Nombre_Proyecto,
    SUM(cm.Costo_Total_Estimado) AS Costo_Total_Materiales
FROM Computo_Materiales cm
JOIN Proyectos p ON cm.ID_Proyecto = p.ID_Proyecto
GROUP BY cm.ID_Proyecto, p.Nombre_Proyecto;

-- 4. Función: Calcular diferencia de costos
CREATE FUNCTION Calcular_Diferencia_Costo(@id_proyecto INT) 
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Diferencia DECIMAL(10,2);
    SELECT @Diferencia = (Costo_Total_Real - Costo_Total_Estimado)
    FROM Proyectos WHERE ID_Proyecto = @id_proyecto;
    RETURN @Diferencia;
END;


-- 5. Función: Calcular duración real de un proyecto
CREATE FUNCTION Calcular_Duracion_Proyecto(@id_proyecto INT) 
RETURNS INT
AS
BEGIN
    DECLARE @Duracion INT;
    SELECT @Duracion = DATEDIFF(DAY, Fecha_Inicio, Fecha_Fin_Real)
    FROM Proyectos WHERE ID_Proyecto = @id_proyecto;
    RETURN @Duracion;
END;

-- 6. Trigger: Evitar que un gasto supere el costo estimado del proyecto
CREATE TRIGGER tr_Limitar_Gastos 
ON Gastos_Ahorros
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Proyectos p ON i.ID_Proyecto = p.ID_Proyecto
        WHERE i.Tipo_Registro = 'Gasto' AND i.Monto > p.Costo_Total_Estimado
    )
    BEGIN
        RAISERROR ('El gasto supera el costo total estimado del proyecto.', 16, 1);
        ROLLBACK;
    END;
END;


-- 7. Trigger: Actualizar el Estado del proyecto

CREATE TRIGGER tr_Actualizar_Estado_Proyecto
ON Inspecciones
AFTER INSERT, UPDATE
AS
BEGIN
    -- Actualizamos el estado de los proyectos donde todas las inspecciones están aprobadas
    DECLARE @ID_Proyecto INT;

    -- Obtenemos el ID de proyecto para las filas insertadas o actualizadas
    SELECT @ID_Proyecto = ID_Proyecto FROM inserted;

    -- Verificamos si todas las inspecciones del proyecto están aprobadas
    IF NOT EXISTS (
        SELECT 1
        FROM Inspecciones
        WHERE ID_Proyecto = @ID_Proyecto
        AND Estado != 'Aprobado'
    )
    BEGIN
        -- Si todas están aprobadas, actualizamos el estado del proyecto
        UPDATE Proyectos
        SET Estado = 'Finalizado'
        WHERE ID_Proyecto = @ID_Proyecto;
    END
END;

-- 8. Stored Procedure: Insertar un nuevo proyecto
CREATE PROCEDURE Insertar_Proyecto 
    @Nombre_Proyecto VARCHAR(100), 
    @Fecha_Inicio DATE, 
    @Fecha_Fin_Estimada DATE,
    @Costo_Total_Estimado DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Proyectos (Nombre_Proyecto, Fecha_Inicio, Fecha_Fin_Estimada, Costo_Total_Estimado, Estado)
    VALUES (@Nombre_Proyecto, @Fecha_Inicio, @Fecha_Fin_Estimada, @Costo_Total_Estimado, 'En Progreso');
END;

-- 9. Stored Procedure: Obtener detalles de un proyecto
CREATE PROCEDURE Obtener_Detalles_Proyecto 
    @ID_Proyecto INT
AS
BEGIN
    SELECT * FROM Proyectos WHERE ID_Proyecto = @ID_Proyecto;
END;