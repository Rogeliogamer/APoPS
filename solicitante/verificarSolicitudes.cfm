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
