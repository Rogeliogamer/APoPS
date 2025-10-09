<!---
 * Página `listaSolicitudes.cfm` para la visualización de solicitudes firmadas.
 *
 * Funcionalidad:
 * - Muestra un listado de las solicitudes firmadas por el usuario autenticado.
 * - Permite consultar información general y el estado actual de la firma.
 * - Incluye un botón que permite acceder a los detalles completos de cada solicitud.
 *
 * Uso:
 * - Página destinada al seguimiento de solicitudes firmadas por el usuario logueado.
--->

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
        <!-- Metadatos y enlaces a estilos -->
        <meta charset="UTF-8">
        <!-- Vista adaptable para dispositivos móviles -->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Título de la página -->
        <title>Solicitudes Firmadas</title>
        <!-- Enlace a fuentes y hojas de estilo -->
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/tablas.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!-- Verificación de sesión y rol -->
        <cfif NOT structKeyExists(session, "rol") 
            OR ListFindNoCase("Expediente,RecursosHumanos,Autorizacion,Jefe,Solicitante", session.rol) EQ 0>
            <cflocation url="menu.cfm" addtoken="no">
        </cfif>

        <div class="container">
            <div class="header">
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <h1>Solicitudes firmadas por ti</h1>
            </div>

            <div class="form-container">
                <div class="section">
                    <h2 class="section-title">Listado de solicitudes</h2>

                    <table class="tabla">
                        <thead>
                            <tr class="titulos-tabla">
                                <th class="titulo-general">ID Solicitud</th>
                                <th class="titulo-general">Solicitante</th>
                                <th class="titulo-general">Motivo</th>
                                <th class="titulo-general">Tipo Permiso</th>
                                <th class="titulo-general">Fecha Solicitud</th>
                                <th class="titulo-general">Rol</th>
                                <th class="titulo-general">Estado Firma</th>
                                <th class="titulo-general">Fecha Firma</th>
                                <th class="titulo-general-centrado">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="qFirmados">
                                <tr>
                                    <td class="titulo-general-centrado">#id_solicitud#</td>
                                    <td>#solicitante#</td>
                                    <td>#motivo#</td>
                                    <td>#tipo_permiso#</td>
                                    <td class="titulo-general-centrado">#DateFormat(fecha,'dd/mm/yyyy')#</td>
                                    <td>#rol#</td>
                                    <td>
                                        <cfif status_final EQ "Aprobado">
                                            <span class="status-aprobado">✔ #status_final#</span>
                                        <cfelseif status_final EQ "Rechazado">
                                            <span class="status-rechazado">✘ #status_final#</span>
                                        <cfelseif status_final EQ "Pendiente">
                                            <span class="status-pendiente">⏳ #status_final#</span>
                                        <cfelse>
                                            <span class="status-desconocido">#status_final#</span>
                                        </cfif>
                                    </td>
                                    <td class="titulo-general-centrado">#DateFormat(fecha_firma,'dd/mm/yyyy')# #TimeFormat(fecha_firma,'HH:mm')#</td>
                                    <td class="titulo-general-centrado">
                                        <form action="solicitudDetalles.cfm" method="get">
                                            <input type="hidden" name="id_solicitud" value="#id_solicitud#">
                                            <button type="submit" class="submit-btn-verDetalles">Ver Detalles</button>
                                        </form>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>

                <div class="submit-section">
                    <div class="field-group">
                        <a href="menu.cfm" class="submit-btn-menu submit-btn-menu-text">
                            Menú
                        </a>
                    
                        <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
