<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Solicitudes Pendientes de Firma</title>
    <link rel="stylesheet" href="css/globalForm.css">
</head>
<body>
    <!--- Verificación de sesión y rol --->
    <cfif NOT structKeyExists(session, "rol") 
        OR ListFindNoCase("Expediente,RecursosHumanos,Autorizacion,Jefe", session.rol) EQ 0>
        <!--- Redirigir al usuario si no está autorizado --->
        <cflocation url="menu.cfm" addtoken="no">
    </cfif>

    <div class="container">
        <div class="header">
            <div class="logo">Sistema de Permisos</div>
            <h1>Solicitudes Pendientes de Firma</h1>
        </div>

        <div class="form-container">
            <cfquery name="qPendientes" datasource="autorizacion">
                SELECT s.id_solicitud, s.motivo, s.tipo_permiso, s.fecha,
                       du.nombre, du.apellido_paterno, du.apellido_materno,
                       aa.nombre AS area_nombre
                FROM solicitudes s
                LEFT JOIN datos_usuario du ON s.id_solicitante = du.id_datos
                LEFT JOIN area_adscripcion aa ON du.id_area = aa.id_area
                LEFT JOIN firmas f ON s.id_solicitud = f.id_solicitud 
                    AND f.rol = <cfqueryparam value="#session.rol#" cfsqltype="cf_sql_varchar">
                WHERE (f.id_firma IS NULL OR f.aprobado = 'Pendiente')
                ORDER BY s.fecha DESC
            </cfquery>

            <cfif qPendientes.recordcount eq 0>
                <div class="section">
                    <p>No tienes solicitudes pendientes de firma.</p>
                </div>
            <cfelse>
                <div class="section">
                    <div class="section-title">Listado de Solicitudes</div>
                    <table class="form-input">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Solicitante</th>
                                <th>Área</th>
                                <th>Motivo</th>
                                <th>Tipo de Permiso</th>
                                <th>Fecha</th>
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="qPendientes">
                                <tr>
                                    <td>#id_solicitud#</td>
                                    <td>#nombre# #apellido_paterno# #apellido_materno#</td>
                                    <td>#area_nombre#</td>
                                    <td>#motivo#</td>
                                    <td>#tipo_permiso#</td>
                                    <td>#DateFormat(fecha,'yyyy-mm-dd')#</td>
                                    <td>
                                        <form method="get" action="firmar_solicitud.cfm">
                                            <input type="hidden" name="id_solicitud" value="#id_solicitud#">
                                            <button type="submit" class="submit-btn">Firmar</button>
                                        </form>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </cfif>

            <div class="submit-section">
                <!-- Enlace para regresar al menú principal -->
                <a href="menu.cfm" class="submit-btn" style="text-decoration: none">Menu</a>
            </div>
        </div>
    </div>
</body>
</html>
