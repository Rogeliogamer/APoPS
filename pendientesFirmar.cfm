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

<!-- Determinar el filtro según el rol -->
<cfset filtroRol = "">

<!--- Definir filtros específicos para cada rol --->
<cfif session.rol EQ "Jefe">
    <!--- El rol "Jefe" solo puede ver solicitudes de su área de adscripción --->
    <cfset filtroRol = "AND du.id_area = " & session.id_area>

<!--- Si el rol es "RecursosHumanos", "Autorizacion" o "Expediente", no se aplica filtro adicional --->
<cfelseif session.rol EQ "RecursosHumanos">
    <!--- El rol "RecursosHumanos" solo puede ver solicitudes que ya hayan sido aprobadas por el "Jefe" --->
    <cfset filtroRol = "
        AND EXISTS (
            SELECT 1 FROM firmas f2
            WHERE f2.id_solicitud = s.id_solicitud
            AND f2.rol = 'Jefe'
            AND f2.aprobado = 'Aprobado'
        )">

<!--- El rol "Solicitante" no debe ver ninguna solicitud en esta página --->
<cfelseif NOT ListFindNoCase("Jefe,RecursosHumanos", session.rol)>
    <!--- No mostrar ninguna solicitud para el rol "Solicitante" --->
    <cfset filtroRol = "AND 1=0">
</cfif>

<!--- Parámetros de URL y formulario --->
<cfparam name="form.search" default="">

<!--- Consulta para obtener las solicitudes pendientes de firma según el rol del usuario --->
<cfquery name="qPendientes" datasource="autorizacion">
    SELECT s.id_solicitud, 
        s.tipo_solicitud, 
        s.tipo_permiso, 
        s.fecha,
        CONCAT(du.nombre, ' ', du.apellido_paterno, ' ', du.apellido_materno) AS solicitante,
        du.nombre, 
        du.apellido_paterno, 
        du.apellido_materno,
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
            OR CONCAT(du.nombre, ' ', du.apellido_paterno, ' ', du.apellido_materno) LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
            OR aa.nombre LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR s.tipo_solicitud LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
            OR s.tipo_permiso LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
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
        <link rel="icon" href="elements/icono.ico" type="image/x-icon">
        <!--- Título de la página --->
        <title>Solicitudes Pendientes de Firma</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/pendientesFirmar.css">
        <link rel="stylesheet" href="css/tablas.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!--- Verificación de sesión y rol autorizado --->
        <cfif NOT structKeyExists(session, "rol") OR len(trim(session.rol)) EQ 0>
            <!--- No hay sesión activa o el rol no está definido --->
            <cflocation url="login.cfm" addtoken="no">
        <cfelseif ListFindNoCase("RecursosHumanos,Jefe", trim(session.rol)) EQ 0>
                <!--- El rol no está autorizado para acceder a esta sección --->
            <cflocation url="menu.cfm" addtoken="no">
        </cfif>

        <!--- Configuración de paginación --->
        <cfset rowsPerPage = 10>
        <!--- Calcular la página actual y los índices de fila --->
        <cfset currentPage = val(url.page)>
        <!--- Asegurarse de que la página actual sea al menos 1 --->
        <cfif currentPage LTE 0><cfset currentPage = 1></cfif>
        <!--- Calcular la fila de inicio --->
        <cfset startRow = (currentPage - 1) * rowsPerPage + 1>

        <!--- Calcular total de registros y páginas --->
        <cfset totalRecords = qPendientes.recordCount>
        <!--- Calcular el total de páginas --->
        <cfset totalPages = ceiling(totalRecords / rowsPerPage)>
        <!--- Calcular la fila de fin --->
        <cfset endRow = min(startRow + rowsPerPage - 1, totalRecords)>

        <!--- Subconsulta para mostrar solo las filas de la página actual --->
        <cfquery dbtype="query" name="qPaged">
            SELECT *
            FROM qPendientes
        </cfquery>

        <!--- Contenido de la página --->
        <div class="container">
            <!--- Encabezado de la página --->
            <div class="header">
                <!--- Logo y título --->
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <!--- Título principal --->
                <h1>Solicitudes Pendientes de Firmar</h1>
            </div>

            <!--- Contenedor del formulario y la tabla --->
            <div class="form-container">
                <!--- Formulario de búsqueda --->
                <form method="post" action="pendientesFirmar.cfm" class="field-group single">
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
                                class="form-input-general" placeholder="Solicitante, Area, tipo solicitud, Tipo permiso">
                        </cfoutput>
                    </div>

                    <!--- Botón de búsqueda --->
                    <button type="submit" class="submit-btn-buscar">
                        Buscar
                    </button>
                </form>

                <!--- Verificar si hay solicitudes pendientes --->
                <cfif qPendientes.recordcount eq 0>
                    <!--- Mensaje si no hay solicitudes pendientes --->
                    <div class="section">
                        <p>No tienes solicitudes pendientes de firmar.</p>
                    </div>

                <!--- Mostrar tabla de solicitudes pendientes --->
                <cfelse>
                    <!--- Sección de la tabla --->
                    <div class="section">
                        <!--- Título de la sección --->
                        <div class="section-title">
                            Listado de Solicitudes
                        </div>
                        <!--- Tabla responsiva --->
                        <div class="table-responsive-custom">
                            <!--- Tabla de solicitudes --->
                            <table class="tabla">
                                <!---| Encabezado de la tabla --->
                                <thead>
                                    <!--- Fila de títulos --->
                                    <tr class="titulos-tabla">
                                        <!--- Títulos de las columnas --->
                                        <th class="titulo-general-centrado">ID Solicitud</th>
                                        <th class="titulo-general">Solicitante</th>
                                        <th class="titulo-general">Área</th>
                                        <th class="titulo-general">Tipo de Solicitud</th>
                                        <th class="titulo-general">Tipo de Permiso</th>
                                        <th class="titulo-general-centrado">Fecha</th>
                                        <th class="titulo-general-centrado">Acción</th>
                                    </tr>
                                </thead>
                                <!--- Cuerpo de la tabla --->
                                <tbody>
                                    <!--- Iterar sobre las solicitudes paginadas --->
                                    <cfoutput query="qPaged" startrow="#startRow#" maxrows="#rowsPerPage#">
                                        <!--- Fila de datos de la solicitud --->
                                        <tr>
                                            <!--- Datos de cada columna --->
                                            <td class="titulo-general-centrado">#id_solicitud#</td>
                                            <td>#solicitante#</td>
                                            <td>#area_nombre#</td>
                                            <td>#tipo_solicitud#</td>
                                            <td>#tipo_permiso#</td>
                                            <td class="titulo-general-centrado">#DateFormat(fecha,'yyyy-mm-dd')#</td>
                                            <td class="titulo-general-centrado">
                                                <!--- Botón para firmar la solicitud --->
                                                <form method="post" action="firmarSolicitud.cfm">
                                                    <input type="hidden" name="id_solicitud" value="#id_solicitud#">
                                                    <button type="submit" class="submit-btn-firmar">Firmar</button>
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
                                    <!---| Calcular la página anterior --->
                                    <cfset prevPage = startPage - 1>
                                    <!--- Enlace al bloque anterior --->
                                    <cfoutput>
                                        <a href="pendientesFirmar.cfm?page=#prevPage#&search=#urlEncodedFormat(searchTerm)#"
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
                                            <a href="pendientesFirmar.cfm?page=#i#&search=#urlEncodedFormat(searchTerm)#" 
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
                                        <a href="pendientesFirmar.cfm?page=#nextPage#&search=#urlEncodedFormat(searchTerm)#"
                                            class="submit-btn-siguiente"
                                            style="text-decoration:none">Siguiente &raquo;</a>
                                    </cfoutput>
                                </cfif>
                            </cfif>
                        </div>
                    </div>
                </cfif>

                <!--- Sección de botones de menú y cerrar sesión --->
                <div class="submit-section">
                    <!--- Contenedor de los botones --->    
                    <div class="field-group">
                        <!--- Enlace para regresar al menú principal --->
                        <a href="menu.cfm" class="submit-btn-menu submit-btn-menu-text">
                            Menu
                        </a>
                        
                        <!--- Enlace para cerrar sesión --->
                        <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                                Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
