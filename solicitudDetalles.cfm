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

<!--- Verificación de sesión y rol autorizado --->
<cfparam name="form.id_solicitud" default="0">
<cfparam name="url.generarPDF" default="false">

<!--- Obtener los datos de la solicitud --->
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

<!--- Obtener las firmas asociadas a la solicitud --->
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
        <style>
            button {
                display: block;
                width: 100%;
                padding: 12px 0;
                font-size: 16px;
                font-weight: bold;
                color: white;
                border: none;
                border-radius: 10px;
                cursor: pointer;
                background: inherit; /* mantiene el color o degradado original del contenedor */
                box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
        </style>
    </head>
    <body>
        <!--- Verificación de sesión y rol autorizado --->
        <cfif NOT structKeyExists(session, "rol") OR len(trim(session.rol)) EQ 0>
            <!--- No hay sesión activa o rol definido --->
            <cflocation url="login.cfm" addtoken="no">
        <cfelseif ListFindNoCase("Solicitante,Jefe,RecursosHumanos,Autorizacion,Expediente", trim(session.rol)) EQ 0>
            <!--- Rol no autorizado para esta sección --->
            <cflocation url="menu.cfm" addtoken="no">
        </cfif>

        <!--- Contenedor principal --->
        <div class="container">
            <!--- Encabezado con logo y título --->
            <div class="header">
                <!--- Logo y título de la página --->
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <!--- Título de la página --->
                <h1>Solicitud <cfoutput>#qSolicitud.id_solicitud#</cfoutput></h1>
            </div>

            <!--- Contenedor del formulario --->
            <div class="form-container">
                <!--- Sección de información de la solicitud --->
                <div class="section">
                    <!--- Título de la sección --->
                    <div class="section-title">
                        Información de la Solicitud
                    </div>

                    <!--- Grupo de campos de la solicitud --->
                    <div class="field-group">
                        <!--- Campos de solo lectura con la información de la solicitud --->
                        <cfoutput>
                            <!--- Campo: Solicitante --->
                            <div class="form-field">
                                <label class="form-label">Solicitante</label>
                                <input type="text" class="form-input-general" value="#qSolicitud.solicitante#" readonly>
                            </div>

                            <!--- Campo: Tipo de Solicitud --->
                            <div class="form-field">
                                <label class="form-label">Tipo de Solicitud</label>
                                <input type="text" class="form-input-general" value="#qSolicitud.tipo_solicitud#" readonly>
                            </div> 

                            <!--- Campo: Motivo --->
                            <div class="form-field">
                                <label class="form-label">Motivo</label>
                                <input type="text" class="form-input-general" value="#qSolicitud.motivo#" readonly>
                            </div>

                            <!--- Campo: Tipo de Permiso --->
                            <div class="form-field">
                                <label class="form-label">Tipo de Permiso</label>
                                <input type="text" class="form-input-general" value="#qSolicitud.tipo_permiso#" readonly>
                            </div>

                            <!--- Campo: Fecha --->
                            <div class="form-field">
                                <label class="form-label">Fecha</label>
                                <input type="text" class="form-input-general" value="#DateFormat(qSolicitud.fecha,'dd/mm/yyyy')#" readonly>
                            </div>

                            <!--- Campo: Hora de Salida --->
                            <div class="form-field">
                                <label class="form-label">Hora de Salida</label>
                                <input type="text" class="form-input-general" value="#TimeFormat(qSolicitud.hora_salida,'HH:mm')#" readonly>
                            </div>

                            <!--- Campo: Hora de Llegada --->
                            <div class="form-field">
                                <label class="form-label">Hora de Llegada</label>
                                <input type="text" class="form-input-general" value="#TimeFormat(qSolicitud.hora_llegada,'HH:mm')#" readonly>
                            </div>

                            <!--- Campo: Tiempo Solicitado --->
                            <div class="form-field">
                                <label class="form-label">Tiempo Solicitado</label>
                                <input type="text" class="form-input-general" value="#qSolicitud.tiempo_solicitado#" readonly>
                            </div>

                            <!--- Campo: Status Final --->
                            <div class="form-field">
                                <!--- Etiqueta y campo con estilo condicional según el estado --->
                                <label class="form-label">Status Final</label>
                                <!--- Campo con clase CSS según el valor de status_final --->
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

                <!--- Sección de firmas --->
                <div class="section">
                    <!--- Título de la sección --->
                    <div class="section-title">
                        Firmas
                    </div>

                    <!--- Contenedor de las firmas --->
                    <div class="signature-section">
                        <!--- Recorrer las firmas obtenidas de la base de datos --->
                        <cfoutput query="qFirmas">
                            <!--- Contenedor de cada firma --->
                            <div class="signature-field">
                                <!--- Etiqueta del rol de la firma --->
                                <div class="signature-label">
                                    #rol#
                                </div>

                                <!--- SVG de la firma --->
                                <div class="signature-svg">
                                    #svg#
                                </div>

                                <!--- Línea decorativa --->
                                <div class="signature-line">
                                </div>

                                <!--- Estado de la firma --->
                                <div>
                                    #aprobado#
                                </div>

                                <!--- Fecha de la firma --->
                                <div>
                                    #DateFormat(fecha_firma,'dd/mm/yyyy')# #TimeFormat(fecha_firma,'HH:mm')#
                                </div>
                            </div>
                        </cfoutput>
                    </div>
                </div>

                <!--- Sección de botones --->
                <div class="submit-section">
                    <!--- Grupo de botones --->
                    <div class="field-group">
                        <!--- Botón para regresar a la página anterior --->
                        <a class="submit-btn-regresar submit-btn-regresar-text" id="btnRegresar">
                            Regresar
                        </a>
                        
                        <!--- Botón para ir al menú principal --->
                        <a href="menu.cfm" class="submit-btn-menu submit-btn-regresar-text">
                            Menu
                        </a>
                    </div>

                    <div class="field-group">
                        <!-- Usa JavaScript para abrir el generador en una nueva ventana -->
                        <form id="formGenerarPDF" action="generarPDF.cfm" method="post" target="_blank" style="display:inline; width:100%; display:flex; flex-direction:column; align-items:center;">
                            <input type="hidden" name="id_solicitud" value="<cfoutput>#form.id_solicitud#</cfoutput>">
                            <button type="submit" class="submit-btn-pdf submit-btn-pdf-text">Generar PDF</button>
                        </form>

                        <!--- Botón para cerrar sesión --->
                        <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!--- Script para manejar la navegación del botón Regresar --->
        <script>
            <!--- Capturamos el botón --->
            const btnRegresar = document.getElementById('btnRegresar');

            <!--- Agregamos el evento click --->
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

        <script>
            <!--- Función para generar el PDF en una nueva pestaña --->
            function generarPDF(idSolicitud) {
                <!--- Abre el script generadorPDF_backend.cfm en una nueva pestaña/ventana --->
                <!--- Esto le permite al navegador manejar la descarga sin recargar la página actual --->
                window.open('generarPDF.cfm?id_solicitud=' + idSolicitud, '_blank');
            }
        </script>
    </body>
</html>
