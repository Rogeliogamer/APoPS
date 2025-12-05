<!---
 * Nombre de la pagina: administracion/listaFirmaSolicitudes.cfm
 * 
 * Descripción:
 * Esta página muestra una lista paginada de las firmas asociadas a las solicitudes en el sistema.
 * Incluye un formulario de búsqueda que permite filtrar las firmas por varios campos,
 * y muestra los resultados en una tabla con paginación en bloques de 10 páginas.
 * Verifica que el usuario tenga el rol adecuado para acceder a esta página.
 * 
 * Roles:
 * Admin: Acceso completo para ver la lista de firmas.
 * 
 * Paginas relacionadas:
 * login.cfm: Página de inicio de sesión.
 * menu.cfm: Menú principal del sistema.
 * listaFirmasSolicitudes.cfm: Esta misma página.
 * adminPanel.cfm: Panel de administración.
 * cerrarSesion.cfm: Cierre de sesión del usuario.
 * 
 * Autor: Rogelio Perez Guevara
 * 
 * Fecha de creación: 03-12-2025
 * 
 * Versión: 1.0
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
        <title>Lista de Firmas</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/listaUsuarios.css">
        <link rel="stylesheet" href="../css/botones.css">
        <link rel="stylesheet" href="../css/tablas.css">

        <style>
            /* Definimos el tamaño de la columna */
            .columna-firma {
                width: 150px;       /* Ancho fijo que quieres que ocupe */
                text-align: center;
                padding: 5px;
            }

            /* IMPORTANTE: Obligamos al SVG a respetar el ancho de la columna */
            .columna-firma svg {
                width: 100% !important;  /* Llena el ancho disponible (150px) */
                height: auto !important; /* Calcula la altura automáticamente para no deformarse */
                max-height: 60px;        /* Opcional: Límite de altura para que no se haga muy alta */
                display: block;          /* Elimina espacios extra debajo del SVG */
                margin: 0 auto;          /* Centra el SVG */
            }
        </style>
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

        <!--- Configuración de paginación --->
        <cfset rowsPerPage = 10>
        <!--- Cálculo de la fila inicial para la consulta --->
        <cfset currentPage = val(url.page)>
        <!--- Asegurar que la página actual sea al menos 1 --->
        <cfif currentPage LTE 0><cfset currentPage = 1></cfif>
        <!--- Cálculo de la fila inicial --->
        <cfset startRow = (currentPage - 1) * rowsPerPage + 1>
        
        <!--- Consulta con filtro de búsqueda --->
        <cfquery name="qFirmas" datasource="autorizacion">
            SELECT f.id_firma,
                f.id_solicitud,
                f.id_usuario,
                f.rol,
                f.svg,
                f.aprobado,
                f.fecha_firma
            FROM firmas f
            INNER JOIN solicitudes s ON f.id_solicitud = s.id_solicitud
            INNER JOIN usuarios u ON s.id_solicitante = u.id_usuario
            WHERE 1=1
            <cfif len(trim(searchTerm))>
                AND (
                    f.id_firma LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR f.id_solicitud LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR f.id_usuario LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR f.rol LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR f.aprobado LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR f.fecha_firma LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                )
            </cfif>
            <!--- Ordenar resultados --->
            ORDER BY f.id_firma DESC
        </cfquery>

        <!--- Número total de registros --->
        <cfset totalRecords = qFirmas.recordCount>
        <!--- Cálculo del total de páginas --->
        <cfset totalPages = ceiling(totalRecords / rowsPerPage)>

        <!--- Limitar resultados por página --->
        <cfquery dbtype="query" name="qPaged">
            SELECT *
            FROM qFirmas
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
                <h1>Listado de Firmas</h1>
            </div>
            
            <!--- Contenedor del formulario y tabla --->
            <div class="form-container">
                <!--- Formulario de búsqueda --->
                <form method="post" action="../administracion/listaFirmaSolicitudes.cfm" class="field-group single">
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
                                placeholder="id firma, id solicitud, id usuarios, rol, etc.">
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
                                <td class="titulo-general-centrado">ID FIRMA</td>
                                <td class="titulo-general-centrado">ID SOLICITUD</td>
                                <td class="titulo-general-centrado">ID USUARIO</td>
                                <td class="titulo-general-centrado">ROL</td>
                                <td class="titulo-general-centrado">SVG</td>
                                <td class="titulo-general-centrado">APROBADO</td>
                                <td class="titulo-general-centrado">FECHA FIRMA</td>
                            </tr>

                            <!--- Filas de la tabla --->
                            <cfoutput query="qPaged">
                                <!--- Fila de datos --->
                                <tr>
                                    <!--- Datos del usuario --->
                                    <td class="titulo-general-centrado">#id_firma#</td>
                                    <td class="titulo-general-centrado">#id_solicitud#</td>
                                    <td class="titulo-general-centrado">#id_usuario#</td>
                                    <td class="titulo-general-centrado">#rol#</td>
                                    <td class="columna-firma">#svg#</td>
                                    <td class="titulo-general-centrado">#aprobado#</td>
                                    <td class="titulo-general-centrado">#DateFormat(fecha_firma, 'dd/mm/yyyy')# #timeFormat(fecha_firma, 'HH:mm')#</td>
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
                                    <a href="listaFirmaSolicitudes.cfm?page=#prevPage#&search=#urlEncodedFormat(searchTerm)#"
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
                                        <a href="listaFirmaSolicitudes.cfm?page=#i#&search=#urlEncodedFormat(searchTerm)#" 
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
                                    <a href="listaFirmaSolicitudes.cfm?page=#nextPage#&search=#urlEncodedFormat(searchTerm)#"
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
