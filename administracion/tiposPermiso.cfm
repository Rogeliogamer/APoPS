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
        <title>Grafica - Tipos de Permiso</title>
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
                        <div class="chart-title">Tipos de Permiso por Área seleccionada</div>
                        <canvas id="chartTipoPermiso" height="250"></canvas>
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
            Grafica -> 5
            Grafica -> Tipos de Permiso por Área Seleccionada
        --->
        <script>
            document.getElementById("btnActualizar").addEventListener("click", function () {
                const idArea = document.getElementById("areaSeleccionada").value;
                const rangoDias = document.getElementById("rangoFechas").value;

                if (!idArea) {
                    alert("Por favor selecciona un área.");
                    return;
                }

                // Llamada AJAX a obtener_tipos_permiso.cfm
                fetch(`../apis/obtenerTiposPermiso.cfm?id_area=${idArea}&rangoDias=${rangoDias}`)
                .then(response => response.json())
                .then(data => {
                    console.log("Respuesta de permisos:", data);

                    const ctx = document.getElementById("chartTipoPermiso").getContext("2d");

                    // Si existe una gráfica previa, destruirla
                    if (window.graficoTipoPermiso) {
                        window.graficoTipoPermiso.destroy();
                    }

                    // Validar si hay datos
                    if (!data.tiposPermiso || data.tiposPermiso.length === 0) {
                        ctx.font = "16px Arial";
                        ctx.fillText("No hay datos disponibles para el área seleccionada.", 50, 100);
                        return;
                    }

                    // Preparar datos para la gráfica
                    const labels = data.tiposPermiso.map(item => item.tipo_permiso);
                    const valores = data.tiposPermiso.map(item => item.cantidad);

                    // Crear gráfica
                    window.graficoTipoPermiso = new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: labels,
                            datasets: [{
                                label: 'Cantidad de Solicitudes',
                                data: valores,
                                borderWidth: 1
                            }]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: { 
                                    display: true 
                                },
                                title: {
                                    display: true,
                                    text: 'Tipos de Permiso por Área Seleccionada'
                                }
                            },
                            scales: {
                                y: { beginAtZero: true }
                            }
                        }
                    });
                })
                .catch(err => {
                    console.error("Error al obtener los tipos de permiso:", err);
                });
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