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

<!DOCTYPE html>
<html lang="es">
    <head>
        <!-- Metadatos y enlaces a estilos -->
        <meta charset="UTF-8">
        <!-- Vista adaptable para dispositivos móviles -->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Título de la página -->
        <title>Lista de usuarios</title>
        <!-- Enlace a fuentes y hojas de estilo -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/listaUsuarios.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!-- Verificación de sesión y rol -->
        <cfif NOT structKeyExists(session, "usuario") 
            OR (session.rol NEQ "admin" 
                AND session.rol NEQ "Expediente" 
                AND session.rol NEQ "RecursosHumanos" 
                AND session.rol NEQ "Jefe")>
            <!-- Redirigir al usuario a la página de login si no está autorizado -->
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
        
        <!-- Consulta con filtro de búsqueda -->
        <cfquery name="qUsuarios" datasource="autorizacion">
            SELECT 
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
            WHERE 1=1
            <cfif len(trim(form.search))>
                AND (
                    u.usuario LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
                    OR du.nombre LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
                    OR du.apellido_paterno LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
                    OR du.apellido_materno LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
                    OR a.nombre LIKE <cfqueryparam value="%#form.search#%" cfsqltype="cf_sql_varchar">
                )
            </cfif>

            <!--- Filtro si el usuario logueado es jefe --->
            <cfif structKeyExists(session, "rol") AND session.rol EQ "Jefe">
                AND du.id_area = <cfqueryparam value="#session.id_area#" cfsqltype="cf_sql_integer">
            </cfif>

            <!--- Ordenar resultados --->
            ORDER BY du.apellido_paterno, du.nombre
        </cfquery>

        <!-- Número total de registros -->
        <cfset totalRecords = qUsuarios.recordCount>
        <!-- Cálculo del total de páginas -->
        <cfset totalPages = ceiling(totalRecords / rowsPerPage)>

        <!-- Limitar resultados por página -->
        <cfquery dbtype="query" name="qPaged">
            SELECT *
            FROM qUsuarios
            WHERE currentRow BETWEEN #startRow# AND #startRow + rowsPerPage - 1#
        </cfquery>

        <!-- Listado de usuarios -->
        <div class="container" style="max-width: 1200px;">
            <!-- Contenedor principal -->
            <div class="header">
                <!-- Título y logo -->
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <h1>
                    Listado de Usuarios
                </h1>
            </div>
            
            <!-- Contenedor del formulario y tabla -->
            <div class="form-container">
                <!-- Formulario de búsqueda -->
                <form method="post" action="listaUsuarios.cfm" class="field-group single">
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
                                class="form-input-general" placeholder="Nombre, Usuario, Área...">
                        </cfoutput>
                    </div>

                    <!-- Botón de búsqueda -->
                    <button type="submit" class="submit-btn-buscar">
                        Buscar
                    </button>
                </form>

                <!-- Tabla de usuarios -->
                <div class="section">
                    <!-- Contenedor de la tabla -->
                    <div class="section-title">
                        Usuarios Registrados
                    </div>

                    <!-- Contenedor de la tabla y paginación -->
                    <table border="0" width="100%" cellpadding="10" cellspacing="2">
                        <!-- Encabezados de la tabla -->
                        <tr style="background:#f1f5f9; font-weight:bold;">
                            <td>ID</td>
                            <td>Usuario</td>
                            <td>Rol</td>
                            <td>Nombre</td>
                            <td>Apellido Paterno</td>
                            <td>Apellido Materno</td>
                            <td>Área</td>

                            <!-- Mostrar columnas Editar y Eliminar solo si el usuario tiene rol admin -->
                            <cfif structKeyExists(session, "usuario") AND session.rol EQ "admin">
                                <td>Editar</td>
                                <td>Eliminar</td>
                            </cfif>
                        </tr>

                        <!-- Filas de la tabla -->
                        <cfoutput query="qPaged">
                            <tr>
                                <td>#id_usuario#</td>
                                <td>#usuario#</td>
                                <td>#rol#</td>
                                <td>#nombre#</td>
                                <td>#apellido_materno#</td>
                                <td>#apellido_paterno#</td>
                                <td>#area#</td>

                                <cfif structKeyExists(session, "usuario") AND session.rol EQ "admin">
                                    <!-- Botón Editar -->
                                    <td>
                                        <a href="editarUsuario.cfm?id=#id_usuario#" class="submit-btn-editar">
                                            Editar
                                        </a>
                                    </td>

                                    <!-- Botón Eliminar -->
                                    <td>
                                        <a href="eliminarUsuario.cfm?id=#id_usuario#" class="submit-btn-eliminar" onclick="return confirm('¿Estás seguro de eliminar este usuario?');">
                                            Eliminar
                                        </a>
                                    </td>
                                </cfif>
                            </tr>
                        </cfoutput>
                    </table>

                    <!-- Paginación -->
                    <div class="submit-section">
                        <!-- Contenedor de la paginación -->
                        <cfif totalPages GT 1>
                            <!-- Mostrar total de páginas y registros -->
                            <cfloop from="1" to="#totalPages#" index="i">
                                <!-- Botones de paginación -->
                                <cfif i EQ currentPage>
                                    <!-- Botón deshabilitado para la página actual -->
                                    <cfoutput>
                                        <button class="submit-btn" disabled>#i#</button>
                                    </cfoutput>
                                <cfelse>
                                    <!-- Botón para otras páginas -->
                                    <cfoutput>
                                        <a href="listaUsuarios.cfm?page=#i#&search=#urlEncodedFormat(form.search)#" 
                                            class="submit-btn" style="text-decoration:none">#i#</a>
                                    </cfoutput>
                                </cfif>
                            </cfloop>
                        </cfif>
                    </div>

                    <div class="submit-section">
                        <!-- Enlace para regresar al menú principal -->
                        <button class="submit-btn-menu">
                            <a href="menu.cfm" class="submit-btn-menu-text">Menu</a>
                        </button>
                        <button class="submit-btn-cerrarSesion">
                            <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion-text">
                                Cerrar Sesion
                            </a>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
