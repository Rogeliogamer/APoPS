<!---
 * Nombre de la pagina: administracion/estadoSolicitudes.cfm
 * 
 * Descripción: 
 * Esta página muestra las métricas y el estado de las solicitudes
 * realizadas en el sistema. Incluye gráficos interactivos que permiten
 * visualizar el estado de las solicitudes (aprobadas, pendientes,
 * rechazadas) en función de diferentes filtros como rango de fechas
 * y área de adscripción. La página está protegida y solo accesible
 * para usuarios con rol de administrador.
 * 
 * Roles:
 * Admin: Acceso completo a las métricas y gráficos.
 * 
 * Paginas relacionadas:
 * menu.cfm: Página principal del menú.
 * adminPanel.cfm: Panel de administración.
 * cerrarSesion.cfm: Cierre de sesión del usuario.
 * jquery-3.6.0.min.js: Biblioteca jQuery para manipulación del DOM y AJAX.
 * obtenerEstadoSolicitudes.cfm: API para obtener datos de estado de solicitudes.
 * https://cdn.jsdelivr.net/npm/chart.js: Biblioteca Chart.js para gráficos.
 * metricas.js: Script personalizado para manejar métricas.
 * graficasKPI.js: Script personalizado para manejar gráficos KPI.
 * 
 * Autor: Rogelio Perez Guevara
 * 
 * Fecha de creación: 01-12-2025
 * 
 * Versión: 1.0
--->

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
        <title>Gráfica - Estado Solicitudes</title>
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
        <!--- Verificación de sesión y rol --->
        <cfif NOT (structKeyExists(session, "rol") AND len(trim(session.usuario)))>
            <!--- Redirigir a la página de login si no hay sesión activa --->
            <cflocation url="../login.cfm" addtoken="no">
        <!--- Verificar si el rol del usuario es Admin --->
        <cfelseif ListFindNoCase("Admin", session.rol) EQ 0>
            <!--- Redirigir a la página de menú si el rol no es Admin --->
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
                <h1>Estado de solicitudes</h1>
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
                            <option value="">-- Selecciona un área --</option>
                                
                            <!--- Consultar áreas según el rol del usuario --->
                            <cfif ListFindNoCase("RecursosHumanos,Admin", session.rol)>
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
                        <div class="kpi-header container-fluid px-2 px-md-3">
                            <div class="chart-title text-center text-md-start">
                                Estado de solicitudes
                            </div>
                            <div style="position: relative; height: 250px; width: 100%;">
                                <canvas id="chartEstados"></canvas>
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
            Sección -> 3
            Gráfica -> 1
            Gráfica -> Estado de solicitudes
        --->
        <script>
            $(document).ready(function() {

                let chartEstados; // Variable global para mantener la referencia de la gráfica

                function actualizarGraficaEstados(area, dias) {
                    $.ajax({
                        url: "../apis/obtenerEstadoSolicitudes.cfm",
                        method: "POST",
                        data: { 
                            rango: dias, 
                            area: area 
                        },
                        dataType: "json",
                        success: function(response) {
                            // Datos para el pie chart usando status_final
                            const data = {
                                labels: ['Aprobadas', 'Pendientes', 'Rechazadas'],
                                datasets: [{
                                    label: 'Estado de solicitudes',
                                    data: [
                                        response.solicitudesAprobadas,
                                        response.solicitudesPendientes,
                                        response.solicitudesRechazadas
                                    ],
                                    backgroundColor: [
                                        '#2F855A', // Verde
                                        '#D69E2E', // Amarillo
                                        '#C53030'  // Rojo
                                    ],
                                    borderWidth: 1
                                }]
                            };

                            const config = {
                                type: 'pie',
                                data: data,
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    plugins: {
                                        legend: {
                                            position: 'bottom',
                                        },
                                        tooltip: {
                                            callbacks: {
                                                label: function(context){
                                                    let total = context.dataset.data.reduce((a,b)=>a+b,0);
                                                    let value = context.raw;
                                                    let pct = total ? ((value/total)*100).toFixed(1) : 0;
                                                    return `${context.label}: ${value} (${pct}%)`;
                                                }
                                            }
                                        }
                                    }
                                }
                            };

                            // Si la gráfica ya existe, destrúyela antes de crear una nueva
                            if(chartEstados) chartEstados.destroy();

                            chartEstados = new Chart(
                                document.getElementById('chartEstados'),
                                config
                            );
                        },
                        error: function(xhr, status, error) {
                            console.error("Error al obtener datos para la gráfica:", error);
                        }
                    });
                }

                // Llamar la función al dar click en actualizar
                $("#btnActualizar").click(function() {
                    let dias = $("#rangoFechas").val();
                    let area = $("#areaSeleccionada").val();
                    if(area === "") {
                        alert("Por favor selecciona un área.");
                        return;
                    }
                    actualizarGraficaEstados(area, dias);
                });
            });
        </script>

        <!---
            Sección -> 3, 4
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