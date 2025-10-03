<!DOCTYPE html>
<html lang="es">
<head>
    <!-- Metadatos y enlaces a estilos -->
    <meta charset="UTF-8">
    <!-- Vista adaptable para dispositivos móviles -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Título de la página -->
    <title>Firmar Solicitud</title>
    <!-- Enlace a fuentes y hojas de estilo -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/globalForm.css">
    <link rel="stylesheet" href="css/svgFirmaRol.css">
    <link rel="stylesheet" href="css/firmarSolicitud.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">
                <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                <cfoutput>#usuarioRol#</cfoutput>
            </div>
            <h1>AUTORIZACIÓN DE PERMISO O PASE DE SALIDA</h1>
        </div>

        <div class="form-container">
            <form id="formFirma" method="post" action="guardar_firma.cfm">

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

                <!-- Datos del Solicitante -->
                <div class="section">
                    <div class="section-title">Datos del Solicitante</div>
                    <div class="field-group">
                        <div class="form-field">
                            <label class="form-label">Nombre:</label>
                            <cfoutput>
                                <input type="text"
                                    value="#qSolicitud.nombre# #qSolicitud.apellido_paterno# #qSolicitud.apellido_materno#"
                                    class="form-input"
                                    readonly>
                            </cfoutput>
                        </div>
                        <div class="form-field">
                            <label class="form-label">Área de Adscripción:</label>
                            <cfoutput>
                                <input type="text"
                                    value="#qSolicitud.area_nombre#"
                                    class="form-input"
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
                                    class="form-input"
                                    readonly>
                            </cfoutput>
                        </div>
                        <div class="form-field">
                            <label class="form-label">Tipo de permiso:</label>
                            <cfoutput>
                                <input type="text"
                                    value="#qSolicitud.tipo_permiso#"
                                    class="form-input"
                                    readonly>
                            </cfoutput>
                        </div>
                        <div class="form-field">
                            <label class="form-label">Fecha:</label>
                            <cfoutput>
                                <input type="date"
                                    value="#DateFormat(qSolicitud.fecha,'yyyy-mm-dd')#"
                                    class="form-input"
                                    readonly>
                            </cfoutput>
                        </div>
                        <div class="form-field">
                            <label class="form-label">Tiempo Solicitado:</label>
                            <cfoutput>
                                <input type="text"
                                    value="#qSolicitud.tiempo_solicitado#"
                                    class="form-input"
                                    readonly>
                            </cfoutput>
                        </div>
                        <div class="form-field">
                            <label class="form-label">Hora de Salida:</label>
                            <cfoutput>
                                <input type="time"
                                    value="#TimeFormat(qSolicitud.hora_salida,'HH:mm')#"
                                    class="form-input"
                                    readonly>
                            </cfoutput>
                        </div>
                        <div class="form-field">
                            <label class="form-label">Hora de Llegada:</label>
                            <cfoutput>
                                <input type="time"
                                    value="#TimeFormat(qSolicitud.hora_llegada,'HH:mm')#"
                                    class="form-input"
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
                        <div class="signature-wrapper">
                            <cfoutput>
                                <div id="firma-solicitante-display">#qSolicitud.firma_solicitante#</div>
                            </cfoutput>
                        </div>
                    </div>

                    <!-- Firma del Superior -->
                    <div class="signature-field">
                        <cfoutput>
                            <div class="signature-label">Tu Firma (#session.rol#)</div>
                        </cfoutput>
                        <div id="signature-wrapper-superior" class="signature-wrapper" role="application" aria-label="Área de firma">
                            <svg id="signature-svg-superior" class="signature-svg"
                                 xmlns="http://www.w3.org/2000/svg"
                                 width="100%" height="200"
                                 viewBox="0 0 1000 200"
                                 preserveAspectRatio="xMidYMid meet"></svg>
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
                    <button type="submit" name="submit" value="Aprobado" class="submit-btn-aceptar">Aceptar</button>
                    <button type="submit" name="submit" value="Rechazado" class="submit-btn">Rechazar</button>
                </div>
                <div class="submit-section">
                    <button class="submit-btn-menu"><a href="menu.cfm" class="submit-btn-menu2">Menú</a></button>
                    <button class="submit-btn-cerrarSesion"><a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion2">
                            Cerrar Sesion
                    </a></button>
                </div>
            </form>
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
</body>
</html>
