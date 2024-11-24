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
