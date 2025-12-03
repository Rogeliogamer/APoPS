<!---
 * Componente `listaUsuarios.cfc` para la visualización y gestión de usuarios.
 *
 * Acceso:
 * - Permitido únicamente a usuarios con rol: `admin`, `expediente`, `RecursosHumanos` y `jefe`.
 * - Rol `usuario` no tiene acceso a esta página.
 *
 * Funcionalidad:
 * - Muestra la lista de usuarios filtrada según los privilegios del rol autenticado.
 * - La búsqueda de usuarios también respeta las restricciones de acceso por rol.
 * - Garantiza un nivel de seguridad al limitar la visibilidad de la información sensible.
 *
 * Permisos especiales:
 * - Solo los usuarios con rol `admin` tienen habilitados los botones de **Editar** y **Eliminar**.
 * - Cada acción redirige a la página correspondiente con la información del usuario seleccionado.
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
        <title>Lista de Solicitudes</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/listaUsuarios.css">
        <link rel="stylesheet" href="../css/botones.css">
        <link rel="stylesheet" href="../css/tablas.css">
    </head>
    <body>
        <!--- Verificación de sesión y rol --->
        <cfif NOT structKeyExists(session, "usuario") 
            OR NOT structKeyExists(session, "rol")
            OR len(trim(session.rol)) EQ 0>
            <!--- No hay sesión activa --->
            <cflocation url="../login.cfm" addtoken="no">
        <cfelseif listFindNoCase("admin", trim(session.rol)) EQ 0>
            <!--- Rol no autorizado --->
            <cflocation url="../menu.cfm" addtoken="no">
        </cfif>

        <!--- Configuración de paginación --->
        <cfset rowsPerPage = 10>
        <!--- Cálculo de la fila inicial para la consulta --->
        <cfset currentPage = val(url.page)>
        <!--- Asegurar que la página actual sea al menos 1 --->
        <cfif currentPage LTE 0><cfset currentPage = 1></cfif>
        <!--- Cálculo de la fila inicial --->
        <cfset startRow = (currentPage - 1) * rowsPerPage + 1>
        
        <!--- Consulta con filtro de búsqueda --->
        <cfquery name="qSolicitudes" datasource="autorizacion">
            SELECT s.id_solicitud,
                s.id_solicitante,
                s.id_area,
                s.tipo_solicitud,
                s.tipo_permiso,
                s.fecha,
                s.tiempo_solicitado,
                s.hora_salida,
                s.hora_llegada,
                s.status_final,
                s.fecha_creacion,
                s.alert
            FROM solicitudes s
            INNER JOIN usuarios u ON s.id_solicitante = u.id_usuario
            INNER JOIN area_adscripcion a ON s.id_area = a.id_area
            WHERE 1=1
            <cfif len(trim(searchTerm))>
                AND (
                    s.id_solicitud LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR s.id_solicitante LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR s.id_area LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR s.tipo_permiso LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR s.fecha LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR s.tiempo_solicitado LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR s.hora_salida LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR s.hora_llegada LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR s.status_final LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR s.fecha_creacion LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR s.alert LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                )
            </cfif>
            <!--- Ordenar resultados --->
            ORDER BY s.id_solicitud DESC
        </cfquery>

        <!--- Número total de registros --->
        <cfset totalRecords = qSolicitudes.recordCount>
        <!--- Cálculo del total de páginas --->
        <cfset totalPages = ceiling(totalRecords / rowsPerPage)>

        <!--- Limitar resultados por página --->
        <cfquery dbtype="query" name="qPaged">
            SELECT *
            FROM qSolicitudes
            WHERE currentRow BETWEEN #startRow# AND #startRow + rowsPerPage - 1#
        </cfquery>

        <!--- Listado de usuarios --->
        <div class="container">
            <!--- Contenedor principal --->
            <div class="header">
                <!--- Título y logo --->
                <div class="logo">
                    <!--- Mostrar el rol del usuario conectado --->
                    <cfset usuarioRol = createObject("component", "../componentes/usuarioConectadoSAdmin").render()>
                    <!--- Mostrar rol --->
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <!--- Título de la página --->
                <h1>Listado de Solicitudes</h1>
            </div>
            
            <!--- Contenedor del formulario y tabla --->
            <div class="form-container">
                <!--- Formulario de búsqueda --->
                <form method="post" action="../administracion/listaSolicitudes.cfm" class="field-group single">
                    <!--- Campo de búsqueda --->
                    <div class="form-field">
                        <!--- Etiqueta y campo de entrada --->
                        <label class="form-label">
                            Buscar:
                        </label>
                        <!--- Campo de texto --->
                        <cfoutput>
                            <!--- Mantener el valor ingresado en el campo de búsqueda --->
                            <input type="text" 
                                name="search" 
                                value="#encodeForHTMLAttribute(searchTerm)#" 
                                class="form-input-general" 
                                placeholder="tipo de solicitud, tipo de permiso, fecha, hora, etc.">
                        </cfoutput>
                    </div>

                    <!--- Botón de búsqueda --->
                    <button type="submit" class="submit-btn-buscar">
                        Buscar
                    </button>
                </form>

                <!--- Tabla de usuarios --->
                <div class="section">
                    <!--- Contenedor de la tabla --->
                    <div class="section-title">
                        Lista de Solicitudes
                    </div>

                    <!--- Tabla responsiva --->
                    <div class="table-responsive-custom">
                        <!--- Contenedor de la tabla y paginación --->
                        <table class="tabla">
                            <!--- Encabezados de la tabla --->
                            <tr class="titulos-tabla">
                                <!--- Encabezados de las columnas --->
                                <td class="titulo-general">ID SOLICITUD</td>
                                <td class="titulo-general">ID SOLICITANTE</td>
                                <td class="titulo-general">ID AREA</td>
                                <td class="titulo-general">TIPO SOLICITUD</td>
                                <td class="titulo-general">TIPO PERMISO</td>
                                <td class="titulo-general">FECHA</td>
                                <td class="titulo-general">TIEMPO SOLICITADO</td>
                                <td class="titulo-general">HORA SALIDA</td>
                                <td class="titulo-general">HORA LLEGADA</td>
                                <td class="titulo-general">STATUS FINAL</td>
                                <td class="titulo-general">FECHA CREACION</td>
                                <td class="titulo-general">ALERT</td>
                            </tr>

                            <!--- Filas de la tabla --->
                            <cfoutput query="qPaged">
                                <!--- Fila de datos --->
                                <tr>
                                    <!--- Datos del usuario --->
                                    <td>#id_solicitud#</td>
                                    <td>#id_solicitante#</td>
                                    <td>#id_area#</td>
                                    <td>#tipo_solicitud#</td>
                                    <td>#tipo_permiso#</td>
                                    <td>#fecha#</td>
                                    <td>#tiempo_solicitado#</td>
                                    <td>#hora_salida#</td>
                                    <td>#hora_llegada#</td>
                                    <td>#status_final#</td>
                                    <td>#fecha_creacion#</td>
                                    <td>#alert#</td>
                                </tr>
                            </cfoutput>
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
                                <!--- Página anterior al bloque actual --->
                                <cfset prevPage = startPage - 1>
                                <!--- Enlace al bloque anterior --->
                                <cfoutput>
                                    <a href="listaSolicitudes.cfm?page=#prevPage#&search=#urlEncodedFormat(searchTerm)#"
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
                                <!--- Botón para otras páginas --->
                                <cfelse>
                                    <cfoutput>
                                        <a href="listaSolicitudes.cfm?page=#i#&search=#urlEncodedFormat(searchTerm)#" 
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
                                    <a href="listaSolicitudes.cfm?page=#nextPage#&search=#urlEncodedFormat(searchTerm)#"
                                        class="submit-btn-siguiente"
                                        style="text-decoration:none">Siguiente &raquo;</a>
                                </cfoutput>
                            </cfif>
                        </cfif>
                    </div>

                    <!--- Enlaces para regresar al menú principal y cerrar sesión --->
                    <div class="submit-section">
                        <!--- Enlace para regresar al menú principal --->
                        <div class="field-group">
                            <!--- Botón Menu --->
                            <a href="../adminPanel.cfm" class="submit-btn-menu submit-btn-menu-text">
                                Menu
                            </a>
                            
                            <!--- Botón Cerrar Sesion --->
                            <a href="../cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                                Cerrar Sesion
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
