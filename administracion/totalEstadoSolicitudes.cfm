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
        <title>Total de Estado Solicitudes</title>
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
                    <cfset usuarioRol = createObject("component", "../componentes/usuarioConectadoSAdmin.cfc").render()>
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
                    
                <!-- KPIs -->
                <div class="section">
                    <div class="field-group">
                        <div class="kpi-header-totalSolicitudes kpi-card">
                            <div class="kpi-info">
                                <div class="kpi-title">Total Solicitudes</div>
                                <div class="kpi-value" id="totalSolicitudes">0</div>
                                <div class="kpi-subtitle">Este período</div>
                            </div> 
                            <div class="kpi-chart">
                                <canvas id="graficoTotalSolicitudes" width="200" height="80"></canvas>
                            </div>
                        </div>

                        <div class="kpi-header-aprovadas kpi-card">
                            <div class="kpi-info">
                                <div class="kpi-title">Aprobadas</div>
                                <div class="kpi-value" id="solicitudesAprobadas">0</div>
                                <div class="kpi-subtitle" id="solicitudesAprobadasPct">0% de aprobación</div>
                            </div>
                            <div class="kpi-chart">
                                <canvas id="graficoAprobadas" width="200" height="80"></canvas>
                            </div>
                        </div>

                        <div class="kpi-header-pendientes kpi-card">
                            <div class="kpi-info">
                                <div class="kpi-title">Pendientes</div>
                                <div class="kpi-value" id="solicitudesPendientes">0</div>
                                <div class="kpi-subtitle" id="solicitudesPendientesPct">0% de aprobación</div>
                            </div>
                            <div class="kpi-chart">
                                <canvas id="graficoPendientes" width="200" height="80"></canvas>
                            </div>
                        </div>

                        <div class="kpi-header-rechazadas kpi-card">
                            <div class="kpi-info">
                                <div class="kpi-title">Rechazadas</div>
                                <div class="kpi-value" id="solicitudesRechazadas">0</div>
                                <div class="kpi-subtitle" id="solicitudesRechazadasPct">0% de rechazo</div>
                            </div>
                            <div class="kpi-chart">
                                <canvas id="graficoRechazadas" width="200" height="80"></canvas>
                            </div>
                        </div>

                        <div class="kpi-header-tiempoPromedio kpi-card">
                            <div class="kpi-info">
                                <div class="kpi-title">Tiempo Promedio</div>
                                <div class="kpi-value" id="tiempoPromedio">0 días</div>
                                <div class="kpi-subtitle">Hasta aprobación final</div>
                            </div>
                            <div class="kpi-chart">
                                <canvas id="graficoTiempo" width="200" height="80"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div> 
        </div>

        <!--- Carga de jQuery (local o CDN) --->
        <script src="js/jquery-3.6.0.min.js"></script>

        <!--- 
            Seccion 2
            Actuliza el contador del estado de las solicitudes y el tiempo promedio de aprobacion 
        --->
        <script>
            $(document).ready(function() {

                // Función para actualizar las métricas
                function actualizarMetricas() {
                    let dias = $("#rangoFechas").val();
                    let area = $("#areaSeleccionada").val();

                    if(area === "") {
                        alert("Por favor selecciona un área.");
                        return;
                    }

                    $("#loadingOverlay").addClass("active");

                    $.ajax({
                        url: "../apis/obtenerMetricas.cfm",
                        method: "POST",
                        data: { 
                            rango: dias, 
                            area: area 
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false
                        },
                        dataType: "json",
                        success: function(response) {
                            console.log("Datos recibidos mini:", response);
                            // Total de solicitudes
                            $("#totalSolicitudes").text(response.totalSolicitudes);

                            // Aprobadas
                            $("#solicitudesAprobadas").text(response.solicitudesAprobadas);
                            $("#solicitudesAprobadasPct").text(response.porcentajeAprobadas.toFixed(1) + "% de aprobación");

                            // Pendientes
                            $("#solicitudesPendientes").text(response.solicitudesPendientes);
                            $("#solicitudesPendientesPct").text(response.porcentajePendientes.toFixed(1) + "% de aprobación");

                            // Rechazadas
                            $("#solicitudesRechazadas").text(response.solicitudesRechazadas);
                            $("#solicitudesRechazadasPct").text(response.porcentajeRechazadas.toFixed(1) + "% de rechazo");

                            // Tiempo promedio
                            $("#tiempoPromedio").text(response.tiempoPromedio + " días");

                            // ✅ Llamar a las mini gráficas
                            actualizarGraficasKPI(response);
                        },
                        error: function(xhr, status, error) {
                            console.error("Error al obtener métricas:", error);
                            alert("Hubo un error al cargar las métricas.");
                        },
                        complete: function() {
                            $("#loadingOverlay").removeClass("active");
                        }
                    });
                }

                // Evento del botón
                $("#btnActualizar").click(function() {
                    actualizarMetricas();
                });

                // Opcional: cargar métricas automáticamente al cargar la página
                // actualizarMetricas();
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