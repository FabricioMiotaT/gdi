PROCEDIMIENTOS EN PG ADMIN

1 Estudiantes con Deudas
    CREATE OR REPLACE FUNCTION obtener_estudiantes_con_deudas()
    RETURNS TABLE(
        codigo INT, 
        apellido VARCHAR, 
        nombres VARCHAR, 
        dni VARCHAR, 
        correo_institucional VARCHAR, 
        deudas_pendientes BOOLEAN
    ) AS $$
    BEGIN
        RETURN QUERY 
        SELECT 
            mae_estudiante.codigo, 
            mae_estudiante.apellido, 
            mae_estudiante.nombres, 
            mae_estudiante.dni, 
            mae_estudiante.correo_institucional, 
            mae_estudiante.deudas_pendientes
        FROM mae_estudiante
        WHERE mae_estudiante.deudas_pendientes = TRUE;
    END;
    $$ LANGUAGE plpgsql;

2 Obtener Creditos totales
    CREATE OR REPLACE FUNCTION obtener_creditos_totales()
    RETURNS TABLE(
        estudiante_id INT, 
        nombre VARCHAR, 
        apellido VARCHAR, 
        total_creditos INT
    ) AS $$
    BEGIN
        RETURN QUERY 
        SELECT 
            e.codigo AS estudiante_id, 
            e.nombres AS nombre, 
            e.apellido AS apellido, 
            COALESCE(SUM(m.creditos), 0)::INT AS total_creditos
        FROM mae_estudiante e
        LEFT JOIN mae_matricula m ON e.codigo = m.cod_estudiante
        GROUP BY e.codigo, e.nombres, e.apellido
        ORDER BY total_creditos DESC;
    END;
    $$ LANGUAGE plpgsql;
3

4 Listar Entes Rectores
    CREATE OR REPLACE FUNCTION listar_entes_rectores()
    RETURNS TABLE(
        codigo INT, 
        nombres VARCHAR, 
        apellidos VARCHAR, 
        cargo VARCHAR, 
        area VARCHAR
    ) AS $$
    BEGIN
        RETURN QUERY 
        SELECT 
            mae_ente_rector.codigo, 
            mae_ente_rector.nombres, 
            mae_ente_rector.apellidos, 
            mae_ente_rector.cargo, 
            mae_ente_rector.area
        FROM mae_ente_rector;
    END;
    $$ LANGUAGE plpgsql;

5 Agregar este registro para probar
  INSERT INTO mae_estudiante (apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes)
VALUES ('López', 'Andrea', '12345679', 'Ingeniería Ambiental', 'alopez@univ.edu', FALSE);

