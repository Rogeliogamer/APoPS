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
        <title>Grafica - Tendencia de Solicitudes</title>
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
            <cflocation url="menu.cfm" addtoken="no">
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
                            <cfif ListFindNoCase("Admin", session.rol)>
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

                <!-- KPI Cards -->
                <div class="section container-fluid">
                    
                        <div class="kpi-header">
                            <div class="chart-title">Tendencia de Solicitudes (Por periodo)</div>
                            <canvas id="chartTendencia" height="250"></canvas>
                            <!-- Overlay solo para este canvas -->
                            <div class="canvasOverlay">
                                ¡A punto de revelar las estadísticas!
                            </div>
                        </div>
                    
                </div>
            </div> 
        </div>

        <!--- Carga de jQuery (local o CDN) --->
        <script src="../js/jquery-3.6.0.min.js"></script>

        

        

        <!---
            Seccion -> 3
            Grafica -> 3
            Grafica -> Tendencia de Solicitudes
        --->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <script>
            var chartTendencia; // Variable global para la gráfica

            function actualizarTendencia() {
                var rango = $("#rangoFechas").val();
                var area = $("#areaSeleccionada").val();

                // Solo continuar si el usuario seleccionó un área
                if(area === "") {
                    alert("Por favor selecciona un área para mostrar la gráfica.");
                    return;
                }

                $.ajax({
                    url: "../apis/obtenerTendencia.cfm",
                    method: "POST",
                    data: { 
                        rango: rango, 
                        area: area 
                    },
                    dataType: "json",
                    success: function(response) {
                        var labels = [];
                        var aprobadas = [];
                        var pendientes = [];
                        var rechazadas = [];

                        response.tendencia.forEach(function(item) {
                            // Convertir fecha a formato legible si quieres
                            labels.push(item.fecha);
                            aprobadas.push(item.aprobadas);
                            pendientes.push(item.pendientes);
                            rechazadas.push(item.rechazadas);
                        });

                        // Si ya existe la gráfica, la destruimos antes de crear una nueva
                        if(chartTendencia) {
                            chartTendencia.destroy();
                        }

                        var ctx = document.getElementById("chartTendencia").getContext("2d");
                        
                        chartTendencia = new Chart(ctx, {
                            type: 'line',
                            data: {
                                labels: labels,
                                datasets: [
                                    {
                                        label: 'Aprobadas',
                                        data: aprobadas,
                                        borderColor: 'green',
                                        backgroundColor: 'rgba(0,128,0,0.1)',
                                        fill: true,
                                        tension: 0.3
                                    },
                                    {
                                        label: 'Pendientes',
                                        data: pendientes,
                                        borderColor: 'orange',
                                        backgroundColor: 'rgba(255,165,0,0.1)',
                                        fill: true,
                                        tension: 0.3
                                    },
                                    {
                                        label: 'Rechazadas',
                                        data: rechazadas,
                                        borderColor: 'red',
                                        backgroundColor: 'rgba(255,0,0,0.1)',
                                        fill: true,
                                        tension: 0.3
                                    }
                                ]
                            },
                            options: {
                                responsive: true,
                                plugins: {
                                    legend: {
                                        position: 'top',
                                    },
                                    tooltip: {
                                        mode: 'index',
                                        intersect: false,
                                    }
                                },
                                interaction: {
                                    mode: 'nearest',
                                    intersect: false
                                },
                                scales: {
                                    x: {
                                        title: {
                                            display: true,
                                            text: 'Fecha'
                                        }
                                    },
                                    y: {
                                        title: {
                                            display: true,
                                            text: 'Cantidad de solicitudes'
                                        },
                                        beginAtZero: true,
                                        precision: 0
                                    }
                                }
                            }
                        });
                    },
                    error: function(err) {
                        console.error("Error al obtener la tendencia:", err);
                    }
                });
            }

            // Evento click del botón
            $("#btnActualizar").click(function(e) {
                e.preventDefault();
                actualizarTendencia();
            });
        </script>

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

        <!-- Chart.js -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <!-- Tu script de métricas (ya existente) -->
        <script src="../js/metricas.js"></script>

        <!-- Nuevo script de gráficas -->
        <script src="../js/graficasKPI.js"></script>
    </body>
</html>