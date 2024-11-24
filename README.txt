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
