<!-- detalleSolicitud.cfm -->
<cfparam name="url.id_solicitud" default="0">

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
    WHERE s.id_solicitud = <cfqueryparam value="#url.id_solicitud#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="qFirmas" datasource="autorizacion">
    SELECT rol, aprobado, fecha_firma, svg
    FROM firmas
    WHERE id_solicitud = <cfqueryparam value="#url.id_solicitud#" cfsqltype="cf_sql_integer">
    ORDER BY FIELD(rol, 'Solicitante','Jefe','RecursosHumanos','Autorizacion','Expediente')
</cfquery>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle de Solicitud</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/globalForm.css">
    <style>
        .signature-svg svg {
            width: 150px;
            height: 80px;
            display: block;
            margin: 0 auto 10px auto;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <div class="logo">Detalle Solicitud</div>
        <h1>Solicitud #<cfoutput>#qSolicitud.id_solicitud#</cfoutput></h1>
    </div>
    <div class="form-container">
        <div class="section">
            <div class="section-title">Información de la Solicitud</div>
            <div class="field-group single">
                <cfoutput>
                <div class="form-field">
                    <label class="form-label">Solicitante</label>
                    <input type="text" class="form-input" value="#qSolicitud.solicitante#" readonly>
                </div>
                <div class="form-field">
                    <label class="form-label">Tipo de Solicitud</label>
                    <input type="text" class="form-input" value="#qSolicitud.tipo_solicitud#" readonly>
                </div>
                <div class="form-field">
                    <label class="form-label">Motivo</label>
                    <input type="text" class="form-input" value="#qSolicitud.motivo#" readonly>
                </div>
                <div class="form-field">
                    <label class="form-label">Tipo de Permiso</label>
                    <input type="text" class="form-input" value="#qSolicitud.tipo_permiso#" readonly>
                </div>
                <div class="form-field">
                    <label class="form-label">Fecha</label>
                    <input type="text" class="form-input" value="#DateFormat(qSolicitud.fecha,'dd/mm/yyyy')#" readonly>
                </div>
                <div class="form-field">
                    <label class="form-label">Hora de Salida</label>
                    <input type="text" class="form-input" value="#TimeFormat(qSolicitud.hora_salida,'HH:mm')#" readonly>
                </div>
                <div class="form-field">
                    <label class="form-label">Hora de Llegada</label>
                    <input type="text" class="form-input" value="#TimeFormat(qSolicitud.hora_llegada,'HH:mm')#" readonly>
                </div>
                <div class="form-field">
                    <label class="form-label">Tiempo Solicitado</label>
                    <input type="text" class="form-input" value="#qSolicitud.tiempo_solicitado#" readonly>
                </div>
                <div class="form-field">
                    <label class="form-label">Status Final</label>
                    <input type="text" class="form-input" value="#qSolicitud.status_final#" readonly>
                </div>
                </cfoutput>
            </div>
        </div>

        <div class="section">
            <div class="section-title">Firmas</div>
            <div class="signature-section">
                <cfoutput query="qFirmas">
                    <div class="signature-field">
                        <div class="signature-label">#rol#</div>
                        <!-- SVG de la firma -->
                <div class="signature-svg">
                    #svg#
                </div>
                        <div class="signature-line"></div>
                        <div>#aprobado#</div>
                        <div>#DateFormat(fecha_firma,'dd/mm/yyyy')# #TimeFormat(fecha_firma,'HH:mm')#</div>
                    </div>
                </cfoutput>
            </div>
        </div>

        <div class="submit-section">
            <a href="menu.cfm" class="submit-btn">Regresar</a>
        </div>
    </div>
</div>
</body>
</html>
