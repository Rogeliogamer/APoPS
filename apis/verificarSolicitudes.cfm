<!---
 * Nombre de la página: verificarSolicitudes.cfm
 * 
 * Descripción:
 * Esta página verifica cuántas solicitudes personales ha realizado
 * el solicitante en el mes actual y devuelve el conteo en formato JSON.
 * 
 * Roles:
 * No aplica (se usa la sesión del solicitante).
 * 
 * Paginas relacionadas:
 * Ninguna.
 * 
 * Autor: Rogelio Pérez Guevara
 * 
 * Fecha de creación: 13-11-2025
 * 
 * Versión: 1.0
--->

<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json; charset=utf-8">
<cftry>

    <cfquery name="qContarSolicitudes" datasource="autorizacion">
        SELECT COUNT(*) AS total
        FROM Solicitudes
        WHERE id_solicitante = <cfqueryparam value="#session.id_usuario#" cfsqltype="cf_sql_integer">
        AND tipo_solicitud = 'Personal'
        AND MONTH(fecha_creacion) = MONTH(NOW())
        AND YEAR(fecha_creacion) = YEAR(NOW())
    </cfquery>

    <cfoutput>{"totalSolicitudes": #qContarSolicitudes.total#}</cfoutput>

    <cfcatch>
        <cfoutput>{"error": "No se pudo obtener las solicitudes."}</cfoutput>
    </cfcatch>
</cftry>
<cfsetting enablecfoutputonly="false">
