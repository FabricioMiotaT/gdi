from http.server import BaseHTTPRequestHandler, HTTPServer
import json
from urllib.parse import parse_qs
import psycopg2

def conectar():
    return psycopg2.connect(
        dbname="MODELOFISICO2",
        user="postgres",
        password="admin",
        host="localhost",
        port="5432"
    )

class RequestHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_POST(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        params = parse_qs(post_data)

        if self.path == "/insertar_estudiante":
            apellido = params['apellido'][0]
            nombres = params['nombres'][0]
            dni = params['dni'][0]
            escuela_profesional = params['escuela_profesional'][0]
            correo_institucional = params['correo_institucional'][0]
            deudas_pendientes = params['deudas_pendientes'][0].lower() == 'true'
            self.insertar_estudiante(apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes)
        elif self.path == "/eliminar_estudiante":
            estudiante_id = int(params['id'][0])
            self.eliminar_estudiante(estudiante_id)
        elif self.path == "/actualizar_estudiante":
            estudiante_id = int(params['id'][0])
            apellido = params['apellido'][0]
            nombres = params['nombres'][0]
            dni = params['dni'][0]
            escuela_profesional = params['escuela_profesional'][0]
            correo_institucional = params['correo_institucional'][0]
            deudas_pendientes = params['deudas_pendientes'][0].lower() == 'true'
            self.actualizar_estudiante(estudiante_id, apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes)

        elif self.path == "/obtener_estudiantes_con_deudas":
            self.llamar_funcion("SELECT * FROM obtener_estudiantes_con_deudas();")
        elif self.path == "/obtener_creditos_totales":
            self.llamar_funcion("SELECT * FROM obtener_creditos_totales();")
        elif self.path == "/listar_constancias_recientes":
            self.llamar_funcion("SELECT * FROM listar_constancias_recientes();")
        elif self.path == "/listar_entes_rectores":
            self.llamar_funcion("SELECT * FROM listar_entes_rectores();")
        elif self.path == "/estudiantes_sin_matricula":
            self.llamar_funcion("SELECT * FROM estudiantes_sin_matricula();")
        elif self.path == "/listar_estudiantes_con_deudas":
            self.llamar_funcion("SELECT * FROM listar_estudiantes_con_deudas();")
        elif self.path == "/historial_constancias_por_ente":
            self.llamar_funcion("SELECT * FROM historial_constancias_por_ente();")

    def insertar_estudiante(self, apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes):
        conn = conectar()
        cursor = conn.cursor()
        cursor.callproc('insertar_estudiante', (apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes))
        conn.commit()
        cursor.close()
        conn.close()
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Estudiante insertado correctamente.')

    def eliminar_estudiante(self, estudiante_id):
        conn = conectar()
        cursor = conn.cursor()
        cursor.callproc('eliminar_estudiante', (estudiante_id,))
        conn.commit()
        cursor.close()
        conn.close()
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Estudiante eliminado correctamente.')

    def actualizar_estudiante(self, estudiante_id, apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes):
        conn = conectar()
        cursor = conn.cursor()
        cursor.callproc('actualizar_estudiante', (estudiante_id, apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes))
        conn.commit()
        cursor.close()
        conn.close()
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Estudiante actualizado correctamente.')

    def llamar_funcion(self, funcion_sql):
        conn = conectar()
        cursor = conn.cursor()
        try:
            cursor.execute(funcion_sql)
            resultados = cursor.fetchall()
            colnames = [desc[0] for desc in cursor.description]
            datos = [dict(zip(colnames, fila)) for fila in resultados]
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(datos).encode())
        except Exception as e:
            print(f"Error: {e}")
            self.send_response(500)
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode())
        finally:
            cursor.close()
            conn.close()


def run():
    server_address = ('', 8000)
    httpd = HTTPServer(server_address, RequestHandler)
    print("Servidor corriendo en el puerto 8000...")
    httpd.serve_forever()

run()
