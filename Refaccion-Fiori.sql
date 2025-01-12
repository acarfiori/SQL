-- Creación de la base de datos
	CREATE DATABASE Refaccion;
	USE Refaccion;

-- Tabla: Proyectos
	CREATE TABLE Proyectos (
    ID_Proyecto INT PRIMARY KEY IDENTITY(1,1), --genera un valor
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
    ID_Material INT PRIMARY KEY IDENTITY (1,1),
    Nombre VARCHAR(100) NOT NULL,
    Cantidad_Necesaria DECIMAL(10, 2),
    Precio_Unitario DECIMAL(10, 2) NOT NULL,
    Costo_Total_Estimado DECIMAL(10, 2) NOT NULL,
    ID_Proyecto INT NOT NULL,
    FOREIGN KEY (ID_Proyecto) REFERENCES Proyectos(ID_Proyecto)
        ON DELETE CASCADE ON UPDATE CASCADE
	);

-- Tabla: Computo_Mano_de_Obra
	CREATE TABLE Computo_Mano_de_Obra (
    ID_Mano_Obra INT PRIMARY KEY IDENTITY (1,1),
    Especialidad VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255),
    Costo_Estimado DECIMAL(10, 2) NOT NULL,
    ID_Proyecto INT NOT NULL,
    FOREIGN KEY (ID_Proyecto) REFERENCES Proyectos(ID_Proyecto)
        ON DELETE CASCADE ON UPDATE CASCADE
	);

-- Tabla: Gastos_Ahorros
	CREATE TABLE Gastos_Ahorros (
    ID_Registro INT PRIMARY KEY IDENTITY (1,1),
    Fecha DATE NOT NULL,
    Tipo_Registro VARCHAR(50) NOT NULL,
    Categoria VARCHAR(100),
    Descripcion VARCHAR(255),
    Monto DECIMAL(10, 2) NOT NULL,
    ID_Proyecto INT NOT NULL,
    FOREIGN KEY (ID_Proyecto) REFERENCES Proyectos(ID_Proyecto)
        ON DELETE CASCADE ON UPDATE CASCADE
	);