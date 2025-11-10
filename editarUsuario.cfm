<!---
 * Página `editarUsuario.cfm` para la modificación de la información básica de un usuario.
 *
 * Funcionalidad:
 * - Permite al administrador editar los campos necesarios de la información del usuario seleccionado.
 * - Si los datos son válidos, se actualizan en la base de datos reemplazando la información anterior.
 * - Todos los campos requeridos deben ser completados; de lo contrario, no se podrá guardar la información.
 * - Al confirmar los cambios, se redirige automáticamente a la lista de usuarios.
 * - Si el usuario no existe, se muestra un mensaje de error.
 *
 * Uso:
 * - Página destinada a la edición y mantenimiento de la información de los usuarios registrados.
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

        <!--- Verificar que el formulario se haya enviado correctamente --->
        <cfif NOT structKeyExists(form, "id") OR NOT isNumeric(form.id) OR form.id LTE 0>
            <!--- Si no viene por POST o es inválido, redirigir a la lista --->
            <cflocation url="listaUsuarios.cfm" addtoken="no">
        </cfif>

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
                d.id_area
            FROM usuarios u
            INNER JOIN datos_usuario d ON u.id_datos = d.id_datos
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
        <!--- Limpiar la cadena para obtener solo los valores --->
        <cfset enumStringR = REReplace(enumStringR,"^enum\('","", "all")>.
        <!--- Eliminar el paréntesis final --->
        <cfset enumStringR = REReplace(enumStringR,"'\)$","", "all")>
        <!--- Reemplazar los separadores para crear una lista --->
        <cfset enumListR = REReplace(enumStringR,"','",",","all")>

        <!--- Procesar formulario --->
        <cfif structKeyExists(form, "guardar")>
            <!--- Actualizar tabla usuarios --->
            <cfquery datasource="autorizacion">
                UPDATE usuarios
                SET usuario = <cfqueryparam value="#form.usuario#" cfsqltype="cf_sql_varchar">,
                    rol = <cfqueryparam value="#form.rol#" cfsqltype="cf_sql_varchar">
                WHERE id_usuario = <cfqueryparam value="#form.id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <!--- Actualizar tabla datos_usuario --->
            <cfquery datasource="autorizacion">
                UPDATE datos_usuario
                SET nombre = <cfqueryparam value="#form.nombre#" cfsqltype="cf_sql_varchar">,
                    apellido_paterno = <cfqueryparam value="#form.apellido_paterno#" cfsqltype="cf_sql_varchar">,
                    apellido_materno = <cfqueryparam value="#form.apellido_materno#" cfsqltype="cf_sql_varchar">,
                    id_area = <cfqueryparam value="#form.id_area#" cfsqltype="cf_sql_integer">
                WHERE id_datos = <cfqueryparam value="#qUsuario.id_datos#" cfsqltype="cf_sql_integer">
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
                        <cfoutput>
                            #usuarioRol#
                        </cfoutput>
                    </div>

                    <!--- Nombre del usuario --->
                    <h1>#qUsuario.usuario#</h1>
                </div>

                <!--- Formulario de edición --->
                <div class="form-container">
                    <!--- Formulario --->
                    <form method="post">
                        <!-- Campo oculto con el ID del usuario -->
                        <input type="hidden" name="id" value="#qUsuario.id_usuario#">

                        <!--- Sección de datos del usuario --->
                        <div class="section">
                            <!--- Título de la sección --->
                            <div class="section-title">
                                Datos de Inicio de Sesión
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
                                    <input type="text" name="usuario" value="#qUsuario.usuario#" required class="form-input-general"><br>
                                </div>

                                <!--- Campo de rol --->
                                <div class="form-field">
                                    <!--- Rol de usuario --->
                                    <label class="form-label">
                                        Rol:
                                    </label>

                                    <!--- Lista desplegable para seleccionar el rol --->
                                    <select name="rol" required class="form-input-general">
                                        <!--- Iterar sobre los valores ENUM para crear las opciones --->
                                        <cfloop list="#enumListR#" index="tipo">
                                            <!--- Marcar la opción seleccionada --->
                                            <option value="#tipo#" <cfif tipo EQ qUsuario.rol>selected</cfif>>#tipo#</option>
                                        </cfloop>
                                    </select>
                                </div>

                                <!--- Campo de área --->
                                <div class="form-field">
                                    <!--- Área de adscripción --->
                                    <label class="form-label">
                                        Área:
                                    </label>

                                    <!--- Lista desplegable para seleccionar el área --->
                                    <select name="id_area" required class="form-input-general">
                                        <!--- Iterar sobre las áreas para crear las opciones --->
                                        <cfloop query="qAreas">
                                            <!--- Marcar la opción seleccionada --->
                                            <option value="#id_area#" <cfif id_area EQ qUsuario.id_area>selected</cfif>>#nombre#</option>
                                        </cfloop>
                                    </select>
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
                                    <input type="text" name="nombre" value="#qUsuario.nombre#" required class="form-input-general"><br>
                                </div>

                                <!--- Campo de apellido paterno --->
                                <div class="form-field">
                                    <!--- Apellido Paterno --->
                                    <label class="form-label">
                                        Apellido Paterno:
                                    </label>

                                    <!--- Campo de texto para el apellido paterno --->
                                    <input type="text" name="apellido_paterno" value="#qUsuario.apellido_paterno#" required class="form-input-general"><br>
                                </div>

                                <!--- Campo de apellido materno --->
                                <div class="form-field">
                                    <!--- Apellido Materno --->
                                    <label class="form-label">
                                        Apellido Materno:
                                    </label>

                                    <!--- Campo de texto para el apellido materno --->
                                    <input type="text" name="apellido_materno" value="#qUsuario.apellido_materno#" required class="form-input-general"><br>
                                </div>
                            </div>
                        </div>
                        
                        <!--- Sección de envío --->
                        <div class="submit-section">
                            <!--- Botón para guardar los cambios --->
                            <button type="submit" name="guardar" class="submit-btn-guardar">
                                Guardar cambios
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
                    <!--- Va a la página desde donde llegó --->
                    window.location.href = document.referrer;
                } else {
                    <!--- Si no hay referrer, va a una página por defecto --->
                    window.location.href = 'listaUsuarios.cfm';
                }
            });
        </script>
    </body>
</html>