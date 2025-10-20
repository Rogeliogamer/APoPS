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
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dashboard - Sistema de Permisos</title>

        <!-- Carga de jQuery (local) -->
        <script src="js/jquery-3.6.0.min.js"></script>

        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/botones.css">

        <style>
            /* Extensiones específicas para Dashboard */
            .kpi-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                margin-bottom: 25px;
            }

            .kpi-card {
                background: #ebebeb;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px rgba(0,0,0,0.15);
            }

            .kpi-header {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-totalSolicitudes {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-totalSolicitudes:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px #2B6CB0;
            }

            /* Cambia el color de los textos internos al hacer hover en el header */
            .kpi-header-totalSolicitudes:hover .kpi-title,
            .kpi-header-totalSolicitudes:hover .kpi-value,
            .kpi-header-totalSolicitudes:hover .kpi-subtitle {
                color: #2B6CB0; /* Azul principal */
                transition: color 0.3s ease;
                font-weight: 700;
            }

            .kpi-header-aprovadas {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-aprovadas:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px #2F855A;
            }

            /* Cambia el color de los textos internos al hacer hover en el header */
            .kpi-header-aprovadas:hover .kpi-title,
            .kpi-header-aprovadas:hover .kpi-value,
            .kpi-header-aprovadas:hover .kpi-subtitle {
                color: #2F855A; /* Azul principal */
                transition: color 0.3s ease;
                font-weight: 700;
            }

            .kpi-header-pendientes {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-pendientes:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px #D69E2E;
            }

            /* Cambia el color de los textos internos al hacer hover en el header */
            .kpi-header-pendientes:hover .kpi-title,
            .kpi-header-pendientes:hover .kpi-value,
            .kpi-header-pendientes:hover .kpi-subtitle {
                color: #D69E2E; /* Azul principal */
                transition: color 0.3s ease;
                font-weight: 700;
            }

            .kpi-header-rechazadas {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-rechazadas:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px #C53030;
            }

            /* Cambia el color de los textos internos al hacer hover en el header */
            .kpi-header-rechazadas:hover .kpi-title,
            .kpi-header-rechazadas:hover .kpi-value,
            .kpi-header-rechazadas:hover .kpi-subtitle {
                color: #C53030; /* Azul principal */
                transition: color 0.3s ease;
                font-weight: 700;
            }

            .kpi-header-tiempoPromedio {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-tiempoPromedio:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px #6B46C1;
            }

            /* Cambia el color de los textos internos al hacer hover en el header */
            .kpi-header-tiempoPromedio:hover .kpi-title,
            .kpi-header-tiempoPromedio:hover .kpi-value,
            .kpi-header-tiempoPromedio:hover .kpi-subtitle {
                color: #6B46C1; /* Azul principal */
                transition: color 0.3s ease;
                font-weight: 700;
            }

            .kpi-title { font-size: 14px; color: #4a5568; margin-bottom: 8px; }
            .kpi-value { font-size: 28px; font-weight: 700; color: #2d3748; }
            .kpi-subtitle { font-size: 12px; color: #718096; margin-top: 5px; }

            .charts-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
                gap: 20px;
                margin-bottom: 25px;
            }

            .chart-card {
                background: #ebebeb;
                padding: 25px;
                border-radius: 25px;                
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            }

            .chart-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px rgba(0,0,0,0.15);
            }

            .chart-title {
                font-size: 16px;
                font-weight: 600;
                color: #2d3748;
                margin-bottom: 15px;
            }

            .table-container { overflow-x: auto; margin-top: 10px; }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            th {
                background: #f8fafc;
                padding: 12px;
                font-weight: 600;
                border-bottom: 2px solid #e2e8f0;
                text-align: left;
            }

            td {
                padding: 12px;
                border-bottom: 1px solid #e2e8f0;
            }

            .loading-overlay {
                display: none;
                position: fixed;
                top:0; left:0;
                width:100%; height:100%;
                background: rgba(0,0,0,0.5);
                z-index: 9999;
                justify-content: center;
                align-items: center;
            }

            .loading-overlay.active { display:flex; }

            .spinner {
                width:50px; height:50px;
                border:5px solid #f3f3f3;
                border-top:5px solid #667eea;
                border-radius:50%;
                animation: spin 1s linear infinite;
            }

            @keyframes spin { 0%{transform:rotate(0deg);} 100%{transform:rotate(360deg);} }
        </style>
    </head>
    <body>
            <div class="loading-overlay" id="loadingOverlay">
                <div class="spinner"></div>
            </div>

            <div class="container">
                <div class="header">
                    <div class="logo">
                        <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                        <cfoutput>#usuarioRol#</cfoutput>
                    </div>
                    <h1>📊 Metricas de Permisos y Pases de Salida</h1>
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
                                
                                <!--- Consultar todas las áreas --->
                                <cfquery name="getAreas" datasource="Autorizacion">
                                    SELECT id_area, nombre
                                    FROM area_adscripcion
                                </cfquery>

                                <!--- Iterar sobre la consulta --->
                                <cfoutput query="getAreas">
                                    <option value="#id_area#">#nombre#</option>
                                </cfoutput>
                            </select>
                        </div>
                        <div class="submit-section">
                            <button class="submit-btn-actualizar" id="btnActualizar">
                                🔍 Actualizar
                            </button>
                        </div>
                    </div>   
                    
                    <!-- KPIs -->
                    <div class="section">
                        <div class="field-group">
                            <div class="kpi-header-totalSolicitudes">
                                <div class="kpi-title">Total Solicitudes</div>
                                <div class="kpi-value" id="totalSolicitudes">0</div>
                                <div class="kpi-subtitle">Este período</div>
                            </div>

                            <div class="kpi-header-aprovadas">
                                <div class="kpi-title">Aprobadas</div>
                                <div class="kpi-value" id="solicitudesAprobadas">0</div>
                                <div class="kpi-subtitle" id="solicitudesAprobadasPct">0% de aprobación</div>
                            </div>

                            <div class="kpi-header-pendientes">
                                <div class="kpi-title">Pendientes</div>
                                <div class="kpi-value" id="solicitudesPendientes">0</div>
                                <div class="kpi-subtitle" id="solicitudesPendientesPct">0% de aprobación</div>
                            </div>

                            <div class="kpi-header-rechazadas">
                                <div class="kpi-title">Rechazadas</div>
                                <div class="kpi-value" id="solicitudesRechazadas">0</div>
                                <div class="kpi-subtitle" id="solicitudesRechazadasPct">0% de rechazo</div>
                            </div>

                            <div class="kpi-header-tiempoPromedio">
                                <div class="kpi-title">Tiempo Promedio</div>
                                <div class="kpi-value" id="tiempoPromedio">0 días</div>
                                <div class="kpi-subtitle">Hasta aprobación final</div>
                            </div>
                        </div>
                    </div>

                    <!-- KPI Cards -->
                    <div class="section">
                        <div class="field-group">
                            <div class="kpi-header">
                                <div class="chart-title">Estado de solicitudes</div>
                                <canvas id="chartEstados" height="50"></canvas>
                                Aqui va una grafica de pastel de todas las solicitudes
                            </div>

                            <div class="kpi-header">
                                <div class="chart-title">Por Etapa de Firma</div>
                                <canvas id="chartEtapas" height="250"></canvas>
                                Aqui va una grafica de barras de todas las firmas por etapa
                            </div>
                            
                            <div class="kpi-header">
                                <div class="chart-title">Tendencia de Solicitudes (Por periodo)</div>
                                <canvas id="chartTendencia" height="250"></canvas>
                                Aqui va un grafico de lineas (aprovadas, pendientes, rechazadas)
                            </div>

                            <div class="kpi-header">
                                <div class="chart-title">Solicitudes por Área sleccionada</div>
                                <canvas id="chartAreas" height="250"></canvas>
                                Aqui va un grafico de barras (aprovadas, pendientes, rechazadas) por los diferentes firmantes
                            </div>

                            <div class="kpi-header">
                                <div class="chart-title">Tipos de Permiso por Área selecionada</div>
                                <canvas id="chartTipoPermiso" height="250"></canvas>
                                Aqui va una grafica de barras de los tipos de permiso de las solicitudes
                            </div>

                            <div class="kpi-header">
                                <div class="chart-title">Personal vs Oficial por Area Seleccionada</div>
                                <canvas id="chartTipoSolicitud" height="250"></canvas>
                                Aqui va una grafica de pastel 
                            </div>
                        </div>
                    </div>

                    <!-- prediccion a futuro -->
                    <div class="section">
                        
                            <div class="kpi-header">
                                <div class="chart-title">Predicion a 30 dias por area selecionada</div>
                                <canvas id="chartTipoSolicitud" height="250"></canvas>
                                Grafica de de lineas para predecir las solicitudes
                            </div>
                        
                    </div>

                    <!-- Tablas -->
                    <div class="section">
                        <div class="field-group">
                            <div class="kpi-header">
                                <div class="chart-title">Ranking por Área selecionada</div>
                                <div class="table-container">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Área</th>
                                                <th>Total</th>
                                                <th>Aprobadas</th>
                                                <th>Rechazadas</th>
                                                <th>Pendientes</th>
                                                <th>Tasa Aprobación</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tablaAreasBody">
                                            <tr><td colspan="6" style="text-align: center;">Cargando...</td></tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <div class="kpi-header">
                                <div class="chart-title">Top 10 Solicitantes por area selecionada</div>
                                    <div class="table-container">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>Firmante</th>
                                                    <th>Rol</th>
                                                    <th>Aprovadas</th>
                                                    <th>Rechazadas</th>
                                                    <th>Pendientes</th>
                                                </tr>
                                            </thead>
                                            <tbody id="tablaFirmantesBody">
                                                <tr><td colspan="5" style="text-align: center;>Cargando...</td></tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div> 
            </div>
        </div>

        
        <!--- Carga de jQuery (local o CDN) --->
        <script src="js/jquery-3.6.0.min.js"></script>
        
        <script>
            $(document).ready(function(){

                // Función para actualizar las métricas
                function actualizarMetricas(){
                    let dias = $("#rangoFechas").val();
                    let area = $("#areaSeleccionada").val();

                    if(area === ""){
                        alert("Por favor selecciona un área.");
                        return;
                    }

                    $("#loadingOverlay").addClass("active");

                    $.ajax({
                        url: "obtenerMetricas.cfm",
                        method: "POST",
                        data: { rango: dias, area: area },
                        dataType: "json",
                        success: function(response){
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
                        },
                        error: function(xhr, status, error){
                            console.error("Error al obtener métricas:", error);
                            alert("Hubo un error al cargar las métricas.");
                        },
                        complete: function(){
                            $("#loadingOverlay").removeClass("active");
                        }
                    });
                }

                // Evento del botón
                $("#btnActualizar").click(function(){
                    actualizarMetricas();
                });

                // Opcional: cargar métricas automáticamente al cargar la página
                // actualizarMetricas();
            });
        </script>

    


    </body>
</html>