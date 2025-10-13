<!---
 * Página pública de acceso (login).
 *
 * Características:
 * - Accesible sin autenticación previa, ya que permite iniciar sesión.
 * - Requiere credenciales válidas (usuario y contraseña) para acceder al sistema.
 * - Si las credenciales no son correctas, el acceso se deniega y el usuario permanece en `login.cfm`.
 *
 * Nota:
 * Esta página actúa como puerta de entrada al sistema; todas las demás requieren sesión activa.
--->

<!DOCTYPE html>
<html>
    <head>
        <!-- Metadatos y enlaces a estilos -->
        <meta charset="UTF-8">
        <!-- Vista adaptable para dispositivos móviles -->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Título de la página -->
        <title>Login</title>
        <!-- Enlace a fuentes y hojas de estilo -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!-- Contenedor principal -->
        <div class="container">
            <!-- Contenedor del formulario -->
            <div class="header">
                <!-- Encabezado del formulario -->
                <h1>Iniciar Sesión</h1>
            </div>

            <!-- Contenedor del formulario -->
            <div class="form-container">
                <!-- Mostrar mensajes de error si existen -->
                <cfif structKeyExists(session, "mensajeLogin")>
                    <div style="padding: 15px; background-color: #fde2e2; color: #b00020; border-radius: 6px; margin-bottom: 20px;">
                        <!-- Mostrar el mensaje de error almacenado en la sesión -->
                        <cfoutput>#session.mensajeLogin#</cfoutput>
                    </div>
                    <!-- Eliminar el mensaje de error de la sesión después de mostrarlo -->
                    <cfset structDelete(session, "mensajeLogin")>
                </cfif>
                
                <!-- Formulario de inicio de sesión -->
                <form action="login.cfm" method="post">
                    <!-- Grupo de campos para Usuario y Contraseña -->
                    <div class="field-group single">
                        <div class="form-field">
                            <!-- Campo para el nombre de usuario -->
                            <label class="form-label" for="usuario">Usuario:</label>
                            <input type="text" id="usuario" name="usuario" placeholder="Username" class="form-input-general" required>
                        </div>

                        <div class="form-field">
                            <!-- Campo para la contraseña -->
                            <label class="form-label" for="contrasena">Contraseña:</label>
                            <input type="password" id="contrasena" name="contrasena" placeholder="password" class="form-input-general" required>
                        </div>
                    </div>

                    <div class="submit-section">
                        <!-- Botón para enviar el formulario -->
                        <button type="submit" class="submit-btn-entrar">Entrar</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Procesar el formulario si se han enviado datos -->
        <cfif structKeyExists(form,"usuario") AND structKeyExists(form,"contrasena")>
            <!-- Hashear la contraseña usando SHA-256 -->
            <cfset contrasenaHasheada = hash(form.contrasena, "SHA-256")>

            <!-- Consulta para verificar las credenciales -->
            <cfquery name="qLogin" datasource="autorizacion">
                SELECT u.id_usuario, u.usuario, u.rol, d.id_area, u.activo
                FROM usuarios u
                INNER JOIN datos_usuario d ON u.id_datos = d.id_datos
                WHERE u.usuario = <cfqueryparam value="#form.usuario#" cfsqltype="cf_sql_varchar">
                AND u.contraseña = <cfqueryparam value="#contrasenaHasheada#" cfsqltype="cf_sql_varchar">
                AND u.activo = 1
            </cfquery>

            <!-- Verificar si se encontró un usuario con las credenciales proporcionadas -->
            <cfif qLogin.recordCount EQ 1>
                <cfset session.id_usuario = qLogin.id_usuario>
                <cfset session.usuario = qLogin.usuario>
                <cfset session.rol = qLogin.rol>
                <cfset session.id_area = qLogin.id_area>

                <cflocation url="menu.cfm">
            <cfelse>
                <cfset session.mensajeLogin = "Usuario o contraseña incorrectos.">
                <cflocation url="login.cfm" addtoken="no">
            </cfif>
        </cfif>
    </body>
</html>
