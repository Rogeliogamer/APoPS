<cfsetting enablecfoutputonly="yes">
<cfcontent type="application/json; charset=utf-8">

<cfparam name="FORM.rango" default="30">
<cfparam name="FORM.area" default="">

<!--- Conexión a la base de datos --->

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
