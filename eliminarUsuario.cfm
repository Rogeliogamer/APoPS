<!---
 * Página `eliminarUsuario.cfm` para la eliminación de la información de un usuario.
 *
 * Funcionalidad:
 * - Permite al administrador eliminar al usuario seleccionado.
 * - Recibe el ID del usuario a eliminar mediante un formulario POST.
 * - Valida que el ID sea válido y que el usuario exista en la base de datos.
 * - Si el usuario existe, se muestra un formulario con los datos actuales del usuario.
 * - Al confirmar la eliminación, se actualiza el campo `activo` a 0 en la tabla de usuarios (borrado lógico).
 * - Se proporciona retroalimentación al administrador sobre el resultado de la operación.
 * - En caso de que el usuario no exista, se muestra un mensaje de error.
 * - Al finalizar, se redirige automáticamente a la lista de usuarios.
 *
 * Uso:
 * - Página destinada a la desactivación (borrado lógico) de usuarios registrados en el sistema.
--->

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
        <title>Editar Usuario</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!--- Verificación de sesión y rol --->
        <cfif NOT structKeyExists(session, "usuario") 
            OR NOT structKeyExists(session, "rol")
            OR len(trim(session.rol)) EQ 0>
            <!--- No hay sesión activa --->
            <cflocation url="login.cfm" addtoken="no">
        <cfelseif listFindNoCase("admin", trim(session.rol)) EQ 0>
            <!--- Rol no autorizado --->
            <cflocation url="listaUsuarios.cfm" addtoken="no">
        </cfif>

        <!--- Parámetro de entrada --->
        <cfparam name="form.id" default="0">

        <!--- Obtener datos del usuario --->
        <cfquery name="qUsuario" datasource="autorizacion">
            SELECT u.id_usuario, 
                u.usuario, 
                u.rol, 
                u.activo,
                d.id_datos, 
                d.nombre, 
                d.apellido_paterno, 
                d.apellido_materno, 
                d.id_area,
                a.nombre AS nombre_area
            FROM usuarios u
            INNER JOIN datos_usuario d ON u.id_datos = d.id_datos
            INNER JOIN area_adscripcion a ON d.id_area = a.id_area
            WHERE u.id_usuario = <cfqueryparam value="#form.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Si no existe el usuario, abortar --->
        <cfif qUsuario.recordCount EQ 0>
            <cfoutput>
                Usuario no encontrado
            </cfoutput>
            <cfabort>
        </cfif>

        <!--- Obtener lista de áreas --->
        <cfquery name="qAreas" datasource="autorizacion">
            SELECT id_area, 
                nombre
            FROM area_adscripcion
        </cfquery>

        <!--- Obtener lista de roles (valores ENUM) --->
        <cfquery name="qRol" datasource="autorizacion">
            SHOW COLUMNS 
            FROM usuarios LIKE 'rol'
        </cfquery>

        <!--- Procesar valores ENUM --->
        <cfset enumStringR = qRol.Type[1]>
        <!--- Eliminar prefijos y sufijos innecesarios --->
        <cfset enumStringR = REReplace(enumStringR,"^enum\('","", "all")>
        <!--- Eliminar el sufijo final --->
        <cfset enumStringR = REReplace(enumStringR,"'\)$","", "all")>
        <!--- Reemplazar separadores de ENUM por comas --->
        <cfset enumListR = REReplace(enumStringR,"','",",","all")>

        <!--- Procesar formulario --->
        <cfif structKeyExists(form, "eliminar")>
            <!--- Actualizar tabla usuarios --->
            <cfquery datasource="autorizacion">
                UPDATE usuarios
                SET activo = 0
                WHERE id_usuario = <cfqueryparam value="#form.id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <!--- Redirigir a la lista de usuarios --->
            <cflocation url="listaUsuarios.cfm" addtoken="false">
        </cfif>

        <!--- Formulario de edición --->
        <cfoutput>
            <!--- Contenedor principal --->
            <div class="container">
                <!--- Contenedor del formulario --->
                <div class="header">
                    <!--- Logo y título --->
                    <div class="logo">
                        <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                        <cfoutput>#usuarioRol#</cfoutput>
                    </div>

                    <!--- Nombre del usuario --->
                    <h1>#qUsuario.usuario#</h1>
                </div>

                <!--- Formulario de edición --->
                <div class="form-container">
                    <!--- Formulario --->
                    <form method="post">
                        <!--- Campo oculto con el ID del usuario --->
                        <input type="hidden" name="id" value="#qUsuario.id_usuario#">

                        <!--- Sección de datos del usuario --->
                        <div class="section">
                            <!--- Título de la sección --->
                            <div class="section-title">
                                Datos usuarios
                            </div>

                            <!--- Grupo de campos --->
                            <div class="field-group triple">
                                <!--- Campo de usuario --->
                                <div class="form-field">
                                    <!--- Usuario --->
                                    <label class="form-label">
                                        Usuario:
                                    </label>

                                    <!--- Campo de texto para el nombre de usuario --->
                                    <input type="text" name="usuario" value="#qUsuario.usuario#" required class="form-input-general" readonly><br>
                                </div>

                                <!--- Campo de rol --->
                                <div class="form-field">
                                    <!--- Rol de usuario --->
                                    <label class="form-label">
                                        Rol:
                                    </label>

                                    <!--- Campo de texto para el rol del usuario --->
                                    <input type="text" name="rol" value="#qUsuario.rol#" required class="form-input-general" readonly><br>
                                </div>

                                <!--- Campo de área --->
                                <div class="form-field">
                                    <!--- Área de adscripción --->
                                    <label class="form-label">
                                        Área:
                                    </label>

                                    <!--- Campo de texto para el nombre de area del usuario --->
                                    <input type="text" name="area" value="#qUsuario.nombre_area#" required class="form-input-general" readonly><br>
                                </div>
                            </div>
                        </div>
                        
                        <!--- Sección de datos personales --->
                        <div class="section">
                            <!--- Título de la sección --->
                            <div class="section-title">
                                Datos de Usuario
                            </div>

                            <!--- Grupo de campos --->
                            <div class="field-group triple">
                                <!--- Campo de nombre --->
                                <div class="form-field">
                                    <!--- Nombre --->
                                    <label class="form-label">
                                        Nombre:
                                    </label>

                                    <!--- Campo de texto para el nombre --->
                                    <input type="text" name="nombre" value="#qUsuario.nombre#" required class="form-input-general" readonly><br>
                                </div>

                                <!--- Campo de apellido paterno --->
                                <div class="form-field">
                                    <!--- Apellido Paterno --->
                                    <label class="form-label">
                                        Apellido Paterno:
                                    </label>

                                    <!--- Campo de texto para el apellido paterno --->
                                    <input type="text" name="apellido_paterno" value="#qUsuario.apellido_paterno#" required class="form-input-general" readonly><br>
                                </div>

                                <!--- Campo de apellido materno --->
                                <div class="form-field">
                                    <!--- Apellido Materno --->
                                    <label class="form-label">
                                        Apellido Materno:
                                    </label>

                                    <!--- Campo de texto para el apellido materno --->
                                    <input type="text" name="apellido_materno" value="#qUsuario.apellido_materno#" required class="form-input-general" readonly><br>
                                </div>
                            </div>
                        </div>
                        
                        <!--- Sección de envío --->
                        <div class="submit-section">
                            <!--- Botón para guardar los cambios --->
                            <button type="submit" name="eliminar" class="submit-btn-eliminarUsuario">
                                Eliminar
                            </button>
                        </div>

                        <!--- Sección de navegación --->
                        <div class="submit-section">
                            <!--- Grupo de botones --->
                            <div class="field-group triple">
                                <!--- Botón para regresar a la página anterior --->
                                <a class="submit-btn-regresar submit-btn-regresar-text" id="btnRegresar">
                                    Regresar
                                </a>

                                <!--- Botón para ir al menú principal --->
                                <a href="menu.cfm" class="submit-btn-menu" style="text-decoration: none">
                                    Menu
                                </a>
                                
                                <!--- Botón para cerrar sesión --->
                                <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                                    Cerrar Sesion
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </cfoutput>

        <!--- Script para manejar el botón de regresar --->
        <script>
            <!--- Capturamos el botón --->
            const btnRegresar = document.getElementById('btnRegresar');

            <!--- Agregamos el evento click --->
            btnRegresar.addEventListener('click', function() {
                <!--- Verificamos si hay una página de referencia --->
                if (document.referrer) {
                    // Va a la página desde donde llegó
                    window.location.href = document.referrer;
                } else {
                    // Si no hay referrer, va a una página por defecto
                    window.location.href = 'listaUsuarios.cfm';
                }
            });
        </script>
    </body>
</html>