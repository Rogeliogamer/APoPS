<cfcontent type="text/html; charset=utf-8">

<cfparam name="form.areaSeleccionada" default="">
<cfparam name="form.rangoFechas" default="30">

<cfset areaSeleccionada = val(form.areaSeleccionada)>
<cfset dias = val(form.rangoFechas)>
<cfset fechaInicio = dateAdd("d", -dias, now())>

<cftry>
    <!-- Consulta SQL para obtener el Top 10 de solicitantes -->
    <cfquery name="rankingFirmantes" datasource="Autorizacion">
        SELECT 
            CONCAT(d.nombre, ' ', d.apellido_paterno, ' ', d.apellido_materno) AS firmante,
            u.rol,
            SUM(CASE WHEN s.status_final = 'Aprobado' THEN 1 ELSE 0 END) AS total_aprobadas,
            SUM(CASE WHEN s.status_final = 'Rechazado' THEN 1 ELSE 0 END) AS total_rechazadas,
            SUM(CASE WHEN s.status_final = 'Pendiente' THEN 1 ELSE 0 END) AS total_pendientes,
            COUNT(s.id_solicitud) AS total_solicitudes
        FROM solicitudes s
        INNER JOIN usuarios u ON s.id_solicitante = u.id_usuario
        INNER JOIN datos_usuario d ON u.id_datos = d.id_datos
        WHERE s.id_area = <cfqueryparam value="#areaSeleccionada#" cfsqltype="cf_sql_integer">
        AND s.fecha_creacion >= <cfqueryparam value="#fechaInicio#" cfsqltype="cf_sql_timestamp">
        GROUP BY firmante, u.rol
        ORDER BY total_solicitudes DESC
        LIMIT 10
    </cfquery>

    <!-- Si no hay registros -->
    <cfif rankingFirmantes.recordCount EQ 0>
        <tr>
            <td colspan="5" style="text-align:center;">No hay datos disponibles para los filtros seleccionados</td>
        </tr>
    <cfelse>
        <cfoutput query="rankingFirmantes">
            <tr>
                <td>#firmante#</td>
                <td>#rol#</td>
                <td>#total_solicitudes#</td>
                <td>#total_aprobadas#</td>
                <td>#total_rechazadas#</td>
                <td>#total_pendientes#</td>
            </tr>
        </cfoutput>
    </cfif>

<cfcatch type="any">
    <tr>
        <td colspan="5" style="color:red; text-align:center;">
            <b>Error:</b> #cfcatch.message#<br>
            <small>#cfcatch.detail#</small><br>
            <small>#cfcatch.tagContext[1].template# (línea #cfcatch.tagContext[1].line#)</small>
        </td>
    </tr>
</cfcatch>
</cftry>
