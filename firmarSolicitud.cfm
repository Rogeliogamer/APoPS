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

<!-- Consulta de Solicitud -->
<cfquery name="qSolicitud" datasource="autorizacion">
    SELECT s.*, du.nombre, du.apellido_paterno, du.apellido_materno,
        aa.nombre AS area_nombre,
        f.svg AS firma_solicitante
    FROM solicitudes s
    LEFT JOIN datos_usuario du ON s.id_solicitante = du.id_datos
    LEFT JOIN area_adscripcion aa ON du.id_area = aa.id_area
    LEFT JOIN firmas f ON s.id_solicitud = f.id_solicitud AND f.rol='Solicitante'
    WHERE s.id_solicitud = <cfqueryparam value="#url.id_solicitud#" cfsqltype="cf_sql_integer">
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
        <div class="container">
            <div class="header">
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <h1>Solicitud <cfoutput>#qSolicitud.id_solicitud#</cfoutput></h1>
            </div>

            <div class="form-container">
                <form id="formFirma" method="post" action="guardar_firma.cfm">

                    

                    <!-- Datos del Solicitante -->
                    <div class="section">
                        <div class="section-title">Datos del Solicitante</div>
                        <div class="field-group">
                            <div class="form-field">
                                <label class="form-label">Nombre:</label>
                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.nombre# #qSolicitud.apellido_paterno# #qSolicitud.apellido_materno#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>
                            <div class="form-field">
                                <label class="form-label">Área de Adscripción:</label>
                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.area_nombre#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>
                        </div>
                    </div>

                    <!-- Descripción de la Solicitud -->
                    <div class="section">
                        <div class="section-title">Descripción de la Solicitud</div>
                        <div class="field-group">
                            <div class="form-field">
                                <label class="form-label">Motivo:</label>
                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.motivo#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>
                            <div class="form-field">
                                <label class="form-label">Tipo de permiso:</label>
                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.tipo_permiso#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>
                            <div class="form-field">
                                <label class="form-label">Fecha:</label>
                                <cfoutput>
                                    <input type="date"
                                        value="#DateFormat(qSolicitud.fecha,'yyyy-mm-dd')#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>
                            <div class="form-field">
                                <label class="form-label">Tiempo Solicitado:</label>
                                <cfoutput>
                                    <input type="text"
                                        value="#qSolicitud.tiempo_solicitado#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>
                            <div class="form-field">
                                <label class="form-label">Hora de Salida:</label>
                                <cfoutput>
                                    <input type="time"
                                        value="#TimeFormat(qSolicitud.hora_salida,'HH:mm')#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>
                            <div class="form-field">
                                <label class="form-label">Hora de Llegada:</label>
                                <cfoutput>
                                    <input type="time"
                                        value="#TimeFormat(qSolicitud.hora_llegada,'HH:mm')#"
                                        class="form-input-general"
                                        readonly>
                                </cfoutput>
                            </div>
                        </div>
                    </div>

                    <!-- Firmas -->
                    <div class="section">
                        <div class="section-title">Firmas de Autorización</div>

                        <!-- Firma del Solicitante -->
                        <div class="signature-field">
                            <div class="signature-label">Solicitante</div>
                            <cfoutput>
                                <div id="firma-solicitante-display">
                                    <svg viewBox="0 0 1000 200" preserveAspectRatio="none" width="100%" height="100%">
                                        #qSolicitud.firma_solicitante#
                                    <svg>
                                </div>
                            </cfoutput>
                        </div>

                        <!-- Firma del Superior -->
                        <div class="signature-field">
                            <cfoutput>
                                <div class="signature-label">Tu Firma (#session.rol#)</div>
                            </cfoutput>
                            <div id="signature-wrapper-superior" class="signature-wrapper" role="application" aria-label="Área de firma">
                                <svg id="signature-svg-superior" class="signature-svg"
                                    xmlns="http://www.w3.org/2000/svg"
                                    width="100%" height="100%"
                                    viewBox="0 0 1000 200"
                                    preserveAspectRatio="none"></svg>
                            </div>
                            <div class="signature-controls">
                                <button id="clearBtn-superior" type="button" class="submit-btn-limpiar">Limpiar</button>
                            </div>
                            <input type="hidden" name="firma_superior_svg" id="firma_superior_svg">
                        </div>

                        <!-- Campos ocultos -->
                        <cfoutput>
                            <input type="hidden" name="id_solicitud" value="#url.id_solicitud#">
                            <input type="hidden" name="rol" value="#session.rol#">
                        </cfoutput>
                    </div>    
                    <!-- Botones de acción -->
                    <div class="submit-section">
                        <div class="field-group">
                            <button type="submit" name="submit" value="Aprobado" class="submit-btn-aceptar">Aceptar</button>
                            <button type="submit" name="submit" value="Rechazado" class="submit-btn-rechazar">Rechazar</button>
                        </div>
                    </div>                
                </form>
                
                <div class="submit-section">
                    <div class="field-group triple">
                        <a class="submit-btn-regresar submit-btn-regresar-text" id="btnRegresar">
                            Regresar
                        </a>

                        <a href="menu.cfm" class="submit-btn-menu submit-btn-menu-text" id="submit-btn-menu">
                            Menú
                        </a>
                    
                        <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- JS de firma -->
        <script>
        document.addEventListener('DOMContentLoaded', function () {
            function initSignature(wrapperId, svgId, hiddenInputId, clearBtnId){
                const wrapper = document.getElementById(wrapperId);
                const svg = document.getElementById(svgId);
                const hiddenInput = document.getElementById(hiddenInputId);
                const clearBtn = document.getElementById(clearBtnId);

                const SVG_W = 1000, SVG_H = 200;
                svg.setAttribute('viewBox', `0 0 ${SVG_W} ${SVG_H}`);

                let drawing = false;
                let currentPoints = [];
                const strokes = [];

                function getSvgPoint(evt){
                    const rect = wrapper.getBoundingClientRect();
                    const clientX = (evt.clientX === undefined) ? (evt.touches && evt.touches[0].clientX) : evt.clientX;
                    const clientY = (evt.clientY === undefined) ? (evt.touches && evt.touches[0].clientY) : evt.clientY;
                    const x = ((clientX - rect.left) / rect.width) * SVG_W;
                    const y = ((clientY - rect.top) / rect.height) * SVG_H;
                    return { x: Math.max(0, Math.min(SVG_W, x)), y: Math.max(0, Math.min(SVG_H, y)) };
                }

                function updatePathElement(pathElem, pts){
                    if(pts.length === 0) return;
                    let d = `M ${pts[0].x.toFixed(2)} ${pts[0].y.toFixed(2)}`;
                    for(let i=1;i<pts.length;i++) d += ` L ${pts[i].x.toFixed(2)} ${pts[i].y.toFixed(2)}`;
                    pathElem.setAttribute('d', d);
                }

                function startStroke(evt){
                    evt.preventDefault();
                    drawing = true;
                    currentPoints = [];
                    const p = getSvgPoint(evt);
                    currentPoints.push(p);
                    const path = document.createElementNS('http://www.w3.org/2000/svg','path');
                    path.setAttribute('fill','none');
                    path.setAttribute('stroke-width','3');
                    path.setAttribute('stroke-linecap','round');
                    path.setAttribute('stroke-linejoin','round');
                    path.setAttribute('stroke','black');
                    path.dataset.temp = '1';
                    svg.appendChild(path);
                    updatePathElement(path, currentPoints);
                }

                function moveStroke(evt){
                    if(!drawing) return;
                    const p = getSvgPoint(evt);
                    const last = currentPoints[currentPoints.length-1] || {x:0,y:0};
                    if(Math.hypot(p.x-last.x, p.y-last.y) < 1) return;
                    currentPoints.push(p);
                    const path = svg.querySelector('path[data-temp="1"]');
                    if(path) updatePathElement(path, currentPoints);
                }

                function endStroke(evt){
                    if(!drawing) return;
                    drawing = false;
                    const path = svg.querySelector('path[data-temp="1"]');
                    if(path){
                        path.removeAttribute('data-temp');
                        strokes.push(path.getAttribute('d'));
                    }
                    currentPoints = [];
                }

                function exportSVG(){
                    if(strokes.length === 0) return '';
                    const header = `<svg xmlns="http://www.w3.org/2000/svg" width="${SVG_W}" height="${SVG_H}" viewBox="0 0 ${SVG_W} ${SVG_H}">`;
                    const paths = strokes.map(d => `<path d="${d}" fill="none" stroke="black" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>`).join('');
                    return header + paths + `</svg>`;
                }

                function clearSignature(){
                    strokes.length = 0;
                    while (svg.firstChild) svg.removeChild(svg.firstChild);
                    hiddenInput.value = '';
                }

                wrapper.addEventListener('pointerdown', startStroke);
                wrapper.addEventListener('pointermove', moveStroke);
                wrapper.addEventListener('pointerup', endStroke);
                wrapper.addEventListener('pointercancel', endStroke);
                wrapper.addEventListener('pointerleave', endStroke);

                clearBtn.addEventListener('click', clearSignature);

                const form = document.getElementById('formFirma');
                form.addEventListener('submit', function(e){
                    hiddenInput.value = exportSVG();
                });
            }

            initSignature('signature-wrapper-superior', 'signature-svg-superior', 'firma_superior_svg', 'clearBtn-superior');
        });
        </script>

        <script>
            document.getElementById("submit-btn-menu").addEventListener("click", function() {
                // 1. Activar la otra acción
                document.getElementById("clearBtn-superior").click(); // simula que se hizo click en btnActivar

                // 2. Esperar un momento si quieres que se vea el efecto
                setTimeout(function() {
                    // 3. Redirigir a otra página
                    window.location.href = "menu.cfm";
                }, 150); // 150 ms de retraso para que se note la acción
            });
        </script>

        <script>
            // Capturamos el botón
            const btnRegresar = document.getElementById('btnRegresar');

            btnRegresar.addEventListener('click', function() {
                if (document.referrer) {
                    // Va a la página desde donde llegó
                    window.location.href = document.referrer;
                } else {
                    // Si no hay referrer, va a una página por defecto
                    window.location.href = 'firmados.cfm';
                }
            });
        </script>
    </body>
</html>
