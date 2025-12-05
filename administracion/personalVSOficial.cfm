<!---
 * Nombre de la pagina: administracion/personalVSOficial.cfm
 * 
 * Descripción:
 * Esta página muestra una gráfica comparativa entre el personal
 * autorizado y el personal oficial en función del área seleccionada
 * y el rango de fechas.
 * 
 * Roles:
 * Admin: Acceso completo para ver métricas de personal.
 * 
 * Paginas relacionadas:
 * menu.cfm: Panel principal del sistema.
 * adminPanel.cfm: Panel de administración.
 * cerrarSesion.cfm: Cierre de sesión del usuario.
 * jquery-3.6.0.min.js: Biblioteca jQuery para manipulación del DOM y AJAX.
 * obtenerPersonalVSOficial.cfm: API para obtener datos de personal vs oficial.
 * https://cdn.jsdelivr.net/npm/chart.js: Biblioteca Chart.js para crear gráficos.
 * metricas.js: Script personalizado para manejar métricas.
 * graficasKPI.js: Script personalizado para manejar gráficas KPI.
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
        <title>Grafica - Personal VS Oficial</title>
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
                <h1>Personal VS Oficial</h1>
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
                    <div class="kpi-header container-fluid px-2 px-md-3">
                        <div class="chart-title text-center text-md-start">
                            Personal vs Oficial por Area Seleccionada
                        </div>
                        <div style="position: relative; height: 250px; width: 100%;">
                            <canvas id="chartTipoSolicitud"></canvas>
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
        <script src="../js/jquery-3.6.0.min.js"></script>

        <!---
            Sección -> 3
            Grafica -> 6
            Grafica -> Personal VS Oficial por Área Seleccionada
        --->
        <script>
            $('#btnActualizar').on('click', function(e) {
                e.preventDefault();

                const rango = $('#rangoFechas').val();
                const area = $('#areaSeleccionada').val();

                if(!area) {
                    alert("Por favor, selecciona un área.");
                    return;
                }

                $.ajax({
                    url: '../apis/obtenerPersonalVSOficial.cfm',
                    method: 'GET',
                    data: { 
                        rango: rango, 
                        area: area 
                    },
                    dataType: 'json',
                    success: function(response) {
                        console.log("Datos recibidos:", response);

                        const labels = response.TIPOSSOLICITUD.map(item => item.TIPO);
                        const cantidades = response.TIPOSSOLICITUD.map(item => item.CANTIDAD);

                        if (labels.length === 0) {
                            $('#chartTipoSolicitud').hide();
                            $('#chartTipoSolicitud').after('<div>No hay datos disponibles para el área seleccionada.</div>');
                            return;
                        }

                        $('#chartTipoSolicitud').show();
                        
                        // Limpiar canvas anterior si existe
                        if (window.tipoSolicitudChart) {
                            window.tipoSolicitudChart.destroy();
                        }

                        const ctx = document.getElementById('chartTipoSolicitud').getContext('2d');
                        window.tipoSolicitudChart = new Chart(ctx, {
                            type: 'pie',
                            data: {
                                labels: labels,
                                datasets: [{
                                    data: cantidades,
                                    backgroundColor: ['#36A2EB', '#FF6384'],
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: { 
                                        position: 'bottom' 
                                    }
                                }
                            }
                        });
                    },
                    error: function(err) {
                        console.error(err);
                        alert("Ocurrió un error al cargar la gráfica.");
                    }
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