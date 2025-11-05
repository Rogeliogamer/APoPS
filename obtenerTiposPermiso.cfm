<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json; charset=utf-8">

<cftry>
    <!-- Parámetros recibidos -->
    <cfparam name="url.id_area" default="">
    <cfparam name="url.rangoDias" default="30">

    <!-- Calcular fechas -->
    <cfset fechaFin = now()>
    <cfset fechaInicio = dateAdd("d", -int(url.rangoDias), fechaFin)>

    <!-- Validar que se haya seleccionado un área -->
    <cfif url.id_area EQ "">
        <cfoutput>#serializeJSON({"error":"No se seleccionó un área."})#</cfoutput>
        <cfabort>
    </cfif>

    <!-- Consulta principal -->
    <cfquery name="qTiposPermiso" datasource="Autorizacion">
        SELECT 
            s.tipo_permiso AS tipo_permiso,
            COUNT(s.id_solicitud) AS cantidad
        FROM 
            solicitudes s
        WHERE 
            s.id_area = <cfqueryparam value="#url.id_area#" cfsqltype="cf_sql_integer">
            AND fecha BETWEEN 
                <cfqueryparam value="#dateFormat(fechaInicio, 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
                AND 
                <cfqueryparam value="#dateFormat(fechaFin, 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
        GROUP BY 
            s.tipo_permiso
        ORDER BY 
            cantidad DESC
    </cfquery>

    <!-- Armar respuesta JSON -->
    <cfset tiposPermiso = []>
    <cfloop query="qTiposPermiso">
        <cfset arrayAppend(tiposPermiso, {
            "tipo_permiso" = qTiposPermiso.tipo_permiso,
            "cantidad" = qTiposPermiso.cantidad
        })>
    </cfloop>

    <cfoutput>#serializeJSON({"tiposPermiso": tiposPermiso})#</cfoutput>

<cfcatch type="any">
    <cfoutput>#serializeJSON({"error": cfcatch.message})#</cfoutput>
</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="false">
