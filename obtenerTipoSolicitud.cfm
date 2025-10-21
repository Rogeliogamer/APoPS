<cfsetting showdebugoutput="No">
<cfcontent type="application/json" reset="true">

<cfparam name="url.rango" default="30">
<cfparam name="url.area" default="">

<cftry>
    <cfquery name="getTiposSolicitud" datasource="Autorizacion">
        SELECT tipo_solicitud AS TIPO, COUNT(*) AS CANTIDAD
        FROM solicitudes
        WHERE fecha_creacion >= DATE_SUB(NOW(), INTERVAL <cfqueryparam cfsqltype="cf_sql_integer" value="#url.rango#"> DAY)
        <cfif len(url.area)>
            AND id_area = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.area#">
        </cfif>
        GROUP BY tipo_solicitud
        ORDER BY tipo_solicitud
    </cfquery>

    <cfset result = { "TIPOSSOLICITUD" = [] }>

    <cfoutput query="getTiposSolicitud">
        <cfset arrayAppend(result.TIPOSSOLICITUD, { "TIPO" = TIPO, "CANTIDAD" = CANTIDAD })>
    </cfoutput>

    <cfoutput>#serializeJSON(result)#</cfoutput>

<cfcatch>
    <cfoutput>#serializeJSON({ "error" = "Ocurrió un error al obtener los datos." })#</cfoutput>
</cfcatch>
</cftry>
