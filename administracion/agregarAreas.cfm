<!--- 
 * Página `pase.cfm` para el llenado del formulario de solicitud.
 *
 * Funcionalidad:
 * - Permite al solicitante completar los campos necesarios para generar la solicitud.
 * - La solicitud será posteriormente revisada y firmada por las autoridades correspondientes.
 * - Todos los campos requeridos deben ser llenados; de lo contrario, no se podrá enviar la solicitud.
 *
 * Uso:
 * - Esta página centraliza la captura de información antes de iniciar el proceso de aprobación.
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
        <title>Permiso o Pase de Salida</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/svgFirma.css">
        <link rel="stylesheet" href="../css/pase.css">
        <link rel="stylesheet" href="../css/botones.css">
    </head>
    <body>
        <!--- Validar que exista un sesión activa --->
        <cfif NOT structKeyExists(session, "rol") OR len(trim(session.rol)) EQ 0>
            <!--- No hay sesión activa, redirigir al login --->
            <cflocation url="../login.cfm" addtoken="no">
        </cfif>

        <cfset mensaje = "">
        <cfset tipoMensaje = "">

        <cfif structKeyExists(form, "submit")>
            <cfset nombreArea = trim(form.area)>

            <!--- Validación: Solo letras y espacios (incluye tildes y ñ) --->
            <!--- Regex: ^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$ --->
            <cfif NOT REFind("^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$", nombreArea)>
                <cfset mensaje = "Error: El nombre del área solo puede contener letras y espacios.">
                <cfset tipoMensaje = "error">
            <cfelse>
                <!--- Verificar si ya existe --->
                <cfquery name="qCheck" datasource="autorizacion">
                    SELECT id_area FROM area_adscripcion 
                    WHERE nombre = <cfqueryparam value="#nombreArea#" cfsqltype="cf_sql_varchar">
                </cfquery>

                <cfif qCheck.recordCount GT 0>
                    <cfset mensaje = "Error: El área '#nombreArea#' ya existe.">
                    <cfset tipoMensaje = "error">
                <cfelse>
                    <!--- Insertar --->
                    <cftry>
                        <cfquery datasource="autorizacion">
                            INSERT INTO area_adscripcion (nombre)
                            VALUES (<cfqueryparam value="#nombreArea#" cfsqltype="cf_sql_varchar">)
                        </cfquery>
                        <cfset mensaje = "Área '#nombreArea#' agregada correctamente.">
                        <cfset tipoMensaje = "exito">
                        <!--- Limpiar el campo para la próxima captura --->
                        <cfset form.area = "">
                    <cfcatch type="any">
                        <cfset mensaje = "Error en base de datos: #cfcatch.message#">
                        <cfset tipoMensaje = "error">
                    </cfcatch>
                    </cftry>
                </cfif>
            </cfif>
        </cfif>

        <!--- Contenedor principal --->
        <div class="container">
            <!--- Encabezado de la página --->
            <div class="header">
                <!--- Logo y título --->
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "../componentes/usuarioConectadoSSoli").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <!--- Título de la página --->
                <h1>Agregar Areas</h1>
            </div>

            <!--- Mensajes de Alerta --->
            <cfif len(mensaje) GT 0>
                <cfoutput>
                    <div style="padding: 15px; margin: 20px; border-radius: 8px; text-align: center; font-weight: bold;
                        background-color: #(tipoMensaje EQ 'error' ? '##ffebee' : '##e8f5e9')#;
                        color: #(tipoMensaje EQ 'error' ? '##c62828' : '##2e7d32')#;
                        border: 1px solid #(tipoMensaje EQ 'error' ? '##ef9a9a' : '##a5d6a7')#;">
                        #mensaje#
                    </div>
                </cfoutput>
            </cfif>

            <!--- Contenedor del formulario --->
            <div class="form-container">
                <!--- Formulario de Solicitud de Permiso o Pase de Salida --->
                <form id="formArea" action="" method="post">
                    <!--- Descripción de la Solicitud --->
                    <div class="section">
                        <!--- Título de la sección --->
                        <div class="section-title">
                            Nueva Area de Adscripcion
                        </div>

                        <!--- Grupo de campos para tipo de solicitud, tipo de permiso, fecha y tiempo solicitado --->
                        <div class="form-field">
                            <!--- Seleccion del tipo de solicitud --->
                            <label class="form-label">
                                Nombre del Area
                            </label>

                            <cfoutput> 
                                <input type="text"
                                    name="area" 
                                    id="area" 
                                    class="form-input-general" 
                                    placeholder="Nombre del Area"
                                    required="yes"
                                    message="Por favor ingrese el nombre del area">
                            </cfoutput>
                            <small style="color: #666; margin-top: 5px;">* Solo letras y espacios permitidos.</small>
                        </div>
                    </div>

                    <!--- Botón de Envío --->
                    <div class="submit-section">
                        <!--- Botón para enviar la solicitud --->
                        <button type="submit" name="submit" class="submit-btn-enviar">
                            Guardar Area
                        </button>
                    </div>
                </form>

                <!--- Sección de botones para menú y cerrar sesión --->
                <div class="submit-section">
                    <!---- Grupo de botones --->
                    <div class="field-group">
                        <!--- Botón para ir al menú principal --->
                        <a href="../adminPanel.cfm" class="submit-btn-menu submit-btn-menu-text">
                            Menu
                        </a>
                        
                        <!--- Botón para cerrar sesión --->
                        <a href="../cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!--- Script simple para validación extra en JS (opcional pero recomendado) --->
        <script>
            document.getElementById('area').addEventListener('input', function(e) {
                // Reemplaza cualquier caracter que no sea letra o espacio
                var valor = e.target.value;
                e.target.value = valor.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
            });
        </script>
    </body>
</html>