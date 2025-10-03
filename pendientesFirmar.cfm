<!---
 * Página `pendientesFirmar.cfm` para la gestión de solicitudes en espera de firma.
 *
 * Funcionalidad:
 * - Muestra la lista de solicitudes enviadas a cuentas con rol de firma.
 * - Cada solicitud puede ser aceptada o rechazada por el firmante.
 * - Una vez firmada (aceptada o rechazada), la solicitud se procesa y se almacena en la base de datos.
 * - Las solicitudes ya firmadas dejan de mostrarse en esta lista.
 *
 * Uso:
 * - Página destinada al flujo de revisión y firma de solicitudes por parte de las autoridades correspondientes.
--->

<!DOCTYPE html>
<html lang="es">
    <head>
        <!-- Metadatos y enlaces a estilos -->
        <meta charset="UTF-8">
        <!-- Vista adaptable para dispositivos móviles -->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Título de la página -->
        <title>Solicitudes Pendientes de Firma</title>
        <!-- Enlace a fuentes y hojas de estilo -->
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/pendientesFirmar.css">
        <link rel="stylesheet" href="css/tablas.css"
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
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
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
                        <table class="tabla">
                            <thead>
                                <tr class="titulos-tabla">
                                    <th class="titulo-general">ID</th>
                                    <th class="titulo-general">Solicitante</th>
                                    <th class="titulo-general">Área</th>
                                    <th class="titulo-general">Motivo</th>
                                    <th class="titulo-general">Tipo de Permiso</th>
                                    <th class="titulo-general">Fecha</th>
                                    <th class="titulo-general-centrado">Acción</th>
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
                                            <form method="get" action="firmarSolicitud.cfm">
                                                <input type="hidden" name="id_solicitud" value="#id_solicitud#">
                                                <button type="submit" class="submit-btn-firmar">Firmar</button>
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
                    <a href="menu.cfm" class="submit-btn-menu">Menu</a>
                    <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion">
                            Cerrar Sesion
                        </a>
                </div>
            </div>
        </div>
    </body>
</html>
