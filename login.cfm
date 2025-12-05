<!---
 * Nombre de la pagina: login.cfm
 * 
 * Descripción:
 * Esta pagina no va permitir acceder al sistemas de acuerdo al tipo de rol de usuario,
 * por lo que de acuerdo a dicho rol se le permitirán ciertas funciones dentro del sistema.
 * En caso de no poder acceder se mostrara un mensaje de error y se mantendrá en la misma pagina
 * hasta que ingrese los datos correctos.
 * 
 * Roles:
 * - Usuarios: Pueden iniciar sesión y acceder al sistema según su rol.
 * - Administradores: Tienen acceso a funciones adicionales y pueden gestionar usuarios.
 * 
 * Páginas Relacionadas:
 * - `menu.cfm`: Página principal del sistema tras el inicio de sesión.
 * - `adminPanel.cfm`: Panel de administración para usuarios con rol de administrador.
 * - `elements/icono.ico`: Icono utilizado en la pestaña del navegador.
 * - `css/globalForm.css`: Hoja de estilos para formularios globales.
 * - `css/botones.css`: Hoja de estilos para botones.
 * 
 * Autor: Rogelio Pérez Guevara
 * Fecha de creación: 24-09-2025
 * Última modificación: 03-12-2025
 * Versión: 1.0
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
        <title>Login</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!--- Contenedor principal --->
        <div class="container">
            <!--- Contenedor del formulario --->
            <div class="header">
                <!--- Encabezado del formulario --->
                <h1>Iniciar Sesión</h1>
            </div>

            <!--- Contenedor del formulario --->
            <div class="form-container">
                <!--- Mostrar mensajes de error si existen --->
                <cfif structKeyExists(session, "mensajeLogin")>
                    <div style="padding: 15px; background-color: #fde2e2; color: #b00020; border-radius: 6px; margin-bottom: 20px;">
                        <!--- Mostrar el mensaje de error almacenado en la sesión --->
                        <cfoutput>#session.mensajeLogin#</cfoutput>
                    </div>
                    <!--- Eliminar el mensaje de error de la sesión después de mostrarlo --->
                    <cfset structDelete(session, "mensajeLogin")>
                </cfif>
                
                <!--- Formulario de inicio de sesión --->
                <form action="login.cfm" method="post">
                    <!--- Grupo de campos para Usuario y Contraseña --->
                    <div class="field-group single">
                        <div class="form-field">
                            <!--- Campo para el nombre de usuario --->
                            <label class="form-label" for="usuario">
                                Usuario:
                            </label>
                            <!--- Input para el nombre de usuario --->
                            <input type="text" id="usuario" name="usuario" placeholder="Username" class="form-input-general" required>
                        </div>

                        <div class="form-field">
                            <!--- Campo para la contraseña --->
                            <label class="form-label" for="contrasena">
                                Contraseña:
                            </label>
                            <!--- Input para la contraseña --->
                            <input type="password" id="contrasena" name="contrasena" placeholder="password" class="form-input-general" required>
                        </div>
                    </div>

                    <!--- Sección de envío del formulario --->
                    <div class="submit-section">
                        <!--- Botón para enviar el formulario --->
                        <button type="submit" class="submit-btn-entrar">
                            Entrar
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!--- Procesar el formulario si se han enviado datos --->
        <cfif structKeyExists(form,"usuario") AND structKeyExists(form,"contrasena")>
            <!--- Hashear la contraseña usando SHA-256 --->
            <cfset contrasenaHasheada = hash(form.contrasena, "SHA-256")>

            <!--- Consulta para verificar las credenciales --->
            <cfquery name="qLogin" datasource="autorizacion">
                SELECT u.id_usuario, 
                    u.usuario, 
                    u.rol, 
                    d.id_area, 
                    u.activo
                FROM usuarios u
                INNER JOIN datos_usuario d 
                    ON u.id_datos = d.id_datos
                WHERE u.usuario = <cfqueryparam value="#form.usuario#" cfsqltype="cf_sql_varchar">
                    AND u.contraseña = <cfqueryparam value="#contrasenaHasheada#" cfsqltype="cf_sql_varchar">
                    AND u.activo = 1
            </cfquery>

            <!--- Verificar si se encontró un usuario con las credenciales proporcionadas --->
            <cfif qLogin.recordCount EQ 1>
                <!--- Almacenar información del usuario en la sesión --->
                <cfset session.id_usuario = qLogin.id_usuario>
                <cfset session.usuario = qLogin.usuario>
                <cfset session.rol = qLogin.rol>
                <cfset session.id_area = qLogin.id_area>

                <cfif session.rol EQ "admin">
                    <cflocation url="adminPanel.cfm" addtoken="no">
                <cfelse>
                    <!--- Redirigir al menú principal después del inicio de sesión exitoso --->
                    <cflocation url="menu.cfm" addtoken="no">
                </cfif>
                
            <!--- Si las credenciales son incorrectas, mostrar mensaje de error --->
            <cfelse>
                <!--- Almacenar mensaje de error en la sesión --->
                <cfset session.mensajeLogin = "Usuario o contraseña incorrectos.">
                <!--- Redirigir de nuevo a la página de login --->
                <cflocation url="login.cfm" addtoken="no">
            </cfif>
        </cfif>
    </body>
</html>
