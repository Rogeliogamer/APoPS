<!---
 * Nombre de la pagina: administracion/listaUsuariosEditar.cfm
 * 
 * Descripción:
 * Esta página muestra una lista paginada de usuarios registrados en el sistema,
 * permitiendo la búsqueda por varios campos como ID, nombre, apellidos y área.
 * Solo los usuarios con rol de administrador pueden acceder a esta página.
 * 
 * Roles:
 * admin - Solo los administradores pueden acceder a esta página.
 * 
 * Paginas relacionadas:
 * login.cfm - Página de inicio de sesión.
 * menu.cfm - Página de menú principal.
 * listaUsuariosEditar.cfm - Página actual para listar y editar usuarios.
 * editarUsuario.cfm - Página para editar los detalles de un usuario específico.
 * adminPanel.cfm - Panel de administración.
 * cerrarSesion.cfm - Página para cerrar sesión.
 * 
 * Autor: Rogelio Perez Guevara
 * 
 * Fecha de creación: 02-12-2025
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
        <title>Lista de Edición de Usuarios</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/listaUsuarios.css">
        <link rel="stylesheet" href="../css/botones.css">
        <link rel="stylesheet" href="../css/tablas.css">
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
        
        <!--- Consulta con filtro de búsqueda --->
        <cfquery name="qUsuarios" datasource="autorizacion">
            SELECT u.activo,
                u.id_usuario,
                u.usuario,
                u.rol,
                du.nombre,
                du.apellido_paterno,
                du.apellido_materno,
                a.nombre AS area
            FROM usuarios u
            INNER JOIN datos_usuario du ON u.id_datos = du.id_datos
            INNER JOIN area_adscripcion a ON du.id_area = a.id_area
            WHERE 1=1 AND u.activo = 1
            <cfif len(trim(searchTerm))>
                AND (
                    u.id_usuario LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR u.usuario LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR du.nombre LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR du.apellido_paterno LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR du.apellido_materno LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR CONCAT(du.nombre, ' ', du.apellido_paterno, ' ', du.apellido_materno) LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                    OR a.nombre LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                )
            </cfif>
            <!--- Ordenar resultados --->
            ORDER BY u.id_usuario ASC
        </cfquery>

        <!--- Configuración de paginación --->
        <cfset rowsPerPage = 10>
        <!--- Cálculo de la fila inicial para la consulta --->
        <cfset currentPage = val(url.page)>
        <!--- Asegurar que la página actual sea al menos 1 --->
        <cfif currentPage LTE 0><cfset currentPage = 1></cfif>
        <!--- Cálculo de la fila inicial --->
        <cfset startRow = (currentPage - 1) * rowsPerPage + 1>

        <!--- Número total de registros --->
        <cfset totalRecords = qUsuarios.recordCount>
        <!--- Cálculo del total de páginas --->
        <cfset totalPages = ceiling(totalRecords / rowsPerPage)>
        <!--- Calcular el índice de la última fila de la página actual --->
        <cfset endRow = min(startRow + rowsPerPage - 1, totalRecords)>

        <!--- Limitar resultados por página --->
        <cfquery dbtype="query" name="qPaged">
            SELECT *
            FROM qUsuarios
            WHERE qUsuarios.currentRow BETWEEN <cfqueryparam value="#startRow#" cfsqltype="cf_sql_integer"> AND <cfqueryparam value="#endRow#" cfsqltype="cf_sql_integer">
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
                <h1>Listado de Usuarios</h1>
            </div>
            
            <!--- Contenedor del formulario y tabla --->
            <div class="form-container">
                <!--- Formulario de búsqueda --->
                <form method="post" action="listaUsuariosEditar.cfm" class="field-group single">
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
                                value="#encodeForHTMLAttribute(form.search)#" 
                                class="form-input-general" 
                                placeholder="Usuario, Nombre, Apellidos, Área">
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
                        Lista de Usuarios
                    </div>

                    <!--- Tabla responsiva --->
                    <div class="table-responsive-custom">
                        <!--- Contenedor de la tabla y paginación --->
                        <table class="tabla">
                            <!--- Encabezados de la tabla --->
                            <tr class="titulos-tabla">
                                <!--- Encabezados de las columnas --->
                                <td class="titulo-general">ID</td>
                                <td class="titulo-general">Usuario</td>
                                <td class="titulo-general">Rol</td>
                                <td class="titulo-general">Nombre</td>
                                <td class="titulo-general">Apellido Paterno</td>
                                <td class="titulo-general">Apellido Materno</td>
                                <td class="titulo-general">Área</td>
                                <td class="titulo-general">Editar</td>
                            </tr>

                            <!--- Filas de la tabla --->
                            <cfoutput query="qPaged">
                                <!--- Fila de datos --->
                                <tr>
                                    <!--- Datos del usuario --->
                                    <td>#id_usuario#</td>
                                    <td>#usuario#</td>
                                    <td>#rol#</td>
                                    <td>#nombre#</td>
                                    <td>#apellido_paterno#</td>
                                    <td>#apellido_materno#</td>
                                    <td>#area#</td>
                                    <td class="submit-btn-editar-separacion">
                                        <form action="editarUsuario.cfm" method="post">
                                            <input type="hidden" name="id" value="#id_usuario#">
                                            <button type="submit" class="submit-btn-editar">Editar</button>
                                        </form>
                                    </td>
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
                            <!--- Asegurar que la página final no exceda el total de páginas --->
                            <cfset endPage = min(startPage + blockSize - 1, totalPages)>

                            <!--- Botón 'Anterior' si hay bloques previos --->
                            <cfif startPage GT 1>
                                <!--- Página anterior al bloque actual --->
                                <cfset prevPage = startPage - 1>
                                <!--- Enlace al bloque anterior --->
                                <cfoutput>
                                    <a href="listaUsuariosEditar.cfm?page=#prevPage#&search=#urlEncodedFormat(searchTerm)#"
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
                                        <a href="listaUsuariosEditar.cfm?page=#i#&search=#urlEncodedFormat(searchTerm)#" 
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
                                    <a href="listaUsuariosEditar.cfm?page=#nextPage#&search=#urlEncodedFormat(searchTerm)#"
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
