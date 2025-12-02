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

<!--- Lógica de manejo de parámetros y búsqueda --->
<cfscript>
    <!--- 1. Valores por defecto --->
    param name="url.page" default="1";
    param name="url.search" default="";
    param name="form.search" default="";

    <!--- 2. Lógica de prioridad MANUAL: --->
    <!--- Si se envió el formulario (POST) y tiene texto, úsalo. --->
    if (len(trim(form.search)) GT 0) {
        searchTerm = trim(form.search);
    } 
    <!--- Si no, revisa si viene en la URL (GET) de la paginación --->
    else if (len(trim(url.search)) GT 0) {
        searchTerm = trim(url.search);
    } 
    <!--- Si no hay nada, cadena vacía --->
    else {
        searchTerm = "";
    }
</cfscript>

<!--- Filtro de área según el rol del usuario en sesión --->
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

<!--- Consulta para obtener las solicitudes firmadas por el usuario en sesión --->
<cfquery name="qFirmados" datasource="autorizacion">
    SELECT s.id_solicitud,
        CONCAT(d.nombre, ' ', d.apellido_paterno, ' ', d.apellido_materno) AS solicitante,
        s.tipo_solicitud,
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
                OR s.tipo_solicitud LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                OR u.rol LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                OR f.aprobado LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            )
        </cfif>
    GROUP BY s.id_solicitud
    ORDER BY s.id_solicitud DESC
</cfquery>

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
        <title>Solicitudes Firmadas</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/firmados.css">
        <link rel="stylesheet" href="../css/tablas.css">
        <link rel="stylesheet" href="../css/botones.css">
    </head>
    <body>
        <!--- Verificación de sesión y rol --->
        <cfif NOT structKeyExists(session, "rol") OR len(trim(session.rol)) EQ 0>
            <!--- No hay sesión activa o rol definido --->
            <cflocation url="login.cfm" addtoken="no">
        <cfelseif ListFindNoCase("Expediente,RecursosHumanos,Autorizacion,Jefe,Solicitante", trim(session.rol)) EQ 0>
            <!--- Rol no autorizado para esta sección --->
            <cflocation url="menu.cfm" addtoken="no">
        </cfif>

        <!--- Configuración de paginación --->
        <cfset rowsPerPage = 10>
        <!--- Página actual y cálculo de filas --->
        <cfset currentPage = val(url.page)>
        <!--- Asegurar que la página actual sea al menos 1 --->
        <cfif currentPage LTE 0><cfset currentPage = 1></cfif>
        <!--- Calcular la fila inicial para la consulta --->
        <cfset startRow = (currentPage - 1) * rowsPerPage + 1>

        <!--- Calcular totales --->
        <cfset totalRecords = qFirmados.recordCount>
        <!--- Calcular total de páginas --->
        <cfset totalPages = ceiling(totalRecords / rowsPerPage)>
        <!--- Calcular fila final --->
        <cfset endRow = min(startRow + rowsPerPage - 1, totalRecords)>

        <!--- Subconsulta para mostrar solo las filas de la página actual --->
        <cfquery dbtype="query" name="qPaged">
            SELECT *
            FROM qFirmados
            ORDER BY s.id_solicitud DESC
        </cfquery>

        <!--- Contenido de la página --->
        <div class="container">
            <!--- Encabezado con logo y título --->
            <div class="header">
                <!--- Logo y rol del usuario --->
                <div class="logo">
                    <!--- Incluir el logo de la aplicación --->
                    <cfset usuarioRol = createObject("component", "../componentes/usuarioConectadoSSoli").render()>
                    <!--- Mostrar el rol del usuario --->
                    <cfoutput>
                        #usuarioRol#
                    </cfoutput>
                </div>

                <!--- Título de la página --->
                <h1>Solicitudes ya firmadas</h1>
            </div>

            <!--- Contenedor del formulario y tabla --->
            <div class="form-container">
                <!--- Formulario de búsqueda --->
                <form method="post" action="firmados.cfm" class="field-group single">
                    <!--- Campo de búsqueda --->
                    <div class="form-field">
                        <!--- Etiqueta y campo de entrada --->
                        <label class="form-label">
                            Buscar:
                        </label>
                        <cfoutput>
                            <input type="text" 
                                name="search" 
                                value="#encodeForHTMLAttribute(form.search)#" 
                                class="form-input-general" 
                                placeholder="Solicitante, Tipo permiso, solicitud, Rol">
                        </cfoutput>
                    </div>

                    <!--- Botón de búsqueda --->
                    <button type="submit" class="submit-btn-buscar">
                        Buscar
                    </button>
                </form>

                <!--- Sección de la tabla de solicitudes firmadas --->
                <div class="section">
                    <!--- Título de la sección --->
                    <h2 class="section-title">Listado de solicitudes con firma</h2>

                    <!--- Tabla de solicitudes firmadas --->
                    <div class="table-responsive-custom">
                        <!--- Tabla con estilos personalizados --->
                        <table class="tabla">
                            <!--- Encabezado de la tabla --->
                            <thead>
                                <!--- Fila de títulos --->
                                <tr class="titulos-tabla">
                                    <!--- Títulos de las columnas --->
                                    <th class="titulo-general">ID Solicitud</th>
                                    <th class="titulo-general">Solicitante</th>
                                    <th class="titulo-general">Tipo Solicitud</th>
                                    <th class="titulo-general">Tipo Permiso</th>
                                    <th class="titulo-general">Fecha Solicitud</th>
                                    <th class="titulo-general-centrado">Rol</th>
                                    <th class="titulo-general">Estado</th>
                                    <th class="titulo-general-centrado">Acciones</th>
                                </tr>
                            </thead>
                            <!--- Cuerpo de la tabla --->
                            <tbody>
                                <!--- Recorrer las filas paginadas --->
                                <cfoutput query="qPaged" startrow="#startRow#" maxrows="#rowsPerPage#">
                                    <!--- Fila de datos --->
                                    <tr>
                                        <!--- Datos de cada columna --->
                                        <td class="titulo-general-centrado">#id_solicitud#</td>
                                        <td>#solicitante#</td>
                                        <td>#tipo_solicitud#</td>
                                        <td>#tipo_permiso#</td>
                                        <td class="titulo-general-centrado">#DateFormat(fecha,'dd/mm/yyyy')#</td>
                                        <td>#rol_solicitante#</td>
                                        <td>
                                            <!--- Mostrar el estado con estilos según su valor --->
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
                                        <td style="text-align:center;">
                                            <!--- Formulario para ver detalles de la solicitud --->
                                            <form action="solicitudDetalles.cfm" method="post">
                                                <input type="hidden" name="id_solicitud" value="#id_solicitud#">
                                                <button type="submit" class="submit-btn-verDetalles">Ver Detalles</button>
                                            </form>
                                        </td>
                                    </tr>
                                </cfoutput>
                            </tbody>
                        </table>
                    </div>

                    <!--- Paginación en bloques de 10 --->
                    <div class="submit-section">
                        <!--- Contenedor de la paginación --->
                        <cfif totalPages GT 1>
                            <!--- Tamaño del bloque de páginas --->
                            <cfset blockSize = 10>
                            <!--- Bloque actual --->
                            <cfset currentBlock = ceiling(currentPage / blockSize)>
                            <!--- Página inicial y final del bloque --->
                            <cfset startPage = ((currentBlock - 1) * blockSize) + 1>
                            <!--- Asegurar que la página final no exceda el total de páginas --->
                            <cfset endPage = min(startPage + blockSize - 1, totalPages)>

                            <!--- Botón 'Anterior' si hay bloques previos --->
                            <cfif startPage GT 1>
                                <!--- Calcular la página anterior --->
                                <cfset prevPage = startPage - 1>
                                <!--- Enlace al bloque anterior --->
                                <cfoutput>
                                    <a href="firmados.cfm?page=#prevPage#&search=#urlEncodedFormat(searchTerm)#"
                                        class="submit-btn-anterior"
                                        style="text-decoration:none">&laquo; Anterior</a>
                                </cfoutput>
                            </cfif>

                            <!--- Números del bloque actual --->
                            <cfloop from="#startPage#" to="#endPage#" index="i">
                                <!--- Resaltar la página actual --->
                                <cfif i EQ currentPage>
                                    <!--- Botón deshabilitado para la página actual --->
                                    <cfoutput>
                                        <button class="submit-btn-paginacion-disabled" disabled>#i#</button>
                                    </cfoutput>
                                <cfelse>
                                    <!--- Botón para otras páginas --->
                                    <cfoutput>
                                        <a href="firmados.cfm?page=#i#&search=#urlEncodedFormat(searchTerm)#" 
                                            class="submit-btn-paginacion" style="text-decoration:none">#i#</a>
                                    </cfoutput>
                                </cfif>
                            </cfloop>

                            <!--- Botón 'Siguiente' si hay más bloques --->
                            <cfif endPage LT totalPages>
                                <!--- Calcular la siguiente página --->
                                <cfset nextPage = endPage + 1>
                                <!--- Enlace al siguiente bloque --->
                                <cfoutput>
                                    <a href="firmados.cfm?page=#nextPage#&search=#urlEncodedFormat(searchTerm)#"
                                        class="submit-btn-siguiente"
                                        style="text-decoration:none">Siguiente &raquo;</a>
                                </cfoutput>
                            </cfif>
                        </cfif>
                    </div>
                </div>

                <!--- Sección de botones de menú y cerrar sesión --->
                <div class="submit-section">
                    <!--- Grupo de botones --->
                    <div class="field-group">
                        <!--- botón para regresar al menú --->
                        <a href="../menu.cfm" class="submit-btn-menu submit-btn-menu-text">
                            Menu
                        </a>
                    
                        <!--- botón para cerrar sesión --->
                        <a href="../cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
