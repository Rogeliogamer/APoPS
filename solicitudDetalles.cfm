<!---
 * Página `solicitudDetalles.cfm` para la visualización detallada de una solicitud.
 *
 * Funcionalidad:
 * - Muestra toda la información de un formulario específico del usuario autenticado.
 * - Incluye información básica, estado final de la solicitud y el estado de las cinco firmas correspondientes.
 * - Cada firma puede tener estado: **Aprobado**, **Rechazado** o **Pendiente**.
 *
 * Uso:
 * - Página destinada a revisar el detalle completo y el historial de firmas de una solicitud.
--->
<cfparam name="form.id_solicitud" default="0">

<cfquery name="qSolicitud" datasource="autorizacion">
    SELECT 
        s.id_solicitud,
        CONCAT(d.nombre, ' ', d.apellido_paterno, ' ', d.apellido_materno) AS solicitante,
        s.tipo_solicitud,
        s.motivo,
        s.tipo_permiso,
        s.fecha,
        s.tiempo_solicitado,
        s.hora_salida,
        s.hora_llegada,
        s.status_final
    FROM solicitudes s
    INNER JOIN usuarios u ON s.id_solicitante = u.id_usuario
    INNER JOIN datos_usuario d ON u.id_datos = d.id_datos
    WHERE s.id_solicitud = <cfqueryparam value="#form.id_solicitud#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="qFirmas" datasource="autorizacion">
    SELECT rol, 
        aprobado, 
        fecha_firma, 
        svg
    FROM firmas
    WHERE id_solicitud = <cfqueryparam value="#form.id_solicitud#" cfsqltype="cf_sql_integer">
    ORDER BY FIELD(rol, 'Solicitante','Jefe','RecursosHumanos','Autorizacion','Expediente')
</cfquery>

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
        <title>Detalle de Solicitud</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/solicitudDetalles.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <h1>Solicitud <cfoutput>#qSolicitud.id_solicitud#</cfoutput></h1>
            </div>

            <div class="form-container">
                <div class="section">
                    <div class="section-title">
                        Información de la Solicitud
                    </div>

                    <div class="field-group">
                        <cfoutput>
                            <div class="form-field">
                                <label class="form-label">Solicitante</label>
                                <input type="text" class="form-input-general" value="#qSolicitud.solicitante#" readonly>
                            </div>

                            <div class="form-field">
                                <label class="form-label">Tipo de Solicitud</label>
                                <input type="text" class="form-input-general" value="#qSolicitud.tipo_solicitud#" readonly>
                            </div>

                            <div class="form-field">
                                <label class="form-label">Motivo</label>
                                <input type="text" class="form-input-general" value="#qSolicitud.motivo#" readonly>
                            </div>

                            <div class="form-field">
                                <label class="form-label">Tipo de Permiso</label>
                                <input type="text" class="form-input-general" value="#qSolicitud.tipo_permiso#" readonly>
                            </div>

                            <div class="form-field">
                                <label class="form-label">Fecha</label>
                                <input type="text" class="form-input-general" value="#DateFormat(qSolicitud.fecha,'dd/mm/yyyy')#" readonly>
                            </div>

                            <div class="form-field">
                                <label class="form-label">Hora de Salida</label>
                                <input type="text" class="form-input-general" value="#TimeFormat(qSolicitud.hora_salida,'HH:mm')#" readonly>
                            </div>

                            <div class="form-field">
                                <label class="form-label">Hora de Llegada</label>
                                <input type="text" class="form-input-general" value="#TimeFormat(qSolicitud.hora_llegada,'HH:mm')#" readonly>
                            </div>

                            <div class="form-field">
                                <label class="form-label">Tiempo Solicitado</label>
                                <input type="text" class="form-input-general" value="#qSolicitud.tiempo_solicitado#" readonly>
                            </div>

                            <div class="form-field">
                                <label class="form-label">Status Final</label>
                                <cfif #qSolicitud.status_final# EQ "Aprobado">
                                    <input type="text" class="form-input-aprovado" value="#qSolicitud.status_final#" readonly>
                                <cfelseif #qSolicitud.status_final# EQ "Rechazado">
                                    <input type="text" class="form-input-rechazado" value="#qSolicitud.status_final#" readonly>
                                <cfelse>
                                    <input type="text" class="form-input-pendiente" value="#qSolicitud.status_final#" readonly>
                                </cfif>
                            </div>
                        </cfoutput>
                    </div>
                </div>

                <div class="section">
                    <div class="section-title">
                        Firmas
                    </div>

                    <div class="signature-section">
                        <cfoutput query="qFirmas">
                            <div class="signature-field">
                                <div class="signature-label">
                                    #rol#
                                </div>

                                <!--- SVG de la firma --->
                                <div class="signature-svg">
                                    #svg#
                                </div>

                                <div class="signature-line">
                                </div>

                                <div>
                                    #aprobado#
                                </div>

                                <div>
                                    #DateFormat(fecha_firma,'dd/mm/yyyy')# #TimeFormat(fecha_firma,'HH:mm')#
                                </div>
                            </div>
                        </cfoutput>
                    </div>
                </div>

                <div class="submit-section">
                    <div class="field-group triple">
                        <a class="submit-btn-regresar submit-btn-regresar-text" id="btnRegresar">
                            Regresar
                        </a>
                        
                        <a href="menu.cfm" class="submit-btn-menu submit-btn-regresar-text">
                            Menu
                        </a>

                        <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <script>
            <!--- Capturamos el botón --->
            const btnRegresar = document.getElementById('btnRegresar');

            btnRegresar.addEventListener('click', function() {
                if (document.referrer) {
                    <!--- Va a la página desde donde llegó --->
                    window.location.href = document.referrer;
                } else {
                    <!--- Si no hay referrer, va a una página por defecto --->
                    window.location.href = 'firmados.cfm';
                }
            });
        </script>
    </body>
</html>
