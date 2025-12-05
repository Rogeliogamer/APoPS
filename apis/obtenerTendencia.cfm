<!---
 * API: obtenerTendencia.cfm
 * 
 * Descripción: 
 * Proporciona una tendencia diaria de solicitudes aprobadas, pendientes y rechazadas
 * en un rango de fechas determinado.
 * 
 * Parámetros de entrada:
 *   - rango (opcional): Número de días para el rango de fechas (por defecto 30 días)
 *  - area (opcional): ID del área para filtrar las solicitudes
 * 
 * Parámetros de salida:
 * JSON con la tendencia diaria de solicitudes
 * 
 * Autor: Rogelio Perez Guevara
 * 
 * Fecha de creación: 20-10-2025
 * 
 * Versión: 1.0   
--->

<cfsetting enablecfoutputonly="yes">
<cfcontent type="application/json; charset=utf-8">

<cfparam name="form.rango" default="30">
<cfparam name="form.area" default="">

<!--- Conexión a la base de datos --->
<cfset fechaFin = dateFormat(now(), "yyyy-mm-dd")>
<cfset fechaInicio = dateFormat(dateAdd("d", -val(form.rango)+1, now()), "yyyy-mm-dd")>

<!--- Generar un array con todas las fechas del rango --->
<cfset fechasRango = []>
<cfloop from="0" to="#val(form.rango)-1#" index="i">
    <cfset arrayAppend(fechasRango, dateFormat(dateAdd("d", -i, now()), "yyyy-mm-dd"))>
</cfloop>
<cfset fechasRango = arrayReverse(fechasRango)> <!--- De más antiguo a más reciente --->

<!--- Consultar las métricas por fecha --->
<cfquery name="qTendencia" datasource="Autorizacion">
SELECT 
    fecha,
    SUM(CASE WHEN status_final = 'Aprobado' THEN 1 ELSE 0 END) AS aprobadas,
    SUM(CASE WHEN status_final = 'Pendiente' THEN 1 ELSE 0 END) AS pendientes,
    SUM(CASE WHEN status_final = 'Rechazado' THEN 1 ELSE 0 END) AS rechazadas
FROM solicitudes
WHERE fecha BETWEEN <cfqueryparam value="#fechaInicio#" cfsqltype="cf_sql_date">
                AND <cfqueryparam value="#fechaFin#" cfsqltype="cf_sql_date">
<cfif len(form.area)>
    AND id_area = <cfqueryparam value="#form.area#" cfsqltype="cf_sql_integer">
</cfif>
GROUP BY fecha
ORDER BY fecha ASC
</cfquery>

<!--- Convertir resultados a un struct por fecha para fácil acceso --->
<cfset tendenciasStruct = {} >
<cfloop query="qTendencia">
    <cfset tendenciasStruct[dateFormat(fecha, "yyyy-mm-dd")] = {
        "aprobadas" = qTendencia.aprobadas,
        "pendientes" = qTendencia.pendientes,
        "rechazadas" = qTendencia.rechazadas
    }>
</cfloop>

<!--- Construir array final con todas las fechas, incluso con 0 --->
<cfset tendencia = []>
<cfloop array="#fechasRango#" index="f">
    <cfif structKeyExists(tendenciasStruct, f)>
        <cfset arrayAppend(tendencia, {
            "fecha" = f,
            "aprobadas" = tendenciasStruct[f].aprobadas,
            "pendientes" = tendenciasStruct[f].pendientes,
            "rechazadas" = tendenciasStruct[f].rechazadas
        })>
    <cfelse>
        <cfset arrayAppend(tendencia, {
            "fecha" = f,
            "aprobadas" = 0,
            "pendientes" = 0,
            "rechazadas" = 0
        })>
    </cfif>
</cfloop>

<cfoutput>
#serializeJSON({ "tendencia" = tendencia })#
</cfoutput>
