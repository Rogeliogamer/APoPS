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
        <link rel="icon" href="../elements/icono.ico" type="image/x-icon">
        <!--- Título de la página --->
        <title>Reset Contraseña</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/botones.css">
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

        <!--- Parámetro de entrada --->
        <cfparam name="form.id" default="0">
        <cfset mensajeError = "">
        
        <cfif structKeyExists(form, "reset")>
            <cfset contrasena = form.contrasena>
            <cfset errores = []>
            <cfif len(contrasena) LT 8>
                <cfset arrayAppend(errores, "Mínimo 8 caracteres.")>
            </cfif>
            <cfif NOT refind("[A-Z]", contrasena)>
                <cfset arrayAppend(errores, "Falta una mayúscula.")>
            </cfif>
            <cfif NOT refind("[a-z]", contrasena)>
                <cfset arrayAppend(errores, "Falta una minúscula.")>
            </cfif>
            <cfif NOT refind("[0-9]", contrasena)>
                <cfset arrayAppend(errores, "Falta un número.")>
            </cfif>
            <cfif NOT refind("[°\|¬!\##$%&/()=?'\\¡¿¨´*+~\]\}`\[\{^;,:._<>/*\-+.]", contrasena)>
                <cfset arrayAppend(errores, "Falta un carácter especial.")>
            </cfif>

            <cfif arrayLen(errores) GT 0>
                <cfset mensajeError = "La contraseña no es segura: " & arrayToList(errores, ", ")>
            <cfelse>
                <cftry>
                    <cfset contrasenaHash = hash(contrasena, "SHA-256")>

                    <cfquery datasource="autorizacion">
                        UPDATE usuarios
                        SET contraseña = <cfqueryparam value="#contrasenaHash#" cfsqltype="cf_sql_varchar">
                        WHERE id_usuario = <cfqueryparam value="#form.id#" cfsqltype="cf_sql_integer">
                    </cfquery>

                    <cfset session.mensajeRegistro = "Contraseña actualizada correctamente.">
                    <cflocation url="listaUsuariosReset.cfm" addtoken="no">

                    <cfcatch type="any">
                        <cfset mensajeError = "Error técnico al guardar: " & cfcatch.message>
                    </cfcatch>
                </cftry>
            </cfif>
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

        <!--- Formulario de edición --->
        <cfoutput>
            <!--- Contenedor principal --->
            <div class="container">
                <!--- Contenedor del formulario --->
                <div class="header">
                    <!--- Logo y título --->
                    <div class="logo">
                        <cfset usuarioRol = createObject("component", "../componentes/usuarioConectadoSAdmin").render()>
                        <cfoutput>#usuarioRol#</cfoutput>
                    </div>

                    <!--- Nombre del usuario --->
                    <h1>Reset -> #qUsuario.usuario#</h1>
                </div>

                <cfif len(mensajeError)>
                    <div style="background-color: ##ffebee; color: ##c62828; padding: 15px; border-radius: 8px; margin: 20px; border: 1px solid ##ef9a9a; text-align: center;">
                        <strong>Error:</strong> #mensajeError#
                    </div>
                </cfif>

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
                                    <input type="text" value="#qUsuario.usuario#" class="form-input-general" readonly>
                                </div>

                                <!--- Campo de rol --->
                                <div class="form-field">
                                    <!--- Rol de usuario --->
                                    <label class="form-label">
                                        Rol:
                                    </label>

                                    <!--- Campo de texto para el rol del usuario --->
                                    <input type="text" value="#qUsuario.rol#" class="form-input-general" readonly>
                                </div>

                                <!--- Campo de área --->
                                <div class="form-field">
                                    <!--- Área de adscripción --->
                                    <label class="form-label">
                                        Área:
                                    </label>

                                    <!--- Campo de texto para el nombre de area del usuario --->
                                    <input type="text" name="area" value="#qUsuario.nombre_area#" class="form-input-general" readonly>
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
                                    <input type="text" value="#qUsuario.nombre#" class="form-input-general" readonly>
                                </div>

                                <!--- Campo de apellido paterno --->
                                <div class="form-field">
                                    <!--- Apellido Paterno --->
                                    <label class="form-label">
                                        Apellido Paterno:
                                    </label>

                                    <!--- Campo de texto para el apellido paterno --->
                                    <input type="text" value="#qUsuario.apellido_paterno#" class="form-input-general" readonly>
                                </div>

                                <!--- Campo de apellido materno --->
                                <div class="form-field">
                                    <!--- Apellido Materno --->
                                    <label class="form-label">
                                        Apellido Materno:
                                    </label>

                                    <!--- Campo de texto para el apellido materno --->
                                    <input type="text" value="#qUsuario.apellido_materno#" class="form-input-general" readonly><br>
                                </div>
                            </div>
                        </div>

                        <!--- Seccion de Reset Contraseña --->
                        <div class="section">
                            <!--- Título de la sección --->
                            <div class="section-title">
                                Nueva Contraseña
                            </div>

                            <!--- Campo de usuario --->
                            <div class="form-field">
                                <!--- Usuario --->
                                <label class="form-label">
                                    Contraseña:
                                </label>

                                <!--- Campo de texto para el nombre de usuario --->
                                <input type="password" 
                                    id="contrasena"
                                    name="contrasena" 
                                    class="form-input-general"
                                    minlength="8"
                                    pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[°|¬!@##$%&/()=?'\\¡¿¨´*+~]}`[{^;,:._&lt;&gt;/\-\+.&quot;]).{8,}$"
                                    title="La contraseña debe tener al menos 8 caracteres, incluyendo mayúsculas, minúsculas, números y un carácter especial."
                                    placeholder="Contraseña Nueva"
                                    required>
                                <span id="passwordMsg" class="mensaje-contraseña"></span>
                            </div>
                        </div>
                        
                        <!--- Sección de envío --->
                        <div class="submit-section">
                            <!--- Botón para guardar los cambios --->
                            <button type="submit" name="reset" class="submit-btn-eliminarUsuario">
                                Actualizar Contraseña
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
                                <a href="../adminPanel.cfm" class="submit-btn-menu" style="text-decoration: none">
                                    Menu
                                </a>
                                
                                <!--- Botón para cerrar sesión --->
                                <a href="../cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
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
                    window.location.href = 'listaUsuariosReset.cfm';
                }
            });
        </script>

        <!--- Enlace al archivo JavaScript para validación del formulario --->
        <script src="../js/validacionResetContraseña.js"></script>
    </body>
</html>