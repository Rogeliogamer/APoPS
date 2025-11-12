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

<!--- Consulta para obtener las solicitudes firmadas por el usuario en sesión --->
<cfquery name="qFirmados" datasource="autorizacion">
    SELECT s.id_solicitud,
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
    WHERE u.activo = '1'
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
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/tablas.css">
        <link rel="stylesheet" href="css/botones.css">
        <link rel="stylesheet" href="css/listaSolicitudes.css">
    </head>
    <body>
        <!--- Verificación de sesión y rol --->
        <cfif NOT structKeyExists(session, "rol") 
            OR ListFindNoCase("RecursosHumanos", session.rol) EQ 0>
            <cflocation url="menu.cfm" addtoken="no">
        </cfif>

        <!--- Parámetros de URL y formulario --->
        <cfparam name="url.page" default="1">
        <cfparam name="form.search" default="">

        <!--- Configuración de paginación --->
        <cfset rowsPerPage = 10>
        <!--- Calcular la página actual y los índices de fila --->
        <cfset currentPage = val(url.page)>
        <!--- Asegurar que la página actual sea al menos 1 --->
        <cfif currentPage LTE 0><cfset currentPage = 1></cfif>
        <!--- Calcular el índice de la primera fila de la página actual --->
        <cfset startRow = (currentPage - 1) * rowsPerPage + 1>

        <!--- Calcular total de registros y páginas --->
        <cfset totalRecords = qFirmados.recordCount>
        <!--- Calcular el total de páginas --->
        <cfset totalPages = ceiling(totalRecords / rowsPerPage)>
        <!--- Calcular el índice de la última fila de la página actual --->
        <cfset endRow = min(startRow + rowsPerPage - 1, totalRecords)>

        <!--- Subconsulta para mostrar solo las filas de la página actual --->
        <cfquery dbtype="query" name="qPaged">
            SELECT *
            FROM qFirmados
        </cfquery>

        <!--- Contenido de la página --->
        <div class="container">
            <!--- Encabezado con logo y título --->
            <div class="header">
                <!--- Logo con el rol del usuario --->
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <!--- Título de la página --->
                <h1>Solicitudes firmadas por ti</h1>
            </div>

            <!--- Contenedor principal --->
            <div class="form-container">
                <!--- Formulario de búsqueda --->
                <form method="post" action="listaTodasSolicitudes.cfm" class="field-group single">
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

                <!--- Sección de listado de solicitudes --->
                <div class="section">
                    <!--- Título de la sección --->
                    <h2 class="section-title">Listado de solicitudes</h2>

                    <!--- Contenedor de la tabla --->
                    <div class="table-responsive-custom">
                        <!--- Tabla de solicitudes --->
                        <table class="tabla">
                            <!--- Encabezado de la tabla --->
                            <thead>
                                <!--- Fila de títulos --->
                                <tr class="titulos-tabla">
                                    <!--- Títulos de las columnas --->
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
                            <!--- Cuerpo de la tabla --->
                            <tbody>
                                <!--- Iterar sobre las filas paginadas --->
                                <cfoutput query="qPaged" startrow="#startRow#" maxrows="#rowsPerPage#">
                                    <!--- Fila de datos --->
                                    <tr>
                                        <!--- Datos de cada columna --->
                                        <td class="titulo-general-centrado">#id_solicitud#</td>
                                        <td>#solicitante#</td>
                                        <td>#motivo#</td>
                                        <td>#tipo_permiso#</td>
                                        <td class="titulo-general-centrado">#DateFormat(fecha,'dd/mm/yyyy')#</td>
                                        <td>#rol_solicitante#</td>
                                        <td>
                                            <!--- Mostrar el estado de la firma con íconos y estilos --->
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
                                            <!--- Botón para ver detalles de la solicitud --->
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
                                <!--- Página anterior al bloque actual --->
                                <cfset prevPage = startPage - 1>
                                <!---- Enlace al bloque anterior --->
                                <cfoutput>
                                    <a href="listaTodasSolicitudes.cfm?page=#prevPage#&search=#urlEncodedFormat(form.search)#"
                                        class="submit-btn-anterior"
                                        style="text-decoration:none">&laquo; Anterior</a>
                                </cfoutput>
                            </cfif>

                            <!--- Números del bloque actual --->
                            <cfloop from="#startPage#" to="#endPage#" index="i">
                                <!--- Verificar si es la página actual --->
                                <cfif i EQ currentPage>
                                    <!--- Botón deshabilitado para la página actual --->
                                    <cfoutput>
                                        <button class="submit-btn-paginacion-disabled" disabled>#i#</button>
                                    </cfoutput>
                                <!---- Botón para otras páginas --->
                                <cfelse>
                                    <!--- Enlace a la página correspondiente --->
                                    <cfoutput>
                                        <a href="listaTodasSolicitudes.cfm?page=#i#&search=#urlEncodedFormat(form.search)#" 
                                            class="submit-btn-paginacion" style="text-decoration:none">#i#</a>
                                    </cfoutput>
                                </cfif>
                            </cfloop>

                            <!--- Botón 'Siguiente' si hay más bloques --->
                            <cfif endPage LT totalPages>
                                <!--- Página siguiente al bloque actual --->
                                <cfset nextPage = endPage + 1>
                                <!--- Enlace al siguiente bloque --->
                                <cfoutput>
                                    <a href="listaTodasSolicitudes.cfm?page=#nextPage#&search=#urlEncodedFormat(form.search)#"
                                        class="submit-btn-siguiente"
                                        style="text-decoration:none">Siguiente &raquo;</a>
                                </cfoutput>
                            </cfif>
                        </cfif>
                    </div>
                </div>

                <!--- Sección de botones de navegación --->
                <div class="submit-section">
                    <!--- Botón para regresar al menú principal --->
                    <div class="field-group">
                        <!--- Botón de menú --->
                        <a href="menu.cfm" class="submit-btn-menu submit-btn-menu-text">
                            Menú
                        </a>
                        
                        <!--- Botón para cerrar sesión --->
                        <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
