<!---
 * Página `firmados.cfm` para la visualización de solicitudes emitidas.
 *
 * Funcionalidad:
 * - Muestra un listado de las solicitudes emitidas por el usuario autenticado.
 * - Presenta información general, el estado de cada solicitud y un botón para ver más detalles.
 * - El botón de "ver más detalles" permite acceder a toda la información de la solicitud seleccionada.
 *
 * Uso:
 * - Página destinada al seguimiento y revisión de solicitudes emitidas por el usuario.
--->
<!--- Evitar error si form.search no existe --->
<cfif structKeyExists(form, "search")>
    <cfset searchTerm = trim(form.search)>
<cfelse>
    <cfset searchTerm = "">
</cfif>

<cfif session.rol EQ "Solicitante">
    <!--- Los Solicitantes solo ven sus propias solicitudes --->
    <cfset filtroArea = "AND s.id_solicitante = " & session.id_usuario>
<cfelseif session.rol EQ "Jefe">
    <!--- Los Jefes solo ven solicitudes de su área --->
    <cfset filtroArea = "AND d.id_area = " & session.id_area>
<cfelseif session.rol EQ "RecursosHumanos" OR session.rol EQ "Autorizacion" OR session.rol EQ "Expediente">
    <!--- Estos roles ven solicitudes de todas las áreas --->
    <cfset filtroArea = "">
</cfif>

<cfquery name="qFirmados" datasource="autorizacion">
    SELECT 
        s.id_solicitud,
        CONCAT(d.nombre, ' ', d.apellido_paterno, ' ', d.apellido_materno) AS solicitante,
        s.tipo_solicitud,
        s.motivo,
        s.tipo_permiso,
        s.fecha,
        s.tiempo_solicitado,
        s.hora_salida,
        s.hora_llegada,
        s.status_final,
        u.rol AS rol_solicitante,
        f.aprobado,
        f.fecha_firma
    FROM solicitudes s
    INNER JOIN firmas f ON s.id_solicitud = f.id_solicitud
    INNER JOIN usuarios u ON s.id_solicitante = u.id_usuario
    INNER JOIN datos_usuario d ON u.id_datos = d.id_datos
    WHERE f.id_usuario = <cfqueryparam value="#session.id_usuario#" cfsqltype="cf_sql_integer">
        AND u.activo = 1
        AND f.fecha_firma IS NOT NULL
        #PreserveSingleQuotes(filtroArea)#
    <!--- Filtro dinámico de búsqueda --->
    <cfif len(searchTerm)>
        AND (
            d.nombre LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR d.apellido_paterno LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR d.apellido_materno LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR s.tipo_permiso LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR s.motivo LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR u.rol LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR f.aprobado LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
        )
    </cfif>
    ORDER BY f.fecha_firma DESC
</cfquery>

<!DOCTYPE html>
<html lang="es">
    <head>
        <!-- Metadatos y enlaces a estilos -->
        <meta charset="UTF-8">
        <!-- Vista adaptable para dispositivos móviles -->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Título de la página -->
        <title>Solicitudes Firmadas</title>
        <!-- Enlace a fuentes y hojas de estilo -->
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/firmados.css">
        <link rel="stylesheet" href="css/tablas.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!--- Verificación de sesión y rol --->
        <cfif NOT structKeyExists(session, "rol") 
            OR ListFindNoCase("Expediente,RecursosHumanos,Autorizacion,Jefe,Solicitante", session.rol) EQ 0>
            <!--- Redirigir al usuario si no está autorizado --->
            <cflocation url="menu.cfm" addtoken="no">
        </cfif>

<!-- Parámetros de URL y formulario -->
<cfparam name="url.page" default="1">
<cfparam name="form.search" default="">

<!-- Configuración de paginación -->
<cfset rowsPerPage = 10>
<cfset currentPage = val(url.page)>
<cfif currentPage LTE 0><cfset currentPage = 1></cfif>
<cfset startRow = (currentPage - 1) * rowsPerPage + 1>

<!-- Calcular totales -->
<cfset totalRecords = qFirmados.recordCount>
<cfset totalPages = ceiling(totalRecords / rowsPerPage)>
<cfset endRow = min(startRow + rowsPerPage - 1, totalRecords)>

<!-- Subconsulta para mostrar solo las filas de la página actual -->
<cfquery dbtype="query" name="qPaged">
    SELECT *
    FROM qFirmados
</cfquery>

        <div class="container">
            <div class="header">
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                        <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <h1>Solicitudes ya firmadas</h1>
            </div>

            <div class="form-container">
<!-- Formulario de búsqueda -->
                <form method="post" action="firmados.cfm" class="field-group single">
                    <!-- Campo de búsqueda -->
                    <div class="form-field">
                        <!-- Etiqueta y campo de entrada -->
                        <label class="form-label">
                            Buscar:
                        </label>
                        <!-- Campo de texto -->
                        <cfoutput>
                            <!-- Mantener el valor ingresado en el campo de búsqueda -->
                            <input type="text" name="search" value="#encodeForHTMLAttribute(form.search)#" 
                                class="form-input-general" placeholder="Solicitante, Tipo permiso, Motivo, Rol">
                        </cfoutput>
                    </div>

                    <!-- Botón de búsqueda -->
                    <button type="submit" class="submit-btn-buscar">
                        Buscar
                    </button>
                </form>

                <div class="section">
                    <h2 class="section-title">Listado de solicitudes con firma</h2>

                    <table class="tabla">
                        <thead>
                            <tr class="titulos-tabla">
                                <th class="titulo-general">ID Solicitud</th>
                                <th class="titulo-general">Solicitante</th>
                                <th class="titulo-general">Motivo</th>
                                <th class="titulo-general">Tipo Permiso</th>
                                <th class="titulo-general">Fecha Solicitud</th>
                                <th class="titulo-general-centrado">Rol</th>
                                <th class="titulo-general">Estado</th>
                                <th class="titulo-general">Fecha Firma</th>
                                <th class="titulo-general-centrado">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="qPaged" startrow="#startRow#" maxrows="#rowsPerPage#">
                                <tr>
                                    <td class="titulo-general-centrado">#id_solicitud#</td>
                                    <td>#solicitante#</td>
                                    <td>#motivo#</td>
                                    <td>#tipo_permiso#</td>
                                    <td class="titulo-general-centrado">#DateFormat(fecha,'dd/mm/yyyy')#</td>
                                    <td>#rol_solicitante#</td>
                                    <td>
                                        <cfif status_final EQ "Aprobado">
                                            <span class="status-aprobado">✔ #status_final#</span>
                                        <cfelseif status_final EQ "Rechazado">
                                            <span class="status-rechazado">✘ #status_final#</span>
                                        <cfelseif status_final EQ "Pendiente">
                                            <span class="status-pendiente">⏳ #status_final#</span>
                                        <cfelse>
                                            <span class="status-desconocido">#status_final#</span>
                                        </cfif>
                                    </td>
                                    <td class="titulo-general-centrado">#DateFormat(fecha_firma,'dd/mm/yyyy')#</td>
                                    <td style="text-align:center;">
                                        <form action="solicitudDetalles.cfm" method="post">
                                            <input type="hidden" name="id_solicitud" value="#id_solicitud#">
                                            <button type="submit" class="submit-btn-verDetalles">Ver Detalles</button>
                                        </form>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>

<!-- Paginación en bloques de 10-->
                    <div class="submit-section">
                        <!-- Contenedor de la paginación -->
                        <cfif totalPages GT 1>
                            <!-- Tamaño del bloque de páginas -->
                            <cfset blockSize = 10>
                            <!-- Bloque actual -->
                            <cfset currentBlock = ceiling(currentPage / blockSize)>
                            <!-- Página inicial y final del bloque -->
                            <cfset startPage = ((currentBlock - 1) * blockSize) + 1>
                            <cfset endPage = min(startPage + blockSize - 1, totalPages)>

                            <!-- Botón 'Anterior' si hay bloques previos -->
                            <cfif startPage GT 1>
                                <cfset prevPage = startPage - 1>
                                <cfoutput>
                                    <a href="firmados.cfm?page=#prevPage#&search=#urlEncodedFormat(form.search)#"
                                        class="submit-btn-anterior"
                                        style="text-decoration:none">&laquo; Anterior</a>
                                </cfoutput>
                            </cfif>

                            <!-- Números del bloque actual -->
                            <cfloop from="#startPage#" to="#endPage#" index="i">
                                <cfif i EQ currentPage>
                                    <!-- Botón deshabilitado para la página actual -->
                                    <cfoutput>
                                        <button class="submit-btn-paginacion-disabled" disabled>#i#</button>
                                    </cfoutput>
                                <cfelse>
                                    <!-- Botón para otras páginas -->
                                    <cfoutput>
                                        <a href="firmados.cfm?page=#i#&search=#urlEncodedFormat(form.search)#" 
                                            class="submit-btn-paginacion" style="text-decoration:none">#i#</a>
                                    </cfoutput>
                                </cfif>
                            </cfloop>

                            <!-- Botón 'Siguiente' si hay más bloques -->
                            <cfif endPage LT totalPages>
                                <cfset nextPage = endPage + 1>
                                <cfoutput>
                                    <a href="firmados.cfm?page=#nextPage#&search=#urlEncodedFormat(form.search)#"
                                        class="submit-btn-siguiente"
                                        style="text-decoration:none">Siguiente &raquo;</a>
                                </cfoutput>
                            </cfif>
                        </cfif>
                    </div>


                </div>
                <div class="submit-section">
                    <div class="field-group">
                        <!-- Enlace para regresar al menú principal -->
                        <a href="menu.cfm" class="submit-btn-menu submit-btn-menu-text">
                            Menu
                        </a>
                    
                        <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
