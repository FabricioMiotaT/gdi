PGDMP                  
    |            MODELOFISICO2    16.2    16.2 S               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    33253    MODELOFISICO2    DATABASE     �   CREATE DATABASE "MODELOFISICO2" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Peru.1252';
    DROP DATABASE "MODELOFISICO2";
                postgres    false            �            1255    33334 �   actualizar_estudiante(integer, character varying, character varying, character varying, character varying, character varying, boolean)    FUNCTION       CREATE FUNCTION public.actualizar_estudiante(estudiante_id integer, apellido character varying, nombres character varying, dni character varying, escuela_profesional character varying, correo_institucional character varying, deudas_pendientes boolean) RETURNS void
    LANGUAGE plpgsql
    AS $_$
BEGIN
    UPDATE mae_estudiante
    SET
        apellido = $2,
        nombres = $3,
        dni = $4,
        escuela_profesional = $5,
        correo_institucional = $6,
        deudas_pendientes = $7
    WHERE codigo = $1;
END;
$_$;
 �   DROP FUNCTION public.actualizar_estudiante(estudiante_id integer, apellido character varying, nombres character varying, dni character varying, escuela_profesional character varying, correo_institucional character varying, deudas_pendientes boolean);
       public          postgres    false            �            1255    33354    calcular_total_deuda()    FUNCTION       CREATE FUNCTION public.calcular_total_deuda() RETURNS TABLE(estudiante_id integer, nombres character varying, apellido character varying, total_deuda numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        e.codigo AS estudiante_id, 
        e.nombres, 
        e.apellido, 
        CAST(SUM(d.monto) AS NUMERIC) AS total_deuda
    FROM mae_estudiante e
    JOIN mae_deuda d ON e.codigo = d.cod_estudiante
    WHERE d.estado = TRUE
    GROUP BY e.codigo, e.nombres, e.apellido;
END;
$$;
 -   DROP FUNCTION public.calcular_total_deuda();
       public          postgres    false            �            1255    33332    consultar_estudiante(integer)    FUNCTION     �  CREATE FUNCTION public.consultar_estudiante(estudiante_id integer) RETURNS TABLE(codigo integer, apellido character varying, nombres character varying, dni character varying, escuela_profesional character varying, correo_institucional character varying, deudas_pendientes boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM mae_estudiante WHERE codigo = estudiante_id;
END;
$$;
 B   DROP FUNCTION public.consultar_estudiante(estudiante_id integer);
       public          postgres    false            �            1255    33351 (   contar_estudiantes_por_semestre(integer)    FUNCTION     -  CREATE FUNCTION public.contar_estudiantes_por_semestre(semestre integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_estudiantes INT;
BEGIN
    SELECT COUNT(*) INTO total_estudiantes
    FROM mae_matricula
    WHERE nro_semestre = semestre;
    RETURN total_estudiantes;
END;
$$;
 H   DROP FUNCTION public.contar_estudiantes_por_semestre(semestre integer);
       public          postgres    false            �            1255    33331    eliminar_estudiante(integer)    FUNCTION     �   CREATE FUNCTION public.eliminar_estudiante(estudiante_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM mae_estudiante WHERE codigo = estudiante_id;
END;
$$;
 A   DROP FUNCTION public.eliminar_estudiante(estudiante_id integer);
       public          postgres    false            �            1255    33386 '   estudiantes_con_constancias_recientes()    FUNCTION     �  CREATE FUNCTION public.estudiantes_con_constancias_recientes() RETURNS TABLE(estudiante_id integer, nombres character varying, apellidos character varying, dni character varying, constancia_id integer, tipo_de_documento integer, fecha_emision date)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        e.codigo AS estudiante_id,
        e.nombres,
        e.apellido AS apellidos,
        e.dni,
        c.codigo AS constancia_id,
        c.tipo_de_documento,
        c.fecha_de_emision
    FROM mae_estudiante e
    JOIN mae_constancia_de_matricula c ON e.codigo = c.cod_estudiante
    WHERE c.fecha_de_emision >= CURRENT_DATE - INTERVAL '30 days'
    ORDER BY c.fecha_de_emision DESC;
END;
$$;
 >   DROP FUNCTION public.estudiantes_con_constancias_recientes();
       public          postgres    false                        1255    33389 %   estudiantes_con_creditos_acumulados()    FUNCTION     Q  CREATE FUNCTION public.estudiantes_con_creditos_acumulados() RETURNS TABLE(estudiante_id integer, nombres character varying, apellidos character varying, total_creditos bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.codigo AS estudiante_id,
        e.nombres,
        e.apellido AS apellidos,
        COALESCE(SUM(m.creditos), 0) AS total_creditos -- El resultado de SUM es BIGINT
    FROM mae_estudiante e
    LEFT JOIN mae_matricula m ON e.codigo = m.cod_estudiante
    GROUP BY e.codigo, e.nombres, e.apellido
    ORDER BY total_creditos DESC;
END;
$$;
 <   DROP FUNCTION public.estudiantes_con_creditos_acumulados();
       public          postgres    false            �            1255    33383 $   estudiantes_con_deuda_mayor_a_1500()    FUNCTION     K  CREATE FUNCTION public.estudiantes_con_deuda_mayor_a_1500() RETURNS TABLE(estudiante_id integer, nombres character varying, apellido character varying, total_deuda numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        e.codigo AS estudiante_id,
        e.nombres,
        e.apellido,
        CAST(SUM(d.monto) AS NUMERIC) AS total_deuda
    FROM mae_estudiante e
    JOIN mae_deuda d ON e.codigo = d.cod_estudiante
    WHERE d.estado = TRUE
    GROUP BY e.codigo, e.nombres, e.apellido
    HAVING SUM(d.monto) > 1500
    ORDER BY total_deuda DESC;
END;
$$;
 ;   DROP FUNCTION public.estudiantes_con_deuda_mayor_a_1500();
       public          postgres    false                       1255    33387 &   estudiantes_con_matriculas_recientes()    FUNCTION       CREATE FUNCTION public.estudiantes_con_matriculas_recientes() RETURNS TABLE(estudiante_id integer, nombres character varying, apellidos character varying, dni character varying, escuela_profesional character varying, semestre_academico integer, nro_semestre integer, creditos integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.codigo AS estudiante_id,
        e.nombres,
        e.apellido AS apellidos,
        e.dni,
        e.escuela_profesional,
        m.semestre_academico,
        m.nro_semestre,
        m.creditos
    FROM mae_estudiante e
    JOIN mae_matricula m ON e.codigo = m.cod_estudiante
    WHERE m.semestre_academico = (
        SELECT MAX(m2.semestre_academico) 
        FROM mae_matricula m2
    )
    ORDER BY m.nro_semestre DESC;
END;
$$;
 =   DROP FUNCTION public.estudiantes_con_matriculas_recientes();
       public          postgres    false            �            1255    33385 $   estudiantes_con_numero_constancias()    FUNCTION     ,  CREATE FUNCTION public.estudiantes_con_numero_constancias() RETURNS TABLE(estudiante_id integer, nombres character varying, apellido character varying, total_constancias bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        e.codigo AS estudiante_id,
        e.nombres,
        e.apellido,
        COUNT(c.codigo) AS total_constancias
    FROM mae_estudiante e
    LEFT JOIN mae_constancia_de_matricula c ON e.codigo = c.cod_estudiante
    GROUP BY e.codigo, e.nombres, e.apellido
    ORDER BY total_constancias DESC;
END;
$$;
 ;   DROP FUNCTION public.estudiantes_con_numero_constancias();
       public          postgres    false            �            1255    33356    estudiantes_sin_matricula()    FUNCTION     �  CREATE FUNCTION public.estudiantes_sin_matricula() RETURNS TABLE(codigo integer, apellido character varying, nombres character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        e.codigo, 
        e.apellido, 
        e.nombres
    FROM mae_estudiante e
    LEFT JOIN mae_matricula m ON e.codigo = m.cod_estudiante
    WHERE m.codigo IS NULL;
END;
$$;
 2   DROP FUNCTION public.estudiantes_sin_matricula();
       public          postgres    false            �            1255    33347    generar_correo_estudiante()    FUNCTION     �  CREATE FUNCTION public.generar_correo_estudiante() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificar si el correo es NULL
    IF NEW.correo_institucional IS NULL THEN
        -- Crear el correo en el formato "nombre.apellido@ucsm.edu.pe"
        NEW.correo_institucional := LOWER(NEW.nombres || '.' || NEW.apellido || '@ucsm.edu.pe');
    END IF;

    -- Retornar la fila modificada
    RETURN NEW;
END;
$$;
 2   DROP FUNCTION public.generar_correo_estudiante();
       public          postgres    false            �            1255    33358     historial_constancias_por_ente()    FUNCTION     �  CREATE FUNCTION public.historial_constancias_por_ente() RETURNS TABLE(cod_ente_rector integer, nombre_ente character varying, apellidos character varying, cod_constancia integer, fecha_de_emision date)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        cer.cod_ente_rector, 
        er.nombres AS nombre_ente, 
        er.apellidos, 
        cer.cod_constancia, 
        cm.fecha_de_emision
    FROM mae_constancia_ente_rector cer
    JOIN mae_ente_rector er ON cer.cod_ente_rector = er.codigo
    JOIN mae_constancia_de_matricula cm ON cer.cod_constancia = cm.codigo
    ORDER BY er.codigo, cm.fecha_de_emision DESC;
END;
$$;
 7   DROP FUNCTION public.historial_constancias_por_ente();
       public          postgres    false            �            1255    33330 {   insertar_estudiante(character varying, character varying, character varying, character varying, character varying, boolean)    FUNCTION       CREATE FUNCTION public.insertar_estudiante(apellido character varying, nombres character varying, dni character varying, escuela_profesional character varying, correo_institucional character varying, deudas_pendientes boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO mae_estudiante (
        apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes
    ) VALUES (apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes);
END;
$$;
 �   DROP FUNCTION public.insertar_estudiante(apellido character varying, nombres character varying, dni character varying, escuela_profesional character varying, correo_institucional character varying, deudas_pendientes boolean);
       public          postgres    false            �            1255    33352    listar_constancias_recientes()    FUNCTION     ;  CREATE FUNCTION public.listar_constancias_recientes() RETURNS TABLE(codigo integer, tipo_de_documento integer, fecha_de_emision date, cod_estudiante integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        mae_constancia_de_matricula.codigo, 
        mae_constancia_de_matricula.tipo_de_documento, 
        mae_constancia_de_matricula.fecha_de_emision, 
        mae_constancia_de_matricula.cod_estudiante
    FROM mae_constancia_de_matricula
    WHERE mae_constancia_de_matricula.fecha_de_emision >= CURRENT_DATE - INTERVAL '1 month';
END;
$$;
 5   DROP FUNCTION public.listar_constancias_recientes();
       public          postgres    false            �            1255    33355    listar_entes_rectores()    FUNCTION     �  CREATE FUNCTION public.listar_entes_rectores() RETURNS TABLE(codigo integer, nombres character varying, apellidos character varying, cargo character varying, area character varying)
    LANGUAGE plpgsql
    AS $$
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
$$;
 .   DROP FUNCTION public.listar_entes_rectores();
       public          postgres    false            �            1255    33357    listar_estudiantes_con_deudas()    FUNCTION     +  CREATE FUNCTION public.listar_estudiantes_con_deudas() RETURNS TABLE(estudiante_id integer, apellido character varying, nombres character varying, total_deuda numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        e.codigo AS estudiante_id, 
        e.apellido, 
        e.nombres, 
        CAST(SUM(d.monto) AS NUMERIC) AS total_deuda
    FROM mae_estudiante e
    JOIN mae_deuda d ON e.codigo = d.cod_estudiante
    WHERE d.estado = FALSE
    GROUP BY e.codigo, e.apellido, e.nombres
    ORDER BY total_deuda DESC;
END;
$$;
 6   DROP FUNCTION public.listar_estudiantes_con_deudas();
       public          postgres    false            �            1255    33350    obtener_creditos_totales()    FUNCTION     6  CREATE FUNCTION public.obtener_creditos_totales() RETURNS TABLE(estudiante_id integer, nombre character varying, apellido character varying, total_creditos integer)
    LANGUAGE plpgsql
    AS $$
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
$$;
 1   DROP FUNCTION public.obtener_creditos_totales();
       public          postgres    false            �            1255    33349     obtener_estudiantes_con_deudas()    FUNCTION     U  CREATE FUNCTION public.obtener_estudiantes_con_deudas() RETURNS TABLE(codigo integer, apellido character varying, nombres character varying, dni character varying, correo_institucional character varying, deudas_pendientes boolean)
    LANGUAGE plpgsql
    AS $$
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
$$;
 7   DROP FUNCTION public.obtener_estudiantes_con_deudas();
       public          postgres    false            �            1255    33353 !   relacion_estudiantes_matriculas()    FUNCTION     1  CREATE FUNCTION public.relacion_estudiantes_matriculas() RETURNS TABLE(estudiante_id integer, nombres character varying, apellido character varying, matricula_id integer, creditos integer, semestre integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        e.codigo AS estudiante_id, 
        e.nombres, 
        e.apellido, 
        m.codigo AS matricula_id, 
        m.creditos, 
        m.nro_semestre AS semestre
    FROM mae_estudiante e
    LEFT JOIN mae_matricula m ON e.codigo = m.cod_estudiante
    ORDER BY e.codigo;
END;
$$;
 8   DROP FUNCTION public.relacion_estudiantes_matriculas();
       public          postgres    false            �            1259    33255    mae_constancia_de_matricula    TABLE     �   CREATE TABLE public.mae_constancia_de_matricula (
    codigo integer NOT NULL,
    tipo_de_documento integer NOT NULL,
    fecha_de_emision date NOT NULL,
    cod_estudiante integer NOT NULL
);
 /   DROP TABLE public.mae_constancia_de_matricula;
       public         heap    postgres    false            �            1259    33254 &   mae_constancia_de_matricula_codigo_seq    SEQUENCE     �   CREATE SEQUENCE public.mae_constancia_de_matricula_codigo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public.mae_constancia_de_matricula_codigo_seq;
       public          postgres    false    216                       0    0 &   mae_constancia_de_matricula_codigo_seq    SEQUENCE OWNED BY     q   ALTER SEQUENCE public.mae_constancia_de_matricula_codigo_seq OWNED BY public.mae_constancia_de_matricula.codigo;
          public          postgres    false    215            �            1259    33262    mae_constancia_ente_rector    TABLE     �   CREATE TABLE public.mae_constancia_ente_rector (
    codigo integer NOT NULL,
    cod_constancia integer NOT NULL,
    cod_ente_rector integer NOT NULL
);
 .   DROP TABLE public.mae_constancia_ente_rector;
       public         heap    postgres    false            �            1259    33261 %   mae_constancia_ente_rector_codigo_seq    SEQUENCE     �   CREATE SEQUENCE public.mae_constancia_ente_rector_codigo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.mae_constancia_ente_rector_codigo_seq;
       public          postgres    false    218                       0    0 %   mae_constancia_ente_rector_codigo_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public.mae_constancia_ente_rector_codigo_seq OWNED BY public.mae_constancia_ente_rector.codigo;
          public          postgres    false    217            �            1259    33269 	   mae_deuda    TABLE     �   CREATE TABLE public.mae_deuda (
    codigo integer NOT NULL,
    monto integer NOT NULL,
    estado boolean DEFAULT false NOT NULL,
    fecha_de_vencimiento date NOT NULL,
    cod_estudiante integer NOT NULL
);
    DROP TABLE public.mae_deuda;
       public         heap    postgres    false            �            1259    33268    mae_deuda_codigo_seq    SEQUENCE     �   CREATE SEQUENCE public.mae_deuda_codigo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.mae_deuda_codigo_seq;
       public          postgres    false    220                       0    0    mae_deuda_codigo_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.mae_deuda_codigo_seq OWNED BY public.mae_deuda.codigo;
          public          postgres    false    219            �            1259    33277    mae_ente_rector    TABLE       CREATE TABLE public.mae_ente_rector (
    codigo integer NOT NULL,
    cargo character varying(100) NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    area character varying(100) NOT NULL,
    firma bytea,
    sello bytea
);
 #   DROP TABLE public.mae_ente_rector;
       public         heap    postgres    false            �            1259    33276    mae_ente_rector_codigo_seq    SEQUENCE     �   CREATE SEQUENCE public.mae_ente_rector_codigo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.mae_ente_rector_codigo_seq;
       public          postgres    false    222                       0    0    mae_ente_rector_codigo_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.mae_ente_rector_codigo_seq OWNED BY public.mae_ente_rector.codigo;
          public          postgres    false    221            �            1259    33286    mae_estudiante    TABLE     ^  CREATE TABLE public.mae_estudiante (
    codigo integer NOT NULL,
    apellido character varying(100) NOT NULL,
    nombres character varying(100) NOT NULL,
    dni character varying(20) NOT NULL,
    escuela_profesional character varying(100) NOT NULL,
    correo_institucional character varying(100),
    deudas_pendientes boolean DEFAULT false
);
 "   DROP TABLE public.mae_estudiante;
       public         heap    postgres    false            �            1259    33285    mae_estudiante_codigo_seq    SEQUENCE     �   CREATE SEQUENCE public.mae_estudiante_codigo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.mae_estudiante_codigo_seq;
       public          postgres    false    224                       0    0    mae_estudiante_codigo_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.mae_estudiante_codigo_seq OWNED BY public.mae_estudiante.codigo;
          public          postgres    false    223            �            1259    33298    mae_matricula    TABLE     �   CREATE TABLE public.mae_matricula (
    codigo integer NOT NULL,
    creditos integer NOT NULL,
    nro_semestre integer NOT NULL,
    semestre_academico integer NOT NULL,
    cod_estudiante integer NOT NULL
);
 !   DROP TABLE public.mae_matricula;
       public         heap    postgres    false            �            1259    33297    mae_matricula_codigo_seq    SEQUENCE     �   CREATE SEQUENCE public.mae_matricula_codigo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.mae_matricula_codigo_seq;
       public          postgres    false    226                       0    0    mae_matricula_codigo_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.mae_matricula_codigo_seq OWNED BY public.mae_matricula.codigo;
          public          postgres    false    225            G           2604    33258 "   mae_constancia_de_matricula codigo    DEFAULT     �   ALTER TABLE ONLY public.mae_constancia_de_matricula ALTER COLUMN codigo SET DEFAULT nextval('public.mae_constancia_de_matricula_codigo_seq'::regclass);
 Q   ALTER TABLE public.mae_constancia_de_matricula ALTER COLUMN codigo DROP DEFAULT;
       public          postgres    false    215    216    216            H           2604    33265 !   mae_constancia_ente_rector codigo    DEFAULT     �   ALTER TABLE ONLY public.mae_constancia_ente_rector ALTER COLUMN codigo SET DEFAULT nextval('public.mae_constancia_ente_rector_codigo_seq'::regclass);
 P   ALTER TABLE public.mae_constancia_ente_rector ALTER COLUMN codigo DROP DEFAULT;
       public          postgres    false    217    218    218            I           2604    33272    mae_deuda codigo    DEFAULT     t   ALTER TABLE ONLY public.mae_deuda ALTER COLUMN codigo SET DEFAULT nextval('public.mae_deuda_codigo_seq'::regclass);
 ?   ALTER TABLE public.mae_deuda ALTER COLUMN codigo DROP DEFAULT;
       public          postgres    false    220    219    220            K           2604    33280    mae_ente_rector codigo    DEFAULT     �   ALTER TABLE ONLY public.mae_ente_rector ALTER COLUMN codigo SET DEFAULT nextval('public.mae_ente_rector_codigo_seq'::regclass);
 E   ALTER TABLE public.mae_ente_rector ALTER COLUMN codigo DROP DEFAULT;
       public          postgres    false    221    222    222            L           2604    33289    mae_estudiante codigo    DEFAULT     ~   ALTER TABLE ONLY public.mae_estudiante ALTER COLUMN codigo SET DEFAULT nextval('public.mae_estudiante_codigo_seq'::regclass);
 D   ALTER TABLE public.mae_estudiante ALTER COLUMN codigo DROP DEFAULT;
       public          postgres    false    223    224    224            N           2604    33301    mae_matricula codigo    DEFAULT     |   ALTER TABLE ONLY public.mae_matricula ALTER COLUMN codigo SET DEFAULT nextval('public.mae_matricula_codigo_seq'::regclass);
 C   ALTER TABLE public.mae_matricula ALTER COLUMN codigo DROP DEFAULT;
       public          postgres    false    225    226    226            �          0    33255    mae_constancia_de_matricula 
   TABLE DATA           r   COPY public.mae_constancia_de_matricula (codigo, tipo_de_documento, fecha_de_emision, cod_estudiante) FROM stdin;
    public          postgres    false    216   $�                  0    33262    mae_constancia_ente_rector 
   TABLE DATA           ]   COPY public.mae_constancia_ente_rector (codigo, cod_constancia, cod_ente_rector) FROM stdin;
    public          postgres    false    218   ��                 0    33269 	   mae_deuda 
   TABLE DATA           `   COPY public.mae_deuda (codigo, monto, estado, fecha_de_vencimiento, cod_estudiante) FROM stdin;
    public          postgres    false    220   ڌ                 0    33277    mae_ente_rector 
   TABLE DATA           `   COPY public.mae_ente_rector (codigo, cargo, nombres, apellidos, area, firma, sello) FROM stdin;
    public          postgres    false    222   c�                 0    33286    mae_estudiante 
   TABLE DATA           �   COPY public.mae_estudiante (codigo, apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes) FROM stdin;
    public          postgres    false    224   Ɏ                 0    33298    mae_matricula 
   TABLE DATA           k   COPY public.mae_matricula (codigo, creditos, nro_semestre, semestre_academico, cod_estudiante) FROM stdin;
    public          postgres    false    226   ��                  0    0 &   mae_constancia_de_matricula_codigo_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.mae_constancia_de_matricula_codigo_seq', 15, true);
          public          postgres    false    215                       0    0 %   mae_constancia_ente_rector_codigo_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('public.mae_constancia_ente_rector_codigo_seq', 15, true);
          public          postgres    false    217                       0    0    mae_deuda_codigo_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.mae_deuda_codigo_seq', 15, true);
          public          postgres    false    219                       0    0    mae_ente_rector_codigo_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.mae_ente_rector_codigo_seq', 15, true);
          public          postgres    false    221                       0    0    mae_estudiante_codigo_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.mae_estudiante_codigo_seq', 17, true);
          public          postgres    false    223                       0    0    mae_matricula_codigo_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.mae_matricula_codigo_seq', 15, true);
          public          postgres    false    225            Q           2606    33260 <   mae_constancia_de_matricula mae_constancia_de_matricula_pkey 
   CONSTRAINT     ~   ALTER TABLE ONLY public.mae_constancia_de_matricula
    ADD CONSTRAINT mae_constancia_de_matricula_pkey PRIMARY KEY (codigo);
 f   ALTER TABLE ONLY public.mae_constancia_de_matricula DROP CONSTRAINT mae_constancia_de_matricula_pkey;
       public            postgres    false    216            T           2606    33267 :   mae_constancia_ente_rector mae_constancia_ente_rector_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.mae_constancia_ente_rector
    ADD CONSTRAINT mae_constancia_ente_rector_pkey PRIMARY KEY (codigo);
 d   ALTER TABLE ONLY public.mae_constancia_ente_rector DROP CONSTRAINT mae_constancia_ente_rector_pkey;
       public            postgres    false    218            X           2606    33275    mae_deuda mae_deuda_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.mae_deuda
    ADD CONSTRAINT mae_deuda_pkey PRIMARY KEY (codigo);
 B   ALTER TABLE ONLY public.mae_deuda DROP CONSTRAINT mae_deuda_pkey;
       public            postgres    false    220            \           2606    33284 $   mae_ente_rector mae_ente_rector_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.mae_ente_rector
    ADD CONSTRAINT mae_ente_rector_pkey PRIMARY KEY (codigo);
 N   ALTER TABLE ONLY public.mae_ente_rector DROP CONSTRAINT mae_ente_rector_pkey;
       public            postgres    false    222            `           2606    33294 6   mae_estudiante mae_estudiante_correo_institucional_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.mae_estudiante
    ADD CONSTRAINT mae_estudiante_correo_institucional_key UNIQUE (correo_institucional);
 `   ALTER TABLE ONLY public.mae_estudiante DROP CONSTRAINT mae_estudiante_correo_institucional_key;
       public            postgres    false    224            b           2606    33296 )   mae_estudiante mae_estudiante_nombres_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.mae_estudiante
    ADD CONSTRAINT mae_estudiante_nombres_key UNIQUE (nombres);
 S   ALTER TABLE ONLY public.mae_estudiante DROP CONSTRAINT mae_estudiante_nombres_key;
       public            postgres    false    224            d           2606    33292 "   mae_estudiante mae_estudiante_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.mae_estudiante
    ADD CONSTRAINT mae_estudiante_pkey PRIMARY KEY (codigo);
 L   ALTER TABLE ONLY public.mae_estudiante DROP CONSTRAINT mae_estudiante_pkey;
       public            postgres    false    224            g           2606    33303     mae_matricula mae_matricula_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.mae_matricula
    ADD CONSTRAINT mae_matricula_pkey PRIMARY KEY (codigo);
 J   ALTER TABLE ONLY public.mae_matricula DROP CONSTRAINT mae_matricula_pkey;
       public            postgres    false    226            Y           1259    33345    idx_area_ente_rector    INDEX     P   CREATE INDEX idx_area_ente_rector ON public.mae_ente_rector USING btree (area);
 (   DROP INDEX public.idx_area_ente_rector;
       public            postgres    false    222            Z           1259    33346    idx_cargo_ente_rector    INDEX     R   CREATE INDEX idx_cargo_ente_rector ON public.mae_ente_rector USING btree (cargo);
 )   DROP INDEX public.idx_cargo_ente_rector;
       public            postgres    false    222            U           1259    33324    idx_cod_estudiante_deuda    INDEX     X   CREATE INDEX idx_cod_estudiante_deuda ON public.mae_deuda USING btree (cod_estudiante);
 ,   DROP INDEX public.idx_cod_estudiante_deuda;
       public            postgres    false    220            e           1259    33341    idx_cod_estudiante_matricula    INDEX     `   CREATE INDEX idx_cod_estudiante_matricula ON public.mae_matricula USING btree (cod_estudiante);
 0   DROP INDEX public.idx_cod_estudiante_matricula;
       public            postgres    false    226            R           1259    33344    idx_constancia_ente_rector    INDEX     |   CREATE INDEX idx_constancia_ente_rector ON public.mae_constancia_ente_rector USING btree (cod_constancia, cod_ente_rector);
 .   DROP INDEX public.idx_constancia_ente_rector;
       public            postgres    false    218    218            ]           1259    33340    idx_correo_institucional    INDEX     c   CREATE INDEX idx_correo_institucional ON public.mae_estudiante USING btree (correo_institucional);
 ,   DROP INDEX public.idx_correo_institucional;
       public            postgres    false    224            ^           1259    33339    idx_dni_estudiante    INDEX     L   CREATE INDEX idx_dni_estudiante ON public.mae_estudiante USING btree (dni);
 &   DROP INDEX public.idx_dni_estudiante;
       public            postgres    false    224            V           1259    33343    idx_estado_deuda    INDEX     H   CREATE INDEX idx_estado_deuda ON public.mae_deuda USING btree (estado);
 $   DROP INDEX public.idx_estado_deuda;
       public            postgres    false    220            O           1259    33342    idx_fecha_emision_constancia    INDEX     p   CREATE INDEX idx_fecha_emision_constancia ON public.mae_constancia_de_matricula USING btree (fecha_de_emision);
 0   DROP INDEX public.idx_fecha_emision_constancia;
       public            postgres    false    216            m           2620    33348 0   mae_estudiante trigger_generar_correo_estudiante    TRIGGER     �   CREATE TRIGGER trigger_generar_correo_estudiante BEFORE INSERT ON public.mae_estudiante FOR EACH ROW EXECUTE FUNCTION public.generar_correo_estudiante();
 I   DROP TRIGGER trigger_generar_correo_estudiante ON public.mae_estudiante;
       public          postgres    false    231    224            i           2606    33309 ?   mae_constancia_ente_rector fk_constancia_ente_rector_constancia    FK CONSTRAINT     �   ALTER TABLE ONLY public.mae_constancia_ente_rector
    ADD CONSTRAINT fk_constancia_ente_rector_constancia FOREIGN KEY (cod_constancia) REFERENCES public.mae_constancia_de_matricula(codigo) ON DELETE CASCADE;
 i   ALTER TABLE ONLY public.mae_constancia_ente_rector DROP CONSTRAINT fk_constancia_ente_rector_constancia;
       public          postgres    false    4689    216    218            j           2606    33314 9   mae_constancia_ente_rector fk_constancia_ente_rector_ente    FK CONSTRAINT     �   ALTER TABLE ONLY public.mae_constancia_ente_rector
    ADD CONSTRAINT fk_constancia_ente_rector_ente FOREIGN KEY (cod_ente_rector) REFERENCES public.mae_ente_rector(codigo) ON DELETE CASCADE;
 c   ALTER TABLE ONLY public.mae_constancia_ente_rector DROP CONSTRAINT fk_constancia_ente_rector_ente;
       public          postgres    false    218    4700    222            h           2606    33304 4   mae_constancia_de_matricula fk_estudiante_constancia    FK CONSTRAINT     �   ALTER TABLE ONLY public.mae_constancia_de_matricula
    ADD CONSTRAINT fk_estudiante_constancia FOREIGN KEY (cod_estudiante) REFERENCES public.mae_estudiante(codigo) ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.mae_constancia_de_matricula DROP CONSTRAINT fk_estudiante_constancia;
       public          postgres    false    224    4708    216            k           2606    33319    mae_deuda fk_estudiante_deuda    FK CONSTRAINT     �   ALTER TABLE ONLY public.mae_deuda
    ADD CONSTRAINT fk_estudiante_deuda FOREIGN KEY (cod_estudiante) REFERENCES public.mae_estudiante(codigo) ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.mae_deuda DROP CONSTRAINT fk_estudiante_deuda;
       public          postgres    false    4708    220    224            l           2606    33325 %   mae_matricula fk_estudiante_matricula    FK CONSTRAINT     �   ALTER TABLE ONLY public.mae_matricula
    ADD CONSTRAINT fk_estudiante_matricula FOREIGN KEY (cod_estudiante) REFERENCES public.mae_estudiante(codigo) ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.mae_matricula DROP CONSTRAINT fk_estudiante_matricula;
       public          postgres    false    224    4708    226            �   \   x�M���0�Ћ#�볗�_G�W�1h���ъT� �/Nd��H6/�O::��Ӎ�������bcS�6T)�tA��=��������� �w$�          :   x�˹�@ ���.������r�!ʍr�<(Oʋ�|(�23���`f6f���;�J         y   x�]�1�@k�/�Ap��I���<�¤D�Edf����D����j(�����n &�M$�Q7.�M,֢C�'�9�p�z��~W%JW�'�"����^��
��f
�_$��0�         V  x�m�MN�@F��)8"��I�"�
bՍ���dN�Eoò��8B.��6M+!ee=���7!$$��,�w+5C�_vQ^���4��z�?��Cbz�)J���kQ6��X����1��
fX���ڜyܑ��-�QB���j]n���]�P���
adسz{��馯,b+�*2���A8����P
���֓EObZ��-�����4cǝy�7�(��A���r��j�O2<�#g���`��l<{�pg6�E���<'�e���p_O�P|���t@x��؊G^��
u�n4�=��(Ů���z�s�n�젤��Ү+�X�_WƤO`���A�F^�1         �  x�u��n�@E뫯�Z��Y�#H!�$M��rE��gI��ߤL�*���,eT��P�s�/G�a��{rI��EY�k��*����A������E1|�;}����q��w���{�Te�gi"�aX>y؆2�`7K�Hv�D����-�H�4�2�U��v���6,9c�ϳ,M�D���^wJv} P��F��DW�3�S�[,�UU�E����۸��W`**�Ň�Z���yQ�eU���ߌ�nd��_)4\�^7�2���r��%����I��HN�v�G���@��"ւm�K�z���Gd*]��?�sC']#��Ū������:Dj�����Q\i|ø/��2��Tr�n�"��Щ��6Ľ_{�s��o�H?7�2t���
��w���%�.\.��^��ME<��ߕᡜ���,���Zԯ��K�̥�1Y�O����w(�����S�r��ɔ���l�Z��         h   x�5�[
A���,��]���X{@�BHJ�Ų�`1EF�6����^�9`�(��2�&⬢ŝ��h�d�):T{���oT�D�'$�RB�IFy6�j���H�	g�     