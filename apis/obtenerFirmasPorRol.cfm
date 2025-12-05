<!---
 * API: obtenerFirmasPorRol.cfm
 * 
 * Descripción: 
 * Proporciona el número de firmas realizadas por rol de usuario
 * en un rango de fechas determinado.
 * 
 * Parámetros de entrada:
 *   - rango (opcional): Número de días para el rango de fechas (por defecto 30 días)
 *   - area (requerido): ID del área para filtrar las firmas
 * 
 * Parámetros de salida:
 * JSON con el conteo de firmas por rol
 * 
 * Autor: Rogelio Perez Guevara
 * 
 * Fecha de creación: 21-10-2025
 * 
 * Versión: 1.0   
--->

<cfsetting showdebugoutput="No">
<cfcontent type="application/json" reset="true">

<cfparam name="url.rango" default="30" requerid="yes">
<cfparam name="url.area" default="" requerid="yes">

<cfset fechaFin = now()>
<cfset fechaInicio = dateAdd("d", -val(url.rango), fechaFin)>

<cftry>
    <cfquery name="firmasPorRol" datasource="Autorizacion">
        SELECT u.rol AS ROL, COUNT(f.id_firma) AS CANTIDAD
        FROM firmas f
        INNER JOIN usuarios u ON f.id_usuario = u.id_usuario
        INNER JOIN solicitudes s ON f.id_solicitud = s.id_solicitud
        WHERE fecha BETWEEN
            <cfqueryparam cfsqltype="cf_sql_date" value="#fechaInicio#">
            AND 
            <cfqueryparam cfsqltype="cf_sql_date" value="#fechaFin#">
        <cfif len(url.area)>
            AND s.id_area = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.area#">
        </cfif>
        GROUP BY u.rol
        ORDER BY u.rol
    </cfquery>

    <cfset result = { "FIRMASROL" = [] }>

    <cfoutput query="firmasPorRol">
        <cfset arrayAppend(result.FIRMASROL, { "ROL" = ROL, "CANTIDAD" = CANTIDAD })>
    </cfoutput>

    <cfoutput>#serializeJSON(result)#</cfoutput>

<cfcatch>
    <cfoutput>#serializeJSON({ "error" = "Ocurrió un error al obtener los datos." })#</cfoutput>
</cfcatch>
</cftry>
