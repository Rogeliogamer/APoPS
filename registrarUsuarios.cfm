<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Registrar Usuarios</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/globalForm.css">
    </head>
    <body>
        <!-- Contenedor principal -->
        <div class="container">
            <!-- Contenedor del formulario -->
            <div class="header">
                <!-- Encabezado del formulario -->
                <div class="logo">
                    Registro de Usuarios
                </div>

                <!-- Nombre del formulario -->
                <h1>Formulario de Registro</h1>
            </div>

            <!-- Formulario de Registro -->
            <div class="form-container">
                <!-- Mostrar mensajes de éxito o error -->
                <cfif structKeyExists(session, "mensajeRegistro")>
                    <!-- Verificar el tipo de mensaje para aplicar el estilo adecuado -->
                    <cfif structKeyExists(session, "tipoMensaje") AND session.tipoMensaje EQ "error">
                        <!-- Estilo para mensajes de error -->
                        <div style="padding: 15px; background-color: #fde2e2; color: #b00020; border-radius: 6px; margin-bottom: 20px;">
                            <!-- Mostrar el mensaje de error -->
                            <cfoutput>
                                #session.mensajeRegistro#
                            </cfoutput>
                        </div>

                    <!-- Estilo para mensajes de éxito -->
                    <cfelse>
                        <!-- Mostrar el mensaje de éxito -->
                        <div style="padding: 15px; background-color: #e0f7e9; color: #2d6a4f; border-radius: 6px; margin-bottom: 20px;">
                            <!-- Mostrar el mensaje de éxito -->
                            <cfoutput>
                                #session.mensajeRegistro#
                            </cfoutput>
                        </div>
                    </cfif>

                    <!-- Limpiar los mensajes de la sesión después de mostrarlos -->
                    <cfset structDelete(session, "mensajeRegistro")>
                    <!-- Limpiar el tipo de mensaje de la sesión después de mostrarlo -->
                    <cfset structDelete(session, "tipoMensaje")>
                </cfif>

                <!-- El formulario envía los datos a procesarRegistroUsuario.cfm para su procesamiento -->
                <form action="procesarRegistroUsuario.cfm" method="post">
                    <!-- Sección de Datos Personales -->
                    <div class="section">
                        <!-- Título de la sección -->
                        <div class="section-title">
                            Datos Personales
                        </div>

                        <!-- Grupo de campos para organizar los inputs -->
                        <div class="field-group triple">
                            <!-- Campo para Nombre -->
                            <div class="form-field">
                                <!-- Etiqueta para el campo Nombre -->
                                <label class="form-label" for="nombre">Nombre</label>
                                <!-- Input de texto para el Nombre -->
                                <input type="text" id="nombre" name="nombre" class="form-input" pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+" title="Solo se permiten letras y espacios" oninput="soloLetras(this)" required>
                            </div>

                            <!-- Campo para Apellido Paterno -->
                            <div class="form-field">
                                <!-- Etiqueta para el campo Apellido Paterno -->
                                <label class="form-label" for="apellido_paterno">Apellido Paterno</label>
                                <!-- Input de texto para el Apellido Paterno -->
                                <input type="text" id="apellido_paterno" name="apellido_paterno" class="form-input" required pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+" title="Solo se permiten letras y espacios" oninput="soloLetras(this)" required>
                            </div>

                            <!-- Campo para Apellido Materno -->
                            <div class="form-field">
                                <!-- Etiqueta para el campo Apellido Materno -->
                                <label class="form-label" for="apellido_materno">Apellido Materno</label>
                                <!-- Input de texto para el Apellido Materno -->
                                <input type="text" id="apellido_materno" name="apellido_materno" class="form-input" required pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+" title="Solo se permiten letras y espacios" oninput="soloLetras(this)" required>
                            </div>
                        </div>

                        <!-- Grupo de campos para organizar los inputs -->
                        <div class="field-group single">
                            <!-- Campo para Área de Adscripción -->
                            <div class="form-field">
                                <!-- Etiqueta para el campo Área de Adscripción -->
                                <label class="form-label" for="id_area">
                                    Área de Adscripción
                                </label>

                                <!-- Select para elegir el Área de Adscripción -->
                                <select id="id_area" name="id_area" class="form-input" required>
                                    <!-- Opción por defecto -->
                                    <option value="">
                                        Selecciona un área
                                    </option>

                                    <!-- Consulta para obtener las áreas de adscripción desde la base de datos -->
                                    <cfquery name="qAreas" datasource="autorizacion">
                                        SELECT id_area, nombre
                                        FROM area_adscripcion
                                    </cfquery>

                                    <!-- Bucle para generar las opciones del select dinámicamente -->
                                    <cfoutput query="qAreas">
                                        <option value="#id_area#">#nombre#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Sección de Datos de Usuario -->
                    <div class="section">
                        <!-- Título de la sección -->
                        <div class="section-title">
                            Datos de Usuario
                        </div>

                        <!-- Grupo de campos para organizar los inputs -->
                        <div class="field-group double">
                            <!-- Campo para Usuario y Rol -->
                            <div class="form-field">
                                <!-- Etiqueta para el campo Usuario -->
                                <label class="form-label" for="usuario">
                                    Usuario
                                </label>

                                <!-- Input de texto para el Usuario -->
                                <input type="text" id="usuario" name="usuario" class="form-input" oninput="sanitizarUsuario(this)" oninput="this.value = this.value.replace(/<|>|'|&quot;|;|--/g, '')" required>
                            </div>

                            <!-- Campo para Rol -->
                            <div class="form-field">
                                <!-- Etiqueta para el campo Rol -->
                                <label class="form-label" for="rol">
                                    Rol
                                </label>

                                <!-- Select para elegir el Rol -->
                                <select id="rol" name="rol" class="form-input" required>
                                    <!-- Opción por defecto -->
                                    <option value="">
                                        Selecciona un rol
                                    </option>

                                    <!-- Consulta para obtener los valores del enum 'rol' desde la base de datos -->
                                    <cfquery name="qRol" datasource="autorizacion">
                                        SHOW COLUMNS FROM usuarios LIKE 'rol'
                                    </cfquery>

                                    <!-- Procesamiento del resultado para extraer los valores del enum -->
                                    <cfset enumStringR = qRol.Type[1]> <!--- "enum('Personal','Oficial')" --->
                                    <cfset enumStringR = REReplace(enumStringR,"^enum\('","", "all")> <!--- quita enum(' al inicio --->
                                    <cfset enumStringR = REReplace(enumStringR,"'\)$","", "all")>  <!--- quita ') al final --->
                                    <cfset enumListR = REReplace(enumStringR,"','",",","all")> <!--- reemplaza ',' por , --->
                                                
                                    <!-- Bucle para generar las opciones del select dinámicamente -->
                                    <cfoutput>
                                        <cfloop list="#enumListR#" index="tipo">
                                            <option value="#tipo#">#tipo#</option>
                                        </cfloop>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>

                        <!-- Grupo de campos para organizar los inputs -->
                        <div class="field-group single">
                            <!-- Campo para Contraseña -->
                            <div class="form-field">
                                <!-- Etiqueta para el campo Contraseña -->
                                <label class="form-label" for="contrasena">
                                    Contraseña
                                    </label>
                                <!-- Input de tipo password para la Contraseña -->
                                <input type="password" id="contrasena" name="contrasena" class="form-input"  minlength="8" pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[°|¬!@#$%&/()=?'\\¡¿¨´*+~]}`[{^;,:._&lt;&gt;/\-\+.&quot;]).{8,}$" title="La contraseña debe tener al menos 8 caracteres, incluyendo mayúsculas, minúsculas, números y un carácter especial." placeholder="Contraseña" required>
                                <span id="passwordMsg" style="color:red; font-size:12px;"></span>
                            </div>
                        </div>
                    </div>

                    <!-- Botón de Envío -->
                    <div class="submit-section">
                        <!-- Botón para enviar el formulario -->
                        <button type="submit" class="submit-btn">Registrar Usuario</button>
                    </div>

                    <div class="submit-section">
                        <!-- Enlace para regresar al menú principal -->
                        <a href="menu.cfm" class="submit-btn" style="text-decoration: none">Menu</a>
                    </div>
                </form>
            </div>        
        </div>

        <script>
            // Función para permitir solo letras y espacios en los campos de texto
            function soloLetras(input) {
                input.value = input.value.replace(/[^A-Za-zÁÉÍÓÚáéíóúÑñ\s]/g,'');
            }
        </script>

        <script>
            /* Sanitización del usuario: elimina etiquetas HTML y espacios extra */
            function sanitizarUsuario(input) {
                // Remueve etiquetas < > y espacios al inicio/fin
                input.value = input.value.replace(/<[^>]*>?/gm, '').trim();
            }
        </script>

        <script>
            const contrasenaInput = document.getElementById('contrasena');
            const submitBtn = document.querySelector('button[type="submit"]');
            const passwordMsg = document.getElementById('passwordMsg');

            contrasenaInput.addEventListener('input', function() {
                const valor = this.value;

                // Regex para validar contraseña
                //const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!¡@#$%^&*(),.?":{}|<>~`_\-+=;/;]).{8,}$/;
                //const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|[\]\\<>~`_\-+=;\/])).{8,}$/;
                //const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>~`_\-+=;\/&quot;&apos;])).{8,}$/;
                //const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[°\|¬!@#$%&\/()\=?'\\¡¿¨´*+~\]\}`\[\{\^;,:._<>\/*\-+\.])).{8,}$/;

                const regex = new RegExp(
    "^" +                         // Inicio de la cadena
    "(?=.*[a-z])" +               // Al menos una letra minúscula
    "(?=.*[A-Z])" +               // Al menos una letra mayúscula
    "(?=.*\\d)" +                 // Al menos un número
    "(?=.*[" +                     // Al menos un carácter especial de la lista
        "°\\|¬!@#$%&/()=?'\\\\¡¿¨´*+~\\]\\}`\\[\\{\\^;,:._<>/*\\-+\\." +
    "])" +
    ".{8,}" +                     // Al menos 8 caracteres en total
    "$"                            // Fin de la cadena
);

                if (!regex.test(valor)) {
                    // Mostrar mensaje en el span
                    passwordMsg.textContent = "La contraseña debe tener al menos 8 caracteres, incluyendo mayúsculas, minúsculas, número y un carácter especial.";
                    // Deshabilitar botón
                    submitBtn.disabled = true;
                } else {
                    // Limpiar mensaje
                    passwordMsg.textContent = "";
                    // Habilitar botón
                    submitBtn.disabled = false;
                }
            });
        </script>
    </body>
</html>