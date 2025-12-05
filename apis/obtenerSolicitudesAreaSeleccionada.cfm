<!--- 
 * API: obtenerSolicitudesAreaSeleccionada.cfm
 * 
 * Descripción:
 * proporciona una API para obtener los solicitantes y el conteo de sus solicitudes en un área específica
 * dentro de un rango de fechas determinado.
 *  
 * Parámetros de entrada:
 *   - rango (opcional): Número de días para el rango de fechas (por defecto 30 días)
 *   - area (requerido): ID del área para filtrar los solicitantes
 * 
 * Parámetros de salida:
 * JSON con la lista de solicitantes y el conteo de sus solicitudes por estado
 * 
 * Autor: Rogelio Perez Guevara
 * 
 * Fecha de creación: 20-10-2025
 * 
 * Versión: 1.0   
 --->

<cfsetting enablecfoutputonly="yes">
<cfcontent type="application/json; charset=utf-8">

<cfparam name="FORM.rango" default="30">
<cfparam name="FORM.area" default="">

<!--- Calcular fechas --->
<cfset fechaFin = now()>
<cfset fechaInicio = dateAdd("d", -val(FORM.rango), fechaFin)>

<cfif len(FORM.area) EQ 0>
    <cfoutput>
        #serializeJSON({ "firmantes" = [] })#
    </cfoutput>
    <cfabort>
</cfif>

<!--- Consultar los solicitantes y sus solicitudes en el área --->
<cfquery name="qFirmantes" datasource="Autorizacion">
    SELECT du.id_datos, CONCAT(du.nombre, ' ', du.apellido_paterno, ' ', du.apellido_materno) AS nombre,
           SUM(CASE WHEN s.status_final = 'Aprobado' THEN 1 ELSE 0 END) AS aprobadas,
           SUM(CASE WHEN s.status_final = 'Pendiente' THEN 1 ELSE 0 END) AS pendientes,
           SUM(CASE WHEN s.status_final = 'Rechazado' THEN 1 ELSE 0 END) AS rechazadas
    FROM datos_usuario du
    LEFT JOIN usuarios u ON u.id_datos = du.id_datos
    LEFT JOIN solicitudes s ON s.id_solicitante = u.id_usuario
    WHERE du.id_area = <cfqueryparam value="#FORM.area#" cfsqltype="cf_sql_integer">
        AND fecha BETWEEN 
            <cfqueryparam value="#dateFormat(fechaInicio, 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
            AND 
            <cfqueryparam value="#dateFormat(fechaFin, 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
    GROUP BY du.id_datos, du.nombre, du.apellido_paterno, du.apellido_materno
    ORDER BY du.nombre ASC
</cfquery>

<cfset firmantes = []>
<cfloop query="qFirmantes">
    <cfset arrayAppend(firmantes, {
        "id_datos"   = qFirmantes.id_datos,
        "nombre"     = qFirmantes.nombre,
        "aprobadas"  = qFirmantes.aprobadas,
        "pendientes" = qFirmantes.pendientes,
        "rechazadas" = qFirmantes.rechazadas
    })>
</cfloop>

<cfoutput>
    #serializeJSON({ "firmantes" = firmantes })#
</cfoutput>
