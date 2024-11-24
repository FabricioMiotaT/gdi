document.getElementById('insertarForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());
    data.deudas_pendientes = formData.get('deudas_pendientes') ? true : false;

    fetch('http://localhost:8000/insertar_estudiante', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(data),
    })
        .then(response => response.text())
        .then(data => {
            alert(data); 
        })
        .catch(error => console.error('Error:', error));
});

document.getElementById('eliminarForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());

    fetch('http://localhost:8000/eliminar_estudiante', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(data),
    })
        .then(response => response.text())
        .then(data => {
            alert(data); 
        })
        .catch(error => console.error('Error:', error));
});

document.getElementById('consultarForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const formData = new FormData(e.target);
    const data = new URLSearchParams(formData).toString(); // Convert form data to query string

    fetch(`http://127.0.0.1:5500//consultar_estudiante?${data}`, {
        method: 'GET', // GET requests should not have a body
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    })
        .then(response => {

                return response.json();

        })
        .then(estudiante => {
            alert(`Estudiante encontrado:\n
ID: ${estudiante.codigo}\n
Apellido: ${estudiante.apellido}\n
Nombre: ${estudiante.nombres}\n
DNI: ${estudiante.dni}\n
Escuela Profesional: ${estudiante.escuela_profesional}\n
Correo: ${estudiante.correo_institucional}\n
Deudas Pendientes: ${estudiante.deudas_pendientes ? 'SÃ­' : 'No'}`);
        })
        .catch(error => {
            alert(error.message); 
        });
});

document.getElementById('actualizarForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());
    data.deudas_pendientes = formData.get('deudas_pendientes') ? true : false;

    fetch('http://localhost:8000/actualizar_estudiante', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(data),
    })
        .then(response => response.text())
        .then(data => {
            alert(data); 
        })
        .catch(error => console.error('Error:', error));
});