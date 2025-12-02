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
        <title>Tabla - Ranking de areas</title>
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

                <!-- Tablas -->
                <div class="section">
                    <div class="row">
                        <div class="kpi-header col-12">
                            <div class="chart-title mb-2">
                                Ranking por Área seleccionada
                            </div>
                            <div class="table-container table-responsive">
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
                    </div> 
                </div>
            </div> 
        </div>

        <!--- Carga de jQuery (local o CDN) --->
        <script src="js/jquery-3.6.0.min.js"></script>

        <!---
            Seccion -> 5
            Tabla -> 1
            Tabla -> Ranking por Área
        --->
        <script>
            document.getElementById("btnActualizar").addEventListener("click", function(e) {
                e.preventDefault();

                // Obtener valores del formulario
                const rango = document.getElementById("rangoFechas").value;
                const area = document.getElementById("areaSeleccionada").value;

                // Mostrar mensaje de carga
                document.getElementById("tablaAreasBody").innerHTML =
                    '<tr><td colspan="6" style="text-align:center;">Cargando...</td></tr>';

                // Llamar al archivo CFM que genera la tabla
                fetch("../apis/obtenerMetricasRanking.cfm", {
                    method: "POST",
                    headers: { 
                        "Content-Type": "application/x-www-form-urlencoded" 
                    },
                    body: `rangoFechas=${rango}&areaSeleccionada=${area}`
                })
                .then(response => response.text())
                .then(html => {
                    document.getElementById("tablaAreasBody").innerHTML = html;
                })
                .catch(err => {
                    console.error(err);
                    document.getElementById("tablaAreasBody").innerHTML =
                        '<tr><td colspan="6" style="text-align:center;color:red;">Error al cargar los datos</td></tr>';
                });
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