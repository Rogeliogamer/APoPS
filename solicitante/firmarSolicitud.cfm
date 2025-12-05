<!---
 * Nombre de la pagina: solicitar/firmarSolicitud.cfm
 * 
 * Descripción:
 * Esta página permite a los usuarios jefe firmar automáticamente las solicitudes que han sido enviadas por los solicitantes y que están pendientes de ser aprobadas o rechazadas.
 * Los usuarios RH también firman automáticamente las solicitudes que han sido aprobadas por los jefes y están pendientes de ser validadas.
 * 
 * Roles:
 * - Jefe: Firma las solicitudes de sus subordinados.
 * - RH: Firma las solicitudes aprobadas por los jefes.
 * - Admin: Firma las solicitudes en calidad de administrador. Solo en casos especiales.
 * 
 * Paginas relacionadas:
 * http://www.w3.org/2000/svg: Especificación SVG
 * https://fonts.googleapis.com/css2?family=Great+Vibes&display=swap: Fuente para la firma
 * guardarFirma.cfm: Página que procesa y guarda la firma en la base de datos.
 * menu.cfm: Página principal del menú.
 * pendientesFirmar.cfm: Página que lista las solicitudes pendientes de firma.
 * 
 * Autor: Rogelio Pérez Guevara
 * 
 * Fecha de creación: 29-09-2025
 * 
 * Versión: 1.0
--->

<!--- Consulta de Solicitud --->
<cfquery name="qSolicitud" datasource="autorizacion">
    SELECT s.*, 
        du.nombre, 
        du.apellido_paterno, 
        du.apellido_materno,
        aa.nombre AS area_nombre,
        f.svg AS firma_solicitante
    FROM solicitudes s
    LEFT JOIN datos_usuario du ON s.id_solicitante = du.id_datos
    LEFT JOIN area_adscripcion aa ON du.id_area = aa.id_area
    LEFT JOIN firmas f ON s.id_solicitud = f.id_solicitud AND f.rol='Solicitante'
    WHERE s.id_solicitud = <cfqueryparam value="#id_solicitud#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="qDatosFirmante" datasource="autorizacion">
    SELECT d.nombre, d.apellido_paterno, d.apellido_materno
    FROM usuarios u
    INNER JOIN datos_usuario d ON u.id_datos = d.id_datos
    WHERE u.id_usuario = <cfqueryparam value="#session.id_usuario#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset nombreCompletoFirmante = qDatosFirmante.nombre & " " & qDatosFirmante.apellido_paterno & " " & qDatosFirmante.apellido_materno>

<cfsavecontent variable="svgFirmaGenerada">
    <svg xmlns="http://www.w3.org/2000/svg" width="1000" height="200" viewBox="0 0 1000 200">
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Great+Vibes&display=swap');
            .texto-firma {
                font-family: 'Great Vibes', cursive; /* Fuente estilo firma */
                font-size: 70px;
                fill: #000000;
            }
        </style>
        <rect width="100%" height="100%" fill="white" opacity="0"/>
        <text x="50%" y="50%" 
          class="texto-firma" 
          dominant-baseline="middle" 
          text-anchor="middle">
            <cfoutput>#nombreCompletoFirmante#</cfoutput>
        </text>
    </svg>
</cfsavecontent>

<cfset svgFirmaGenerada = trim(svgFirmaGenerada)>

<!DOCTYPE html>
<html lang="es">
    <head>
        <!-- Metadatos y enlaces a estilos -->
        <meta charset="UTF-8">
        <!-- Vista adaptable para dispositivos móviles -->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!--- Icono de la pagina --->
        <link rel="icon" href="../elements/icono.ico" type="image/x-icon">
        <!-- Título de la página -->
        <title>Firmar Solicitud</title>
        <!-- Enlace a fuentes y hojas de estilo -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/svgFirma.css">
        <link rel="stylesheet" href="../css/firmarSolicitud.css">
        <link rel="stylesheet" href="../css/botones.css">
    </head>
    <body>
        <!--- Verificación de sesión y rol --->
        <cfif NOT (structKeyExists(session, "rol") AND len(trim(session.usuario)))>
            <!--- Redirigir a la página de login si no hay sesión activa --->
            <cflocation url="../login.cfm" addtoken="no">
        <!--- Verificar si el rol del usuario es Admin --->
        <cfelseif ListFindNoCase("Jefe,RecursosHumanos,Admin", session.rol) EQ 0>
            <!--- Redirigir a la página de menú si el rol no es Admin --->
            <cflocation url="../menu.cfm" addtoken="no">
        </cfif>

        <!--- Validar que se recibió el id_solicitud --->
        <cfif structKeyExists(form, "id_solicitud")>
            <cfset id_solicitud = form.id_solicitud>
        <cfelseif structKeyExists(url, "id_solicitud")>
            <cfset id_solicitud = url.id_solicitud>
        <cfelse>
            <cfoutput>
                <p style="color:red; text-align:center;">Error: No se recibió la solicitud correctamente.</p>
            </cfoutput>
            <cfabort>
        </cfif>

        <!--- Mostrar mensaje de error si no se firmó --->
        <cfif structKeyExists(url, "error") AND url.error eq 1>
            <div style="background-color:#ffdddd; color:#b30000; border:1px solid #ff6666; padding:10px; margin:10px 0; border-radius:5px; text-align:center; font-weight:bold;">
                ⚠️ Error al procesar la firma.
            </div>
        </cfif>

        <!--- Contenedor principal --->
        <div class="container">
            <!--- Encabezado --->
            <div class="header">
                <!--- Logo y rol del usuario --->
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "../componentes/usuarioConectadoSSoli").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <!--- Título de la página --->
                <h1>Solicitud <cfoutput>#qSolicitud.id_solicitud#</cfoutput></h1>
            </div>

            <!--- Formulario de firma --->
            <div class="form-container">
                <!--- Formulario para enviar la firma --->
                <form id="formFirma" method="post" action="guardarFirma.cfm">
                    <!--- Datos del Solicitante --->
                    <div class="section">
                        <!--- Título de la sección --->
                        <div class="section-title">
                            Datos del Solicitante
                        </div>

                        <!--- Campos de datos del solicitante --->
                        <div class="field-group">
                            <!--- Nombre Completo --->
                            <div class="form-field">
                                <label class="form-label">
                                    Nombre:
                                </label>

                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.nombre# #qSolicitud.apellido_paterno# #qSolicitud.apellido_materno#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>

                            <!--- Área de Adscripción --->
                            <div class="form-field">
                                <label class="form-label">
                                    Área de Adscripción:
                                </label>
                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.area_nombre#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>
                        </div>
                    </div>

                    <!--- Descripción de la Solicitud --->
                    <div class="section">
                        <!--- Título de la sección --->
                        <div class="section-title">
                            Descripción de la Solicitud
                        </div>

                        <!--- Campos de descripción de la solicitud --->
                        <div class="field-group">
                            <!--- Tipo de solicitud --->
                            <div class="form-field">
                                <label class="form-label">
                                    Tipo de solicitud:
                                </label>
                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.tipo_solicitud#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>

                            <!--- Tipo de Permiso --->
                            <div class="form-field">
                                <label class="form-label">
                                    Tipo de permiso:
                                </label>
                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.tipo_permiso#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>

                            <!--- Fecha, Tiempo Solicitado, Hora de Salida y Hora de Llegada --->
                            <div class="form-field">
                                <label class="form-label">
                                    Fecha:
                                </label>
                                <cfoutput>
                                    <input type="date"
                                        value="#DateFormat(qSolicitud.fecha,'yyyy-mm-dd')#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>

                            <!--- Tiempo Solicitado --->
                            <div class="form-field">
                                <label class="form-label">
                                    Tiempo Solicitado:
                                </label>
                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.tiempo_solicitado#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>

                            <!--- Hora de Salida --->
                            <div class="form-field">
                                <label class="form-label">
                                    Hora de Salida:
                                </label>
                                <cfoutput>
                                    <input type="time"
                                        value="#TimeFormat(qSolicitud.hora_salida,'HH:mm')#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>

                            <!--- Hora de Llegada --->
                            <div class="form-field">
                                <label class="form-label">
                                    Hora de Llegada:
                                </label>
                                <cfoutput>
                                    <input type="time"
                                        value="#TimeFormat(qSolicitud.hora_llegada,'HH:mm')#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>

                            
                        </div>

                        <!--- Mostrar alerta si existe --->
                        <cfif len(trim(qSolicitud.alert))>
                            <!---Mostrar alerta si existe--->
                            <div class="form-field">
                                <label class="form-label">
                                    Alerta:
                                </label>
                                <input type="text" 
                                    value="<cfoutput>#qSolicitud.alert#</cfoutput>"
                                    class="form-input-general forml-input-alert"
                                    readonly>
                            </div>
                        </cfif>
                    </div>

                    <!--- Firmas --->
                    <div class="section">
                        <!--- Título de la sección --->
                        <div class="section-title">Firmas de Autorización</div>

                        <!--- Firma del Solicitante --->
                        <div class="signature-field">
                            <div class="signature-label">
                                Solicitante
                            </div>
                            <cfoutput>
                                <div id="firma-solicitante-display">
                                    <svg viewBox="0 0 1000 200" preserveAspectRatio="none" width="100%" height="100%">
                                        #qSolicitud.firma_solicitante#
                                    <svg>
                                </div>
                            </cfoutput>
                        </div>

                        <!--- Firma del Superior --->
                        <div class="signature-field">
                            <!--- Título de la firma --->
                            <cfoutput>
                                <div class="signature-label">
                                    Tu Firma (#session.rol#)
                                </div>
                            </cfoutput>

                            
                            <div id="signature-wrapper-superior" class="signature-wrapper">
                                <cfoutput>
                                    #svgFirmaGenerada#
                                </cfoutput>
                            </div>

                            
                            <cfoutput>
                                <input type="hidden" name="firma_superior_svg" id="firma_superior_svg" value="#encodeForHTMLAttribute(svgFirmaGenerada)#">
                            </cfoutput>
                        </div>

                        <!--- Campos ocultos --->
                        <cfoutput>
                            <input type="hidden" name="id_solicitud" value="#id_solicitud#">
                            <input type="hidden" name="rol" value="#session.rol#">
                        </cfoutput>
                    </div>

                    <!--- Botones de acción --->
                    <div class="submit-section">
                        <cfif session.rol eq "jefe">
                            <!--- Botones Aceptar y Rechazar --->
                            <div class="field-group">
                                <!--- Botón Aceptar --->
                                <button type="submit" name="submit" value="Aprobado" class="submit-btn-aceptar">
                                    Aceptar
                                </button>

                                <!--- Botón Rechazar --->
                                <button type="submit" name="submit" value="Rechazado" class="submit-btn-rechazar">
                                    Rechazar
                                </button>
                            </div>
                        <cfelse>
                            <!--- Mostrar solo el botón de Aceptar para otros roles --->
                            <button type="submit" name="submit" value="Aprobado" class="submit-btn-aceptar single-btn">
                                Enterado
                            </button>
                        </cfif>
                    </div>                
                </form>
                
                <!--- Botones de navegación --->
                <div class="submit-section">
                    <!--- Botones Regresar, Menú y Cerrar Sesión --->
                    <div class="field-group triple">
                        <!--- Botón Regresar --->
                        <a class="submit-btn-regresar submit-btn-regresar-text" id="btnRegresar">
                            Regresar
                        </a>

                        <!--- Botón Menú --->
                        <a href="../menu.cfm" class="submit-btn-menu submit-btn-menu-text" id="submit-btn-menu">
                            Menú
                        </a>
                        
                        <!--- Botón Cerrar Sesión --->
                        <a href="../cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesión
                        </a>
                    </div>
                </div>
            </div>
        </div>

        
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                // Ya no necesitamos inicializar la firma superior porque es estática.
                // Si hubiera otras firmas trazables, dejaríamos su initSignature aquí.
            });
        </script>

        <!--- Script para el botón de menú --->
        <script>
            <!--- Manejar el clic en el botón de menú --->
            document.getElementById("submit-btn-menu").addEventListener("click", function(e) {
                // Eliminamos la lógica del botón 'limpiar' ya que no existe
                e.preventDefault(); <!--- Prevenir la acción por defecto del enlace --->
                window.location.href = "../menu.cfm";
            });
        </script>

        <!--- Script para el botón de regresar --->
        <script>
            <!--- Manejar el clic en el botón de regresar --->
            document.getElementById("btnRegresar").addEventListener("click", function() {
                <!--- Redirige siempre a pendientesFirmar.cfm sin importar si hay error o no --->
                window.location.href = "pendientesFirmar.cfm";
            });
        </script>
    </body>
</html>
