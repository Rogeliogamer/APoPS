<!---
 * Página `firmarSolicitud.cfm` para la firma de solicitudes por parte del usuario.
 *
 * Funcionalidad:
 * - Permite al usuario autenticado firmar las solicitudes que le corresponden según su rol.
 * - El usuario puede **aceptar** o **rechazar** cada solicitud.
 *
 * Uso:
 * - Página destinada al proceso de validación y firma de solicitudes por las autoridades correspondientes.
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

<!DOCTYPE html>
<html lang="es">
    <head>
        <!-- Metadatos y enlaces a estilos -->
        <meta charset="UTF-8">
        <!-- Vista adaptable para dispositivos móviles -->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!--- Icono de la pagina --->
        <link rel="icon" href="elements/icono.ico" type="image/x-icon">
        <!-- Título de la página -->
        <title>Firmar Solicitud</title>
        <!-- Enlace a fuentes y hojas de estilo -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/svgFirma.css">
        <link rel="stylesheet" href="css/firmarSolicitud.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
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
                ⚠️ Debes firmar antes de enviar la solicitud.
            </div>
        </cfif>

        <!--- Contenedor principal --->
        <div class="container">
            <!--- Encabezado --->
            <div class="header">
                <!--- Logo y rol del usuario --->
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
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
                            <!--- Motivo --->
                            <div class="form-field">
                                <label class="form-label">
                                    Motivo:
                                </label>
                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.motivo#"
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

                            <!--- Área de firma SVG --->
                            <div id="signature-wrapper-superior" class="signature-wrapper" role="application" aria-label="Área de firma">
                                <!--- SVG para la firma --->
                                <svg id="signature-svg-superior" class="signature-svg"
                                    xmlns="http://www.w3.org/2000/svg"
                                    width="100%" height="100%"
                                    viewBox="0 0 1000 200"
                                    preserveAspectRatio="none"></svg>
                            </div>

                            <!--- Controles de la firma --->
                            <div class="signature-controls">
                                <!--- Botón para limpiar la firma --->
                                <button id="clearBtn-superior" type="button" class="submit-btn-limpiar">
                                    Limpiar
                                </button>
                            </div>
                            <input type="hidden" name="firma_superior_svg" id="firma_superior_svg">
                        </div>

                        <!--- Campos ocultos --->
                        <cfoutput>
                            <input type="hidden" name="id_solicitud" value="#id_solicitud#">
                            <input type="hidden" name="rol" value="#session.rol#">
                        </cfoutput>
                    </div>

                    <!--- Botones de acción --->
                    <div class="submit-section">
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
                        <a href="menu.cfm" class="submit-btn-menu submit-btn-menu-text" id="submit-btn-menu">
                            Menú
                        </a>
                        
                        <!--- Botón Cerrar Sesión --->
                        <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!--- Scripts para la funcionalidad de la firma y navegación --->
        <script>
            <!--- JS de firma --->
            document.addEventListener('DOMContentLoaded', function () {
                <!--- Función para inicializar la firma --->
                function initSignature(wrapperId, svgId, hiddenInputId, clearBtnId) {
                    <!--- Elementos del DOM --->
                    const wrapper = document.getElementById(wrapperId);
                    const svg = document.getElementById(svgId);
                    const hiddenInput = document.getElementById(hiddenInputId);
                    const clearBtn = document.getElementById(clearBtnId);

                    <!--- Configuración inicial del SVG --->
                    const SVG_W = 1000, SVG_H = 200;
                    svg.setAttribute('viewBox', `0 0 ${SVG_W} ${SVG_H}`);

                    <!--- Variables para el dibujo --->
                    let drawing = false;
                    <!--- Puntos actuales del trazo --->
                    let currentPoints = [];

                    <!--- Almacenar los trazos de la firma --->
                    const strokes = [];

                    <!--- Funciones para manejar el dibujo --->
                    function getSvgPoint(evt) {
                        <!--- Obtener la posición del puntero en coordenadas SVG --->
                        const rect = wrapper.getBoundingClientRect();
                        const clientX = (evt.clientX === undefined) ? (evt.touches && evt.touches[0].clientX) : evt.clientX;
                        const clientY = (evt.clientY === undefined) ? (evt.touches && evt.touches[0].clientY) : evt.clientY;
                        const x = ((clientX - rect.left) / rect.width) * SVG_W;
                        const y = ((clientY - rect.top) / rect.height) * SVG_H;
                        return { x: Math.max(0, Math.min(SVG_W, x)), y: Math.max(0, Math.min(SVG_H, y)) };
                    }

                    <!--- Actualizar el elemento de ruta SVG con los puntos actuales --->
                    function updatePathElement(pathElem, pts) {
                        <!--- Construir el atributo 'd' del path SVG --->
                        if(pts.length === 0) return;
                        let d = `M ${pts[0].x.toFixed(2)} ${pts[0].y.toFixed(2)}`;
                        <!--- Agregar líneas a los puntos siguientes --->
                        for(let i=1;i<pts.length;i++) d += ` L ${pts[i].x.toFixed(2)} ${pts[i].y.toFixed(2)}`;
                        <!--- Establecer el atributo 'd' en el elemento path --->
                        pathElem.setAttribute('d', d);
                    }

                    <!--- Manejo de eventos de puntero --->
                    function startStroke(evt) {
                        <!--- Iniciar el trazo --->
                        evt.preventDefault();
                        <!--- Marcar que se está dibujando --->
                        drawing = true;
                        <!--- Inicializar los puntos actuales --->
                        currentPoints = [];
                        <!--- Obtener el punto inicial --->
                        const p = getSvgPoint(evt);
                        <!--- Agregar el punto inicial a los puntos actuales --->
                        currentPoints.push(p);
                        <!--- Crear un nuevo elemento path para el trazo --->
                        const path = document.createElementNS('http://www.w3.org/2000/svg','path');
                        <!--- Configurar atributos del path --->
                        path.setAttribute('fill','none');
                        path.setAttribute('stroke-width','3');
                        path.setAttribute('stroke-linecap','round');
                        path.setAttribute('stroke-linejoin','round');
                        path.setAttribute('stroke','black');
                        path.dataset.temp = '1';
                        <!--- Agregar el path al SVG --->
                        svg.appendChild(path);
                        <!--- Actualizar el path con el punto inicial --->
                        updatePathElement(path, currentPoints);
                    }

                    <!--- Manejar el movimiento del puntero --->
                    function moveStroke(evt) {
                        <!--- Agregar puntos al trazo mientras se dibuja --->
                        if(!drawing) return;
                        <!--- Obtener el punto actual --->
                        const p = getSvgPoint(evt);
                        <!--- Obtener el último punto agregado --->
                        const last = currentPoints[currentPoints.length-1] || {x:0,y:0};
                        <!--- Evitar agregar puntos muy cercanos --->
                        if(Math.hypot(p.x-last.x, p.y-last.y) < 1) return;
                        <!--- Agregar el nuevo punto a los puntos actuales --->
                        currentPoints.push(p);
                        <!--- Actualizar el path con los nuevos puntos --->
                        const path = svg.querySelector('path[data-temp="1"]');
                        <!--- Actualizar el path con los puntos actuales --->
                        if(path) updatePathElement(path, currentPoints);
                    }

                    <!--- Manejar el fin del trazo --->
                    function endStroke(evt) {
                        <!--- Finalizar el trazo --->
                        if(!drawing) return;
                        <!--- Marcar que ya no se está dibujando --->
                        drawing = false;
                        <!--- Obtener el path actual --->
                        const path = svg.querySelector('path[data-temp="1"]');
                        <!--- Actualizar el path con los puntos finales --->
                        if(path){
                            <!--- Quitar el atributo temporal --->
                            path.removeAttribute('data-temp');
                            <!--- Guardar el trazo en el array de trazos --->
                            strokes.push(path.getAttribute('d'));
                        }
                        <!--- Limpiar los puntos actuales --->
                        currentPoints = [];
                    }

                    <!--- Exportar la firma como SVG --->
                    function exportSVG() {
                        <!--- Construir el SVG completo a partir de los trazos --->
                        if(strokes.length === 0) return '';
                        <!--- Construir el SVG completo a partir de los trazos --->
                        const header = `<svg xmlns="http://www.w3.org/2000/svg" width="${SVG_W}" height="${SVG_H}" viewBox="0 0 ${SVG_W} ${SVG_H}">`;
                        const paths = strokes.map(d => `<path d="${d}" fill="none" stroke="black" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>`).join('');
                        <!--- Retornar el SVG completo --->
                        return header + paths + `</svg>`;
                    }

                    <!--- Limpiar la firma --->
                    function clearSignature() {
                        <!--- Limpiar los trazos y el SVG --->
                        strokes.length = 0;
                        <!--- Limpiar los elementos SVG --->
                        while (svg.firstChild) svg.removeChild(svg.firstChild);
                        <!--- Restablecer el valor del input oculto --->
                        hiddenInput.value = '';
                    }

                    <!--- Eventos de puntero para el área de firma --->
                    wrapper.addEventListener('pointerdown', startStroke);
                    wrapper.addEventListener('pointermove', moveStroke);
                    wrapper.addEventListener('pointerup', endStroke);
                    wrapper.addEventListener('pointercancel', endStroke);
                    wrapper.addEventListener('pointerleave', endStroke);

                    <!--- Evento para el botón de limpiar firma --->
                    clearBtn.addEventListener('click', clearSignature);

                    <!--- Evento para el envío del formulario --->
                    const form = document.getElementById('formFirma');
                    <!--- Al enviar el formulario, guardar el SVG generado en el input oculto --->
                    form.addEventListener('submit', function(e){
                        <!--- Guardar el SVG exportado en el input oculto --->
                        hiddenInput.value = exportSVG();
                    });
                }

                <!--- Inicializar la firma para el superior --->
                initSignature('signature-wrapper-superior', 'signature-svg-superior', 'firma_superior_svg', 'clearBtn-superior');
            });
        </script>

        <!--- Script para el botón de menú --->
        <script>
            <!--- Manejar el clic en el botón de menú --->
            document.getElementById("submit-btn-menu").addEventListener("click", function() {
                <!--- 1. Activar la otra acción --->
                document.getElementById("clearBtn-superior").click(); <!--- simula que se hizo click en btnActivar --->

                <!--- 2. Esperar un momento si quieres que se vea el efecto --->
                setTimeout(function() {
                    <!--- 3. Redirigir a otra página --->
                    window.location.href = "menu.cfm";
                }, 150); <!--- 150 ms de retraso para que se note la acción --->
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
