<!---
 * Página `pendientesFirmar.cfm` para la gestión de solicitudes en espera de firma.
 *
 * Funcionalidad:
 * - Muestra la lista de solicitudes enviadas a cuentas con rol de firma.
 * - Cada solicitud puede ser aceptada o rechazada por el firmante.
 * - Una vez firmada (aceptada o rechazada), la solicitud se procesa y se almacena en la base de datos.
 * - Las solicitudes ya firmadas dejan de mostrarse en esta lista.
 *
 * Uso:
 * - Página destinada al flujo de revisión y firma de solicitudes por parte de las autoridades correspondientes.
--->
<!--- Evitar error si form.search no existe --->
<cfif structKeyExists(form, "search")>
    <cfset searchTerm = trim(form.search)>
<cfelse>
    <cfset searchTerm = "">
</cfif>

<!-- Determinar el filtro según el rol -->
<cfset filtroRol = "">

<cfif session.rol EQ "Jefe">
    <cfset filtroRol = "AND du.id_area = " & session.id_area>

<cfelseif session.rol EQ "RecursosHumanos">
    <!--- 
        El rol "RecursosHumanos" es un rol de firmante especial (no es Jefe ni Solicitante)
        Este usuario puede ver TODAS las solicitudes que ya fueron aprobadas por los Jefes de área
        Independientemente de su área de adscripción
    --->
    <cfset filtroRol = "
        AND EXISTS (
            SELECT 1 FROM firmas f2
            WHERE f2.id_solicitud = s.id_solicitud
            AND f2.rol = 'Jefe'
            AND f2.aprobado = 'Aprobado'
        )">

<cfelseif session.rol EQ "Autorizacion">
    <cfset filtroRol = "
        AND EXISTS (
            SELECT 1 FROM firmas f3
            WHERE f3.id_solicitud = s.id_solicitud
            AND f3.rol = 'RecursosHumanos'
            AND f3.aprobado = 'Aprobado'
        )">

<cfelseif session.rol EQ "Expediente">
    <cfset filtroRol = "
        AND EXISTS (
            SELECT 1 FROM firmas f4
            WHERE f4.id_solicitud = s.id_solicitud
            AND f4.rol = 'Autorizacion'
            AND f4.aprobado = 'Aprobado'
        )">

<cfelseif session.rol EQ "Solicitante">
    <cfset filtroRol = "AND 1=0">
</cfif>
<cfparam name="form.search" default="">
<!-- Consulta principal -->
<cfquery name="qPendientes" datasource="autorizacion">
    SELECT s.id_solicitud, s.motivo, s.tipo_permiso, s.fecha,
           du.nombre, du.apellido_paterno, du.apellido_materno,
           aa.nombre AS area_nombre
    FROM solicitudes s
    INNER JOIN datos_usuario du ON s.id_solicitante = du.id_datos
    INNER JOIN usuarios u ON s.id_solicitante = u.id_usuario
    INNER JOIN area_adscripcion aa ON du.id_area = aa.id_area
    LEFT JOIN firmas f ON s.id_solicitud = f.id_solicitud 
        AND f.rol = <cfqueryparam value="#session.rol#" cfsqltype="cf_sql_varchar">
    WHERE u.activo = 1
    AND (f.id_firma IS NULL OR f.aprobado = 'Pendiente')
    #PreserveSingleQuotes(filtroRol)#
    
    <cfif len(trim(form.search))>
        AND (
            du.nombre LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR du.apellido_paterno LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR du.apellido_materno LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR aa.nombre LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR s.motivo LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR s.tipo_permiso LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
        )
    </cfif>

    ORDER BY s.fecha DESC
</cfquery>

<cfparam name="form.search" default="">

<!-- Consulta principal -->
<cfquery name="qPendientes" datasource="autorizacion">
    SELECT s.id_solicitud, s.motivo, s.tipo_permiso, s.fecha,
           du.nombre, du.apellido_paterno, du.apellido_materno,
           aa.nombre AS area_nombre
    FROM solicitudes s
    INNER JOIN datos_usuario du ON s.id_solicitante = du.id_datos
    INNER JOIN usuarios u ON s.id_solicitante = u.id_usuario
    INNER JOIN area_adscripcion aa ON du.id_area = aa.id_area
    LEFT JOIN firmas f ON s.id_solicitud = f.id_solicitud 
        AND f.rol = <cfqueryparam value="#session.rol#" cfsqltype="cf_sql_varchar">
    WHERE u.activo = 1
    AND (f.id_firma IS NULL OR f.aprobado = 'Pendiente')
    #PreserveSingleQuotes(filtroRol)#
    
    <cfif len(trim(form.search))>
        AND (
            du.nombre LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR du.apellido_paterno LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR du.apellido_materno LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR aa.nombre LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR s.motivo LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR s.tipo_permiso LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
        )
    </cfif>

    ORDER BY s.fecha DESC
</cfquery>

<!DOCTYPE html>
<html lang="es">
    <head>
        <!-- Metadatos y enlaces a estilos -->
        <meta charset="UTF-8">
        <!-- Vista adaptable para dispositivos móviles -->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Título de la página -->
        <title>Solicitudes Pendientes de Firma</title>
        <!-- Enlace a fuentes y hojas de estilo -->
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/pendientesFirmar.css">
        <link rel="stylesheet" href="css/tablas.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!--- Verificación de sesión y rol --->
        <cfif NOT structKeyExists(session, "rol") 
            OR ListFindNoCase("Expediente,RecursosHumanos,Autorizacion,Jefe", session.rol) EQ 0>
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
<cfset totalRecords = qPendientes.recordCount>
<cfset totalPages = ceiling(totalRecords / rowsPerPage)>
<cfset endRow = min(startRow + rowsPerPage - 1, totalRecords)>

<!-- Subconsulta para mostrar solo las filas de la página actual -->
<cfquery dbtype="query" name="qPaged">
    SELECT *
    FROM qPendientes
</cfquery>

        <div class="container">
            <div class="header">
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <h1>Solicitudes Pendientes de Firma</h1>
            </div>

            <div class="form-container">
                <!-- Formulario de búsqueda -->
                <form method="post" action="pendientesFirmar.cfm" class="field-group single">
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
                                class="form-input-general" placeholder="Solicitante, Area, Motivo, Tipo permiso">
                        </cfoutput>
                    </div>

                    <!-- Botón de búsqueda -->
                    <button type="submit" class="submit-btn-buscar">
                        Buscar
                    </button>
                </form>

                <cfif qPendientes.recordcount eq 0>
                    <div class="section">
                        <p>No tienes solicitudes pendientes de firma.</p>
                    </div>
                <cfelse>
                    <div class="section">
                        <div class="section-title">Listado de Solicitudes</div>
                        <table class="tabla">
                            <thead>
                                <tr class="titulos-tabla">
                                    <th class="titulo-general-centrado">ID Solicitud</th>
                                    <th class="titulo-general">Solicitante</th>
                                    <th class="titulo-general">Área</th>
                                    <th class="titulo-general">Motivo</th>
                                    <th class="titulo-general">Tipo de Permiso</th>
                                    <th class="titulo-general-centrado">Fecha</th>
                                    <th class="titulo-general-centrado">Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfoutput query="qPaged" startrow="#startRow#" maxrows="#rowsPerPage#">
                                    <tr>
                                        <td class="titulo-general-centrado">#id_solicitud#</td>
                                        <td>#nombre# #apellido_paterno# #apellido_materno#</td>
                                        <td>#area_nombre#</td>
                                        <td>#motivo#</td>
                                        <td>#tipo_permiso#</td>
                                        <td class="titulo-general-centrado">#DateFormat(fecha,'yyyy-mm-dd')#</td>
                                        <td class="titulo-general-centrado">
                                            <form method="get" action="firmarSolicitud.cfm">
                                                <input type="hidden" name="id_solicitud" value="#id_solicitud#">
                                                <button type="submit" class="submit-btn-firmar">Firmar</button>
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
                                    <a href="pendientesFirmar.cfm?page=#prevPage#&search=#urlEncodedFormat(form.search)#"
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
                                        <a href="pendientesFirmar.cfm?page=#i#&search=#urlEncodedFormat(form.search)#" 
                                            class="submit-btn-paginacion" style="text-decoration:none">#i#</a>
                                    </cfoutput>
                                </cfif>
                            </cfloop>

                            <!-- Botón 'Siguiente' si hay más bloques -->
                            <cfif endPage LT totalPages>
                                <cfset nextPage = endPage + 1>
                                <cfoutput>
                                    <a href="pendientesFirmar.cfm?page=#nextPage#&search=#urlEncodedFormat(form.search)#"
                                        class="submit-btn-siguiente"
                                        style="text-decoration:none">Siguiente &raquo;</a>
                                </cfoutput>
                            </cfif>
                        </cfif>
                    </div>

                    </div>
                </cfif>

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
