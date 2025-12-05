<!---
 * API: obtenerEstadoSolicitudes.cfm
 * 
 * Descripción: 
 * Proporciona métricas sobre el estado de las solicitudes de autorización
 * realizadas en un rango de fechas determinado.
 * 
 * Parámetros de entrada:
 *   - rango (opcional): Número de días para el rango de fechas (por defecto 30 días)
 *   - area (requerido): ID del área para filtrar las solicitudes
 * 
 * Parámetros de salida:
 * JSON con métricas de solicitudes
 * 
 * Autor: Rogelio Perez Guevara
 * 
 * Fecha de creación: 22-10-2025
 * 
 * Versión: 1.0   
--->

<cfsetting enablecfoutputonly="yes">
<cfcontent type="application/json; charset=utf-8">

<cfparam name="FORM.rango" default="30" required="yes">
<cfparam name="FORM.area" default="" required="yes">

<!--- Calcular fechas --->
<cfset fechaFin = now()>
<cfset fechaInicio = dateAdd("d", -val(FORM.rango), fechaFin)>

<!--- Consultar métricas --->
<cfquery name="getMetrics" datasource="Autorizacion">
    SELECT 
        COUNT(*) AS totalSolicitudes,
        SUM(CASE WHEN status_final='Aprobado' THEN 1 ELSE 0 END) AS aprobadas,
        SUM(CASE WHEN status_final='Pendiente' THEN 1 ELSE 0 END) AS pendientes,
        SUM(CASE WHEN status_final='Rechazado' THEN 1 ELSE 0 END) AS rechazadas,
        AVG(tiempo_solicitado) AS tiempoPromedio
    FROM solicitudes
    WHERE fecha BETWEEN <cfqueryparam value="#fechaInicio#" cfsqltype="cf_sql_date">
                  AND <cfqueryparam value="#fechaFin#" cfsqltype="cf_sql_date">
    <cfif FORM.area neq "">
        AND id_area = <cfqueryparam value="#FORM.area#" cfsqltype="cf_sql_integer">
    </cfif>
</cfquery>

<cfset total = getMetrics.totalSolicitudes>
<cfset aprobadas = getMetrics.aprobadas>
<cfset pendientes = getMetrics.pendientes>
<cfset rechazadas = getMetrics.rechazadas>
<cfset tiempoPromedio = getMetrics.tiempoPromedio>

<!--- Evitar division por cero --->
<cfset pctAprobadas = 0>
<cfset pctPendientes = 0>
<cfset pctRechazadas = 0>

<cfif total neq 0>
    <cfset pctAprobadas = (aprobadas / total) * 100>
    <cfset pctPendientes = (pendientes / total) * 100>
    <cfset pctRechazadas = (rechazadas / total) * 100>
</cfif>

<!--- Retornar JSON --->
<cfoutput>{
    "totalSolicitudes": #total#,
    "solicitudesAprobadas": #aprobadas#,
    "porcentajeAprobadas": #pctAprobadas#,
    "solicitudesPendientes": #pendientes#,
    "porcentajePendientes": #pctPendientes#,
    "solicitudesRechazadas": #rechazadas#,
    "porcentajeRechazadas": #pctRechazadas#,
    "tiempoPromedio": #tiempoPromedio#
}</cfoutput>
