<cfcontent type="text/html; charset=utf-8">

<cfparam name="form.rangoFechas" default="30">
<cfparam name="form.areaSeleccionada" default="">

<!--- Consulta ranking --->
<cfquery name="rankingAreas" datasource="Autorizacion">
    SELECT 
        a.id_area,
        a.nombre AS area,
        COUNT(s.id_solicitud) AS total_solicitudes,
        SUM(CASE WHEN s.status_final = 'Aprobado' THEN 1 ELSE 0 END) AS aprobadas,
        SUM(CASE WHEN s.status_final = 'Rechazado' THEN 1 ELSE 0 END) AS rechazadas,
        SUM(CASE WHEN s.status_final = 'Pendiente' THEN 1 ELSE 0 END) AS pendientes,
        ROUND(
            (SUM(CASE WHEN s.status_final = 'Aprobado' THEN 1 ELSE 0 END) / 
            NULLIF(COUNT(s.id_solicitud), 0)) * 100, 1
        ) AS tasa_aprobacion
    FROM area_adscripcion a
    LEFT JOIN solicitudes s 
        ON s.id_area = a.id_area
        AND s.fecha_creacion >= DATE_SUB(CURDATE(), INTERVAL <cfqueryparam value="#val(form.rangoFechas)#" cfsqltype="cf_sql_integer"> DAY)
    GROUP BY a.id_area
    ORDER BY total_solicitudes DESC
    LIMIT 10
</cfquery>

<!--- Generar filas de tabla --->
<cfif rankingAreas.recordCount EQ 0>
    <tr><td colspan="6" style="text-align:center;">No hay datos disponibles para el periodo seleccionado</td></tr>
<cfelse>
    <cfoutput query="rankingAreas">
        <tr
            <cfif rankingAreas.id_area EQ val(form.areaSeleccionada)>
                style="font-weight:bold; background-color:##1b263b; color:white;"
            </cfif>
        >
            <td>#area#</td>
            <td>#total_solicitudes#</td>
            <td>#aprobadas#</td>
            <td>#rechazadas#</td>
            <td>#pendientes#</td>
            <td>#tasa_aprobacion#%</td>
        </tr>
    </cfoutput>
</cfif>
