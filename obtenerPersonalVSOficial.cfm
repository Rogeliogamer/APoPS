<cfsetting showdebugoutput="No">
<cfcontent type="application/json" reset="true">

<cfparam name="url.rango" default="30">
<cfparam name="url.area" default="">

<cfset fechaFin = now()>
<cfset fechaInicio = dateAdd("d", -val(url.rango), fechaFin)>

<cftry>
    <cfquery name="getTiposSolicitud" datasource="Autorizacion">
        SELECT tipo_solicitud AS TIPO, COUNT(*) AS CANTIDAD
        FROM solicitudes
        WHERE fecha BETWEEN
            <cfqueryparam value="#fechaInicio#" cfsqltype="cf_sql_date">
            AND 
            <cfqueryparam value="#fechaFin#" cfsqltype="cf_sql_date">
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
