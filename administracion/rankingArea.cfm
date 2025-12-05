<!---
 * Nombre de la pagina: administracion/rankingArea.cfm
 * 
 * Descripción:
 * Esta página muestra métricas y gráficos relacionados con las áreas de adscripción.
 * Permite filtrar datos por rango de fechas y área específica.
 * Utiliza Chart.js para representar visualmente las predicciones de solicitudes.
 * Incluye validaciones de sesión y rol para asegurar que solo administradores accedan.
 * Contiene scripts para manejar la interacción del usuario y la actualización de gráficos.
 * Presenta un diseño responsivo y moderno con CSS personalizado.
 * 
 * Roles:
 * Admin: Acceso completo para ver métricas y gráficos de áreas.
 * 
 * Paginas relacionadas:
 * menu.cfm: Panel principal del sistema.
 * adminPanel.cfm: Panel de administración.
 * cerrarSesion.cfm: Cierre de sesión del usuario.
 * jquery-3.6.0.min.js: Biblioteca jQuery para manipulación del DOM y AJAX.
 * obtenerMetricasRanking.cfm: API para obtener datos de métricas de ranking por área.
 * https://cdn.jsdelivr.net/npm/chart.js: Biblioteca Chart.js para gráficos.
 * metricas.js: Script personalizado para manejar métricas.
 * graficasKPI.js: Script personalizado para gráficos KPI.
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
                <h1>Ranking Areas</h1>
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
                            <cfif ListFindNoCase("Admin,RecursosHumanos", session.rol)>
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
            Sección -> 5
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