<!---
  * API para obtener el conteo de tipos de solicitud de personal VS oficial
  * 
  * Parámetros de entrada:
  *   - rango (opcional): Número de días para el rango de fechas (por defecto 30 días)
  *   - area (requerido): ID del área para filtrar las solicitudes
  * 
  * Parámetros de salida:
  * JSON con el conteo de tipos de solicitud
  * 
  * Autor: Rogelio Perez Guevara
  * 
  * Fecha de creación: 21-10-2025
  * 
  * Versión: 1.0   
 --->

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
