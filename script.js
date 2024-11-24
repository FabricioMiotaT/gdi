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

function consultar(endpoint) {
    fetch(`http://localhost:8000${endpoint}`, {
        method: 'POST',
    })
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    throw new Error(`HTTP ${response.status}: ${text}`);
                });
            }
            return response.json(); 
        })
        .then(data => {
            const resultadosDiv = document.getElementById('resultados');
            resultadosDiv.innerHTML = `<pre>${JSON.stringify(data, null, 2)}</pre>`;
        })
        .catch(error => {
            console.error('Error en la consulta:', error);
            alert(`Error: ${error.message}`);
        });
}

document.getElementById('semestreForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const formData = new FormData(e.target);
    const semestre = formData.get('semestre');

    fetch('http://localhost:8000/contar_estudiantes_por_semestre', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ semestre }),
    })
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    throw new Error(`Error HTTP ${response.status}: ${text}`);
                });
            }
            return response.json();
        })
        .then(data => {
            document.getElementById('cantidad').innerText =
                `Total de estudiantes matriculados en el semestre ${semestre}: ${data.total_estudiantes}`;
        })
        .catch(error => {
            console.error('Error en la consulta:', error);
            alert(`Error: ${error.message}`);
        });
});

document.getElementById('deudasButton').addEventListener('click', function () {
    fetch('http://localhost:8000/calcular_total_deuda', {
        method: 'POST',
    })
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    throw new Error(`HTTP Error ${response.status}: ${text}`);
                });
            }
            return response.json();
        })
        .then(data => {
            const tableBody = document.getElementById('deudasTable').querySelector('tbody');
            tableBody.innerHTML = ''; 

            data.forEach(row => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${row.estudiante_id}</td>
                    <td>${row.nombres}</td>
                    <td>${row.apellido}</td>
                    <td>${row.total_deuda.toFixed(2)}</td>
                `;
                tableBody.appendChild(tr);
            });
        })
        .catch(error => {
            console.error('Error en la consulta:', error);
            alert(`Error: ${error.message}`);
        });
});

document.getElementById('relacionButton').addEventListener('click', function () {
    fetch('http://localhost:8000/relacion_estudiantes_matriculas', {
        method: 'POST',
    })
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    throw new Error(`HTTP Error ${response.status}: ${text}`);
                });
            }
            return response.json();
        })
        .then(data => {
            const tableBody = document.getElementById('relacionTable').querySelector('tbody');
            tableBody.innerHTML = ''; 

            data.forEach(row => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${row.estudiante_id}</td>
                    <td>${row.nombres}</td>
                    <td>${row.apellido}</td>
                    <td>${row.matricula_id || 'Sin matrícula'}</td>
                    <td>${row.creditos || 'N/A'}</td>
                    <td>${row.semestre || 'N/A'}</td>
                `;
                tableBody.appendChild(tr);
            });
        })
        .catch(error => {
            console.error('Error en la consulta:', error);
            alert(`Error: ${error.message}`);
        });
});

document.getElementById('consultarConstanciasButton').addEventListener('click', function () {
    console.log("Botón presionado"); 
    fetch('http://localhost:8000/estudiantes_con_numero_constancias', {
        method: 'POST'
    })
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    throw new Error(`HTTP Error ${response.status}: ${text}`);
                });
            }
            return response.json();
        })
        .then(data => {
            console.log("Datos recibidos del backend:", data); 
            const tableBody = document.getElementById('constanciasTable').querySelector('tbody');
            tableBody.innerHTML = '';
            data.forEach(row => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${row.estudiante_id}</td>
                    <td>${row.nombres}</td>
                    <td>${row.apellido}</td>
                    <td>${row.total_constancias}</td>
                `;
                tableBody.appendChild(tr);
            });
        })
        .catch(error => {
            console.error('Error en la consulta:', error);
            alert(`Error: ${error.message}`);
        });
});

document.getElementById('deudaMayor1500Button').addEventListener('click', function () {
    fetch('http://localhost:8000/estudiantes_con_deuda_mayor_a_1500', {
        method: 'POST'
    })
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    throw new Error(`HTTP Error ${response.status}: ${text}`);
                });
            }
            return response.json();
        })
        .then(data => {
            const tableBody = document.getElementById('deudaMayor1500Table').querySelector('tbody');
            tableBody.innerHTML = ''; 

            data.forEach(row => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${row.estudiante_id}</td>
                    <td>${row.nombres}</td>
                    <td>${row.apellido}</td>
                    <td>${row.total_deuda.toFixed(2)}</td>
                `;
                tableBody.appendChild(tr);
            });
        })
        .catch(error => {
            console.error('Error en la consulta:', error);
            alert(`Error: ${error.message}`);
        });
});

function consultarConstanciasRecientes() {
    fetch('http://localhost:8000/estudiantes_con_constancias_recientes', {
        method: 'POST',
    })
        .then(response => {
            if (!response.ok) {
                throw new Error(`Error HTTP: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            const tabla = document.getElementById('tablaConstanciasRecientes').getElementsByTagName('tbody')[0];
            tabla.innerHTML = ''; 

            data.forEach(fila => {
                const filaHTML = `
                    <tr>
                        <td>${fila.estudiante_id}</td>
                        <td>${fila.nombres}</td>
                        <td>${fila.apellidos}</td>
                        <td>${fila.dni}</td>
                        <td>${fila.constancia_id}</td>
                        <td>${fila.tipo_de_documento}</td>
                        <td>${fila.fecha_emision}</td>
                    </tr>
                `;
                tabla.innerHTML += filaHTML;
            });
        })
        .catch(error => {
            console.error("Error en la consulta:", error);
            alert("Error en la consulta: " + error.message);
        });
}

function consultarMatriculasRecientes() {
    fetch('http://localhost:8000/estudiantes_con_matriculas_recientes', {
        method: 'POST',
    })
        .then(response => {
            if (!response.ok) {
                throw new Error(`Error HTTP: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            const tabla = document
                .getElementById('tablaMatriculasRecientes')
                .getElementsByTagName('tbody')[0];
            tabla.innerHTML = ''; 

            data.forEach(fila => {
                const filaHTML = `
                    <tr>
                        <td>${fila.estudiante_id}</td>
                        <td>${fila.nombres}</td>
                        <td>${fila.apellidos}</td>
                        <td>${fila.dni}</td>
                        <td>${fila.escuela_profesional}</td>
                        <td>${fila.semestre_academico}</td>
                        <td>${fila.nro_semestre}</td>
                        <td>${fila.creditos}</td>
                    </tr>
                `;
                tabla.innerHTML += filaHTML;
            });
        })
        .catch(error => {
            console.error("Error en la consulta:", error);
            alert("Error en la consulta: " + error.message);
        });
}

function consultarCreditosAcumulados() {
    fetch('http://localhost:8000/estudiantes_con_creditos_acumulados', {
        method: 'POST',
    })
        .then(response => {
            if (!response.ok) {
                throw new Error(`Error HTTP: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            const tabla = document
                .getElementById('tablaCreditosAcumulados')
                .getElementsByTagName('tbody')[0];
            tabla.innerHTML = ''; 

            data.forEach(fila => {
                const filaHTML = `
                    <tr>
                        <td>${fila.estudiante_id}</td>
                        <td>${fila.nombres}</td>
                        <td>${fila.apellidos}</td>
                        <td>${fila.total_creditos}</td>
                    </tr>
                `;
                tabla.innerHTML += filaHTML;
            });
        })
        .catch(error => {
            console.error("Error en la consulta:", error);
            alert("Error en la consulta: " + error.message);
        });
}

function mostrarResultados(datos) {
    const contenedorResultados = document.getElementById('resultados');

    if (datos.length === 0) {
        contenedorResultados.innerHTML = '<p>No se encontraron resultados.</p>';
        return;
    }

    const tabla = document.createElement('table');

    const caption = document.createElement('caption');
    caption.textContent = 'Estudiantes con Deudas Pendientes';
    tabla.appendChild(caption);

    const encabezado = document.createElement('tr');
    const columnas = ['Código', 'Apellido', 'Nombres', 'DNI', 'Correo Institucional', 'Deudas Pendientes'];
    columnas.forEach(columna => {
        const th = document.createElement('th');
        th.textContent = columna;
        encabezado.appendChild(th);
    });
    tabla.appendChild(encabezado);

    datos.forEach(estudiante => {
        const fila = document.createElement('tr');
        fila.innerHTML = `
            <td>${estudiante.codigo}</td>
            <td>${estudiante.apellido}</td>
            <td>${estudiante.nombres}</td>
            <td>${estudiante.dni}</td>
            <td>${estudiante.correo_institucional}</td>
            <td>${estudiante.deudas_pendientes ? 'Sí' : 'No'}</td>
        `;
        tabla.appendChild(fila);
    });

    contenedorResultados.innerHTML = '';
    contenedorResultados.appendChild(tabla);
}
