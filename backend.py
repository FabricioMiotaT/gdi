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
        elif self.path == "/consultar_estudiante":
            estudiante_id = int(params['id'][0])
            self.consultar_estudiante(estudiante_id)
        elif self.path == "/actualizar_estudiante":
            estudiante_id = int(params['id'][0])
            apellido = params['apellido'][0]
            nombres = params['nombres'][0]
            dni = params['dni'][0]
            escuela_profesional = params['escuela_profesional'][0]
            correo_institucional = params['correo_institucional'][0]
            deudas_pendientes = params['deudas_pendientes'][0].lower() == 'true'
            self.actualizar_estudiante(estudiante_id, apellido, nombres, dni, escuela_profesional, correo_institucional, deudas_pendientes)

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

    def consultar_estudiante(self, estudiante_id):
        conn = conectar()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM consultar_estudiante(%s)", (estudiante_id,))
        estudiante = cursor.fetchone()
        cursor.close()
        conn.close()

        if estudiante:
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            estudiante_dict = {
                "codigo": estudiante[0],
                "apellido": estudiante[1],
                "nombres": estudiante[2],
                "dni": estudiante[3],
                "escuela_profesional": estudiante[4],
                "correo_institucional": estudiante[5],
                "deudas_pendientes": estudiante[6]
            }
            self.wfile.write(json.dumps(estudiante_dict).encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Estudiante no encontrado.')

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


def run():
    server_address = ('', 8000)
    httpd = HTTPServer(server_address, RequestHandler)
    print("jeje")
    httpd.serve_forever()

run()
