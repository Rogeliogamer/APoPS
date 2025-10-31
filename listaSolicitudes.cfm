<!---
 * Página `listaSolicitudes.cfm` para la visualización de solicitudes firmadas.
 *
 * Funcionalidad:
 * - Muestra un listado de las solicitudes firmadas por el usuario autenticado.
 * - Permite consultar información general y el estado actual de la firma.
 * - Incluye un botón que permite acceder a los detalles completos de cada solicitud.
 *
 * Uso:
 * - Página destinada al seguimiento de solicitudes firmadas por el usuario logueado.
--->

<!--- Evita errores si no existe form.search --->
<cfif structKeyExists(form, "search")>
    <cfset searchTerm = trim(form.search)>
<cfelse>
    <cfset searchTerm = "">
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
        AND u.activo = '1'
    <!--- Filtro de búsqueda si hay texto --->
    <cfif len(searchTerm)>
        AND (
            d.nombre LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR d.apellido_paterno LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR d.apellido_materno LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR s.motivo LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR s.tipo_permiso LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR s.status_final LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR f.rol LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR f.aprobado LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
        )
    </cfif>
    ORDER BY f.fecha_firma DESC
</cfquery>

<!DOCTYPE html>
<html lang="es">
    <head>
        <!--- Metadatos y enlaces a estilos --->
        <meta charset="UTF-8">
        <!--- Vista adaptable para dispositivos móviles --->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!--- Icono de la pagina --->
        <link rel="icon" href="elements/icono.ico" type="image/x-icon">
        <!--- Título de la página --->
        <title>Solicitudes Firmadas</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/tablas.css">
        <link rel="stylesheet" href="css/botones.css">
        <link rel="stylesheet" href="css/listaSolicitudes.css">
    </head>
    <body>
        <!--- Verificación de sesión y rol --->
        <cfif NOT structKeyExists(session, "rol") 
            OR ListFindNoCase("Expediente,RecursosHumanos,Autorizacion,Jefe,Solicitante", session.rol) EQ 0>
            <cflocation url="menu.cfm" addtoken="no">
        </cfif>

        <!--- Parámetros de URL y formulario --->
        <cfparam name="url.page" default="1">
        <cfparam name="form.search" default="">

        <!--- Configuración de paginación --->
        <cfset rowsPerPage = 10>
        <cfset currentPage = val(url.page)>
        <cfif currentPage LTE 0><cfset currentPage = 1></cfif>
        <cfset startRow = (currentPage - 1) * rowsPerPage + 1>

        <!--- Calcular totales --->
        <cfset totalRecords = qFirmados.recordCount>
        <cfset totalPages = ceiling(totalRecords / rowsPerPage)>
        <cfset endRow = min(startRow + rowsPerPage - 1, totalRecords)>

        <!--- Subconsulta para mostrar solo las filas de la página actual --->
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
                <h1>Solicitudes firmadas por ti</h1>
            </div>

            <div class="form-container">
                <!--- Formulario de búsqueda --->
                <form method="post" action="listaSolicitudes.cfm" class="field-group single">
                    <!--- Campo de búsqueda --->
                    <div class="form-field">
                        <!--- Etiqueta y campo de entrada --->
                        <label class="form-label">
                            Buscar:
                        </label>
                        <!--- Campo de texto --->
                        <cfoutput>
                            <!--- Mantener el valor ingresado en el campo de búsqueda --->
                            <input type="text" name="search" value="#encodeForHTMLAttribute(form.search)#" 
                                class="form-input-general" placeholder="Solicitante, Motivo, Tipo permiso, Status, Rol">
                        </cfoutput>
                    </div>

                    <!--- Botón de búsqueda --->
                    <button type="submit" class="submit-btn-buscar">
                        Buscar
                    </button>
                </form>

                <div class="section">
                    <h2 class="section-title">Listado de solicitudes</h2>

                    <div class="table-responsive-custom">
                        <table class="tabla">
                            <thead>
                                <tr class="titulos-tabla">
                                    <th class="titulo-general">ID Solicitud</th>
                                    <th class="titulo-general">Solicitante</th>
                                    <th class="titulo-general">Motivo</th>
                                    <th class="titulo-general">Tipo Permiso</th>
                                    <th class="titulo-general">Fecha Solicitud</th>
                                    <th class="titulo-general">Rol</th>
                                    <th class="titulo-general">Estado Firma</th>
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
                                        <td class="titulo-general-centrado">#DateFormat(fecha_firma,'dd/mm/yyyy')# #TimeFormat(fecha_firma,'HH:mm')#</td>
                                        <td class="titulo-general-centrado">
                                            <form action="solicitudDetalles.cfm" method="get">
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
                            <cfset endPage = min(startPage + blockSize - 1, totalPages)>

                            <!--- Botón 'Anterior' si hay bloques previos --->
                            <cfif startPage GT 1>
                                <cfset prevPage = startPage - 1>
                                <cfoutput>
                                    <a href="listaSolicitudes.cfm?page=#prevPage#&search=#urlEncodedFormat(form.search)#"
                                        class="submit-btn-anterior"
                                        style="text-decoration:none">&laquo; Anterior</a>
                                </cfoutput>
                            </cfif>

                            <!--- Números del bloque actual --->
                            <cfloop from="#startPage#" to="#endPage#" index="i">
                                <cfif i EQ currentPage>
                                    <!--- Botón deshabilitado para la página actual --->
                                    <cfoutput>
                                        <button class="submit-btn-paginacion-disabled" disabled>#i#</button>
                                    </cfoutput>
                                <cfelse>
                                    <!--- Botón para otras páginas --->
                                    <cfoutput>
                                        <a href="listaSolicitudes.cfm?page=#i#&search=#urlEncodedFormat(form.search)#" 
                                            class="submit-btn-paginacion" style="text-decoration:none">#i#</a>
                                    </cfoutput>
                                </cfif>
                            </cfloop>

                            <!--- Botón 'Siguiente' si hay más bloques --->
                            <cfif endPage LT totalPages>
                                <cfset nextPage = endPage + 1>
                                <cfoutput>
                                    <a href="listaSolicitudes.cfm?page=#nextPage#&search=#urlEncodedFormat(form.search)#"
                                        class="submit-btn-siguiente"
                                        style="text-decoration:none">Siguiente &raquo;</a>
                                </cfoutput>
                            </cfif>
                        </cfif>
                    </div>
                </div>

                <div class="submit-section">
                    <div class="field-group">
                        <a href="menu.cfm" class="submit-btn-menu submit-btn-menu-text">
                            Menú
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
