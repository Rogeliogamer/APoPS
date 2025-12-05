<!--- 
 * Nombre de la página: administracion/registrarUsuarios.cfm
 * 
 * Descripción: 
 * Página para registrar nuevos usuarios en el sistema.
 * Incluye un formulario que recopila datos personales y de usuario, 
 * y envía la información a procesarRegistroUsuario.cfm para su procesamiento.
 * 
 * Roles:
 * Admin: Solo los usuarios con rol 'admin' pueden acceder a esta página.
 * 
 * Paginas relacionadas:
 * menu.cfm: Página principal del menú.
 * procesarRegistroUsuario.cfm: Página que procesa el registro de usuarios.
 * adminPanel.cfm: Panel de administración.
 * cerrarSesion.cfm: Página para cerrar sesión.
 * validacionRegistrarUsuarios.js: Archivo JavaScript para validación del formulario.
 * 
 * Autor: Rogelio Pérez Guevara
 * 
 * Fecha de creación: 25-09-2025
 * 
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
        <link rel="icon" href="../elements/icono.ico" type="image/x-icon">
        <!--- Título de la página --->
        <title>Registrar Usuario</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/registrarUsuarios.css">
        <link rel="stylesheet" href="../css/botones.css">
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

        <!--- Contenedor principal --->
        <div class="container">
            <!--- Contenedor del formulario --->
            <div class="header">
                <!--- Nombre del usuario y rol que esta conectado --->
                <div class="logo">
                    <!--- Llamar al componente para mostrar el usuario conectado y su rol --->
                    <cfset usuarioRol = createObject("component", "../componentes/usuarioConectadoSAdmin").render()>
                    <!--- Mostrar el nombre del usuario y su rol --->
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>

                <!--- Nombre del formulario --->
                <h1>Registro de Usuario</h1>
            </div>

            <!--- Formulario de Registro --->
            <div class="form-container">
                <!--- Mostrar mensajes de éxito o error --->
                <cfif structKeyExists(session, "mensajeRegistro")>
                    <!--- Verificar el tipo de mensaje para aplicar el estilo adecuado --->
                    <cfif structKeyExists(session, "tipoMensaje") AND session.tipoMensaje EQ "error">
                        <!--- Estilo para mensajes de error --->
                        <div class="mensaje-error">
                            <!--- Mostrar el mensaje de error --->
                            <cfoutput>
                                #session.mensajeRegistro#
                            </cfoutput>
                        </div>

                    <!--- Estilo para mensajes de éxito --->
                    <cfelse>
                        <!--- Mostrar el mensaje de éxito --->
                        <div class="mensaje-exito">
                            <!--- Mostrar el mensaje de éxito --->
                            <cfoutput>
                                #session.mensajeRegistro#
                            </cfoutput>
                        </div>
                    </cfif>

                    <!--- Limpiar los mensajes de la sesión después de mostrarlos --->
                    <cfset structDelete(session, "mensajeRegistro")>
                    <!--- Limpiar el tipo de mensaje de la sesión después de mostrarlo --->
                    <cfset structDelete(session, "tipoMensaje")>
                </cfif>

                <!--- El formulario envía los datos a procesarRegistroUsuario.cfm para su procesamiento --->
                <form action="procesarRegistroUsuario.cfm" method="post">
                    <!--- Sección de Datos Personales --->
                    <div class="section">
                        <!--- Título de la sección --->
                        <div class="section-title">
                            Datos Personales
                        </div>

                        <!--- Grupo de campos para organizar los inputs --->
                        <div class="field-group triple">
                            <!--- Campo para Nombre --->
                            <div class="form-field">
                                <!--- Etiqueta para el campo Nombre --->
                                <label class="form-label" for="nombre">
                                    Nombre
                                </label>
                                <!--- Input de texto para el Nombre --->
                                <input type="text"
                                    id="nombre"
                                    name="nombre"
                                    class="form-input-general" 
                                    pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+"
                                    title="Solo se permiten letras y espacios"
                                    oninput="soloLetras(this)"
                                    required>
                            </div>

                            <!--- Campo para Apellido Paterno --->
                            <div class="form-field">
                                <!--- Etiqueta para el campo Apellido Paterno --->
                                <label class="form-label" for="apellido_paterno">
                                    Apellido Paterno
                                </label>
                                <!--- Input de texto para el Apellido Paterno --->
                                <input type="text"
                                    id="apellido_paterno"
                                    name="apellido_paterno"
                                    class="form-input-general"
                                    pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+"
                                    title="Solo se permiten letras y espacios"
                                    oninput="soloLetras(this)"
                                    required>
                            </div>

                            <!--- Campo para Apellido Materno --->
                            <div class="form-field">
                                <!--- Etiqueta para el campo Apellido Materno --->
                                <label class="form-label" for="apellido_materno">
                                    Apellido Materno
                                </label>
                                <!--- Input de texto para el Apellido Materno --->
                                <input type="text"
                                id="apellido_materno"
                                name="apellido_materno"
                                class="form-input-general"
                                pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+"
                                title="Solo se permiten letras y espacios"
                                oninput="soloLetras(this)" required>
                            </div>
                        </div>

                        <!--- Grupo de campos para organizar los inputs --->
                        <div class="field-group single">
                            <!--- Campo para Área de Adscripción --->
                            <div class="form-field">
                                <!--- Etiqueta para el campo Área de Adscripción --->
                                <label class="form-label" for="id_area">
                                    Área de Adscripción
                                </label>

                                <!--- Select para elegir el Área de Adscripción --->
                                <select id="id_area" name="id_area" class="form-input-general" required>
                                    <!--- Opción por defecto --->
                                    <option value="">
                                        Selecciona un área
                                    </option>

                                    <!--- Consulta para obtener las áreas de adscripción desde la base de datos --->
                                    <cfquery name="qAreas" datasource="autorizacion">
                                        SELECT id_area, nombre
                                        FROM area_adscripcion
                                    </cfquery>

                                    <!--- Bucle para generar las opciones del select dinámicamente --->
                                    <cfoutput query="qAreas">
                                        <option value="#id_area#">#nombre#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!--- Sección de Datos de Usuario --->
                    <div class="section">
                        <!--- Título de la sección --->
                        <div class="section-title">
                            Datos de Usuario
                        </div>

                        <!--- Grupo de campos para organizar los inputs --->
                        <div class="field-group double">
                            <!--- Campo para Usuario y Rol --->
                            <div class="form-field">
                                <!--- Etiqueta para el campo Usuario --->
                                <label class="form-label" for="usuario">
                                    Usuario
                                </label>

                                <!--- Input de texto para el Usuario --->
                                <input type="text"
                                    id="usuario"
                                    name="usuario"
                                    class="form-input-general"
                                    oninput="sanitizarUsuario(this)"
                                    placeholder="Solo letras y números"
                                    autocomplete="off"
                                    required>
                            </div>

                            <!--- Campo para Rol --->
                            <div class="form-field">
                                <!--- Etiqueta para el campo Rol --->
                                <label class="form-label" for="rol">
                                    Rol
                                </label>

                                <!--- Select para elegir el Rol --->
                                <select id="rol" name="rol" class="form-input-general" required>
                                    <!--- Opción por defecto --->
                                    <option value="">
                                        Selecciona un rol
                                    </option>

                                    <!--- Consulta para obtener los valores del enum 'rol' desde la base de datos --->
                                    <cfquery name="qRol" datasource="autorizacion">
                                        SHOW COLUMNS FROM usuarios LIKE 'rol'
                                    </cfquery>

                                    <!--- Procesamiento del resultado para extraer los valores del enum --->
                                    <cfset enumStringR = qRol.Type[1]> <!--- "enum('Personal','Oficial')" --->
                                    <cfset enumStringR = REReplace(enumStringR,"^enum\('","", "all")> <!--- quita enum(' al inicio --->
                                    <cfset enumStringR = REReplace(enumStringR,"'\)$","", "all")>  <!--- quita ') al final --->
                                    <cfset enumListR = REReplace(enumStringR,"','",",","all")> <!--- reemplaza ',' por , --->
                                                
                                    <!--- Bucle para generar las opciones del select dinámicamente --->
                                    <cfoutput>
                                        <cfloop list="#enumListR#" index="tipo">
                                            <option value="#tipo#">#tipo#</option>
                                        </cfloop>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>

                        <!--- Grupo de campos para organizar los inputs --->
                        <div class="field-group single">
                            <!-- Campo para Contraseña -->
                            <div class="form-field">
                                <!--- Etiqueta para el campo Contraseña --->
                                <label class="form-label" for="contrasena">
                                    Contraseña
                                </label>
                                <!--- Input de tipo password para la Contraseña --->
                                <input type="password"
                                    id="contrasena"
                                    name="contrasena"
                                    class="form-input-general"
                                    minlength="8"
                                    pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[°|¬!@#$%&/()=?'\\¡¿¨´*+~]}`[{^;,:._&lt;&gt;/\-\+.&quot;]).{8,}$"
                                    title="La contraseña debe tener al menos 8 caracteres, incluyendo mayúsculas, minúsculas, números y un carácter especial."
                                    placeholder="Contraseña"
                                    required>
                                <span id="passwordMsg" class="mensaje-contraseña"></span>
                            </div>
                        </div>
                    </div>

                    <!--- Botón de Envío --->
                    <div class="submit-section">
                        <!--- Botón para enviar el formulario --->
                        <button type="submit" class="submit-btn-registrar">Registrar Usuario</button>
                    </div>

                    <div class="submit-section">
                        <!--- Enlace para regresar al menú principal --->
                        <a href="../adminPanel.cfm" class="submit-btn-menu">Menu</a>
                        <!--- Enlace para cerrar sesión --->
                        <a href="../cerrarSesion.cfm" class="submit-btn-cerrarSesion">
                            Cerrar Sesion
                        </a>
                    </div>
                </form>
            </div>        
        </div>
        
        <!--- Enlace al archivo JavaScript para validación del formulario --->
        <script src="../js/validacionRegistrarUsuarios.js"></script>
    </body>
</html>