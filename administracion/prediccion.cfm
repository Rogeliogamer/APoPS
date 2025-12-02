<!---
 * Dashboard Integral para Sistema de Permisos
 * Integra datos reales desde getDashboardData.cfm
--->

<!--- Verificación de sesión --->
<cfif NOT structKeyExists(session, "rol")>
    <cflocation url="index.cfm" addtoken="no">
</cfif>

<!DOCTYPE html>
<html lang="es">
    <head>
        <!--- Metadatos y enlaces a estilos --->
        <meta charset="UTF-8">
        <!--- Vista adaptable para dispositivos móviles --->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!--- Icono de la pagina --->
        <link rel="icon" href="../elements/icono.ico" type="image/x-icon">
        <!--- Título de la página --->
        <title>Grafica - Prediccion</title>
        <!-- Carga de jQuery (local) -->
        <script src="../js/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <!-- Scripts del sistema -->
        <script src="../js/graficasKPI.js"></script>
        <script src="../js/metricas.js"></script>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/metricas.css">
        <link rel="stylesheet" href="../css/botones.css">
        <link rel="stylesheet" href="../css/temp.css">
    </head>
    <body>
        <!-- Verificación de sesión y rol -->
        <cfif NOT structKeyExists(session, "rol") 
            OR ListFindNoCase("Admin", session.rol) EQ 0>
            <cflocation url="../menu.cfm" addtoken="no">
        </cfif>

        <div class="container">
            <!-- Contenedor del formulario -->
            <div class="header">
                <!-- Nombre del usuario y rol que esta conectado -->
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "../componentes/usuarioConectadoSAdmin").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>

                <!-- Nombre del formulario -->
                <h1>Metricas</h1>
            </div>

            <div class="loading-overlay" id="loadingOverlay">
                <div class="spinner"></div>
            </div>

            <!-- Filtros -->
            <div class="form-container">
                <div class="section">
                    <div class="field-group single">
                        <div class="section-title">
                            Rango de Fechas
                        </div>
                        <select class="form-input-general" id="rangoFechas">
                            <option value="30" selected>Últimos 30 días</option>
                            <option value="60">Últimos 60 días</option>
                            <option value="90">Últimos 90 días</option>
                        </select>

                        <div class="section-title">
                            Área
                        </div>

                        <!--- Select dinámico --->
                        <select class="form-input-general" id="areaSeleccionada">
                            <!--- Opción para todas las áreas --->
                            <option value="">-- Seleciona un área --</option>
                                
                            <!--- Consultar áreas según el rol del usuario --->
                            <cfif ListFindNoCase("Admin,RecursosHumanos,Autorizacion,Expediente", session.rol)>
                                <!--- Estos roles pueden ver todas las áreas --->
                                <cfquery name="getAreas" datasource="Autorizacion">
                                    SELECT id_area, 
                                        nombre
                                    FROM area_adscripcion
                                </cfquery>
                            <cfelse>
                                <!--- Otros roles solo pueden ver su propia área --->
                                <cfquery name="getAreas" datasource="Autorizacion">
                                    SELECT id_area, 
                                        nombre
                                    FROM area_adscripcion
                                    WHERE id_area = <cfqueryparam value="#session.id_area#" cfsqltype="cf_sql_integer">
                                </cfquery>
                            </cfif>

                            <!--- Iterar sobre la consulta --->
                            <cfoutput query="getAreas">
                                <option value="#id_area#">#nombre#</option>
                            </cfoutput>
                        </select>
                    </div>
                        
                    <div class="submit-section">
                        <div class="field-group triple">
                            <a href="../adminPanel.cfm" class="submit-btn-menu submit-btn-menu-text">
                                Menu
                            </a>

                            <button class="submit-btn-actualizar" id="btnActualizar">
                                🔍 Actualizar
                            </button>

                            <a href="../cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                                Cerrar Sesion
                            </a>
                        </div>
                    </div>
                </div>

                <!-- prediccion a futuro -->
                <div class="section container-fluid">
                    <div class="kpi-header">
                        <div class="chart-title text-center mb-2">
                            Predicion a 7 dias por area seleccionada
                        </div>
                        <div class="chart-wrapper-fixed">
                            <canvas id="chartPredicion" class="w-100"></canvas>
                        </div>
                        <!-- Overlay solo para este canvas -->
                        <div class="canvasOverlay">
                            ¡A punto de revelar las estadísticas!
                        </div>
                    </div>
                </div>
            </div> 
        </div>

        <!--- Carga de jQuery (local o CDN) --->
        <script src="js/jquery-3.6.0.min.js"></script>

        <!---
            Seccion -> 3, 4
            Grafica -> 1, 2, 3, 4, 5, 6, 7
            Quita los overlays de las graficas
        --->
        <script>
            $('#btnActualizar').click(function() {
                // Oculta todos los overlays
                $('.canvasOverlay').fadeOut(300);
            });
        </script>

        <!---
            Seccion -> 4
            Grafica -> 7
            Grafica -> Predicion a 7 dias por area selecionada
        --->
        <script>
            $(document).ready(function() {
                $('#btnActualizar').click(function() {
                    let rangoDias = $('#rangoFechas').val();
                    let areaId = $('#areaSeleccionada').val();

                    $.ajax({
                        url: '../apis/obtenerPrediccion.cfc?method=getPrediccion',
                        type: 'GET',
                        data: { 
                            rangoDias: rangoDias, 
                            areaId: areaId 
                        },
                        dataType: 'json',
                        success: function(response) {
                            // Asegurarse de parsear JSON si viene como string
                            let data = (typeof response === 'string') ? JSON.parse(response) : response;
                            console.log('Datos AJAX:', data);
                            renderAdvancedChart(data);
                        },
                        error: function(err) {
                            console.error('Error al obtener predicción', err);
                        }
                    });
                });
            });

            function renderAdvancedChart(data) {
                // Usamo fecha y nombre del dia para el eje X
                const labels = data.map(d => `${d.nombre_dia} ${d.fecha}`);
                const ctx = document.getElementById('chartPredicion').getContext('2d');

                // Gradientes futuristas
                const gradientAprobados = ctx.createLinearGradient(0,0,0,400);
                gradientAprobados.addColorStop(0,'rgba(0,255,128,0.5)');
                gradientAprobados.addColorStop(1,'rgba(0,128,64,0.1)');

                const gradientPendientes = ctx.createLinearGradient(0,0,0,400);
                gradientPendientes.addColorStop(0,'rgba(255,200,0,0.5)');
                gradientPendientes.addColorStop(1,'rgba(128,100,0,0.1)');

                const gradientRechazados = ctx.createLinearGradient(0,0,0,400);
                gradientRechazados.addColorStop(0,'rgba(255,0,0,0.5)');
                gradientRechazados.addColorStop(1,'rgba(128,0,0,0.1)');

                <!---const gradientCredibilidad = ctx.createLinearGradient(0,0,0,400);
                gradientCredibilidad.addColorStop(0,'rgba(0,128,255,0.5)');
                gradientCredibilidad.addColorStop(1,'rgba(0,64,128,0.1)');--->

                // Destruir instancia previa
                if (window.chartInstance) {
                    window.chartInstance.destroy();
                }

                window.chartInstance = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [
                        {
                            label: 'Aprobados',
                            data: data.map(d => d.aprobados),
                            borderColor: '#00cc66', // Verde solido
                            backgroundColor: gradientAprobados,
                            fill: true,
                            tension: 0.4, // Curva suave (bezier)
                            pointRadius: 4,
                            pointBackgroundColor: '#fff',
                            pointBorderColor: '#00cc66',
                            borderWidth: 2
                        },
                        {
                            label: 'Pendientes',
                            data: data.map(d => d.pendientes),
                            borderColor: '#ffaa00', // Naranja
                            backgroundColor: gradientPendientes,
                            fill: true,
                            tension: 0.4,
                            pointRadius: 4,
                            pointBackgroundColor: '#fff',
                            pointBorderColor: '#ffaa00',
                            borderWidth: 2,
                            borderDash: [5,5] // Linea punteada para indicar incertidumbre
                        },
                        {
                            label: 'Rechazados',
                            data: data.map(d => d.rechazados),
                            borderColor: '#ff4444', // Rojo
                            backgroundColor: gradientRechazados,
                            fill: true,
                            tension: 0.4,
                            pointRadius: 4,
                            pointBackgroundColor: '#fff',
                            pointBorderColor: '#ff4444',
                            borderWidth: 2
                        },
                        {
                            label: 'Credibilidad (%)',
                            data: data.map(d => d.credibilidad),
                            borderColor: '#3399ff',
                            backgroundColor: 'rgba(51,153,255,0.1)',
                            fill: false,
                            tension: 0, // Linea recta para datos tecnicos
                            pointRadius: 0, // Ocultar puntos para limpiar ruido visual
                            borderWidth: 1,
                            yAxisID: 'yCredibilidad',
                            borderDash: [2,3]
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false, // Permite ajustar mejor la altura
                    interaction: { 
                        mode: 'index', 
                        intersect: false 
                    },
                    plugins: {
                        tooltip: {
                            backgroundColor: 'rgba(255, 255, 255, 0.9)',
                            titleColor: '#333',
                            bodyColor: '#666',
                            borderColor: '#ddd',
                            borderWidth: 1,
                            callbacks: {
                                label: function(context) {
                                    let label = context.dataset.label || '';
                                    if (label) {
                                        label += ': ';
                                    }
                                    if (context.parsed.y !== null) {
                                        label += context.parsed.y;
                                    }
                                    return label;
                                }
                            }
                        },
                        legend: { 
                            labels: { 
                                usePointStyle: true, 
                                boxWidth: 10,
                                font: { family: "'Inter', sans-serif", size: 12}
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: 'rgba(0,0,0,0.05)' },
                            title: { 
                                display: true, 
                                text: 'Solicitudes Estimadas', font: {size:11} 
                            } 
                        },
                        yCredibilidad: {
                            position: 'right',
                            min: 0,
                            max: 100,
                            grid: { display: false },
                            title: { display: true, text: 'Nivel de confianza (%)', font: {size:11} }, 
                        },
                        x: {
                            grid: { display: false }
                        }
                    }
                }
            });
        }
        </script>

        <!-- Chart.js -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <!-- Tu script de métricas (ya existente) -->
        <script src="../js/metricas.js"></script>

        <!-- Nuevo script de gráficas -->
        <script src="../js/graficasKPI.js"></script>
    </body>
</html>