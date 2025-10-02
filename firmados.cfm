<cfquery name="qFirmados" datasource="autorizacion">
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
        s.status_final,
        f.rol,
        f.aprobado,
        f.fecha_firma
    FROM solicitudes s
    INNER JOIN firmas f ON s.id_solicitud = f.id_solicitud
    INNER JOIN usuarios u ON s.id_solicitante = u.id_usuario
    INNER JOIN datos_usuario d ON u.id_datos = d.id_datos
    WHERE f.id_usuario = <cfqueryparam value="#session.id_usuario#" cfsqltype="cf_sql_integer">
    ORDER BY f.fecha_firma DESC
</cfquery>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Solicitudes Firmadas</title>
    <link rel="stylesheet" href="css/globalForm.css">
</head>
<body>
    <!--- Verificación de sesión y rol --->
    <cfif NOT structKeyExists(session, "rol") 
        OR ListFindNoCase("Expediente,RecursosHumanos,Autorizacion,Jefe,Solicitante", session.rol) EQ 0>
        <!--- Redirigir al usuario si no está autorizado --->
        <cflocation url="menu.cfm" addtoken="no">
    </cfif>

    <div class="container">
        <div class="header">
            <div class="logo">APoPS</div>
            <h1>Solicitudes ya firmadas</h1>
        </div>

        <div class="form-container">
            <div class="section">
                <h2 class="section-title">Listado de solicitudes con firma</h2>

                <table style="width:100%; border-collapse: collapse;">
                    <thead>
                        <tr style="background:#667eea; color:white;">
                            <th style="padding:10px; text-align:left;">ID Solicitud</th>
                            <th style="padding:10px; text-align:left;">Solicitante</th>
                            <th style="padding:10px; text-align:left;">Motivo</th>
                            <th style="padding:10px; text-align:left;">Tipo Permiso</th>
                            <th style="padding:10px; text-align:left;">Fecha Solicitud</th>
                            <th style="padding:10px; text-align:left;">Rol</th>
                            <th style="padding:10px; text-align:left;">Estado</th>
                            <th style="padding:10px; text-align:left;">Fecha Firma</th>
                            <th style="padding:10px; text-align:center;">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="qFirmados">
                            <tr style="border-bottom:1px solid ##e2e8f0;">
                                <td style="padding:10px;">#id_solicitud#</td>
                                <td style="padding:10px;">#solicitante#</td>
                                <td style="padding:10px;">#motivo#</td>
                                <td style="padding:10px;">#tipo_permiso#</td>
                                <td style="padding:10px;">#DateFormat(fecha,'dd/mm/yyyy')#</td>
                                <td style="padding:10px;">#rol#</td>
                                <td style="padding:10px;">
                                    <cfif aprobado EQ "Aprobado">
                                        <span style="color:green; font-weight:bold;">✔ #aprobado#</span>
                                    <cfelse>
                                        <span style="color:red; font-weight:bold;">✘ #aprobado#</span>
                                    </cfif>
                                </td>
                                <td style="padding:10px;">#DateFormat(fecha_firma,'dd/mm/yyyy')#</td>
                                <td style="padding:10px; text-align:center;">
                                    <form action="solicitudDetalles.cfm" method="get">
                                        <input type="hidden" name="id_solicitud" value="#id_solicitud#">
                                        <button type="submit" class="submit-btn">Ver Detalles</button>
                                    </form>
                                </td>
                            </tr>
                        </cfoutput>
                    </tbody>
                </table>
            </div>
            <div class="submit-section">
                <!-- Enlace para regresar al menú principal -->
                <a href="menu.cfm" class="submit-btn" style="text-decoration: none">Menu</a>
            </div>
        </div>
    </div>
</body>
</html>
