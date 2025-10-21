<cfsetting showdebugoutput="No">
<cfcontent type="application/json" reset="true">

<cfparam name="url.rango" default="30">
<cfparam name="url.area" default="">

<cftry>
    <cfquery name="firmasPorRol" datasource="Autorizacion">
        SELECT u.rol AS ROL, COUNT(f.id_firma) AS CANTIDAD
        FROM firmas f
        INNER JOIN usuarios u ON f.id_usuario = u.id_usuario
        INNER JOIN solicitudes s ON f.id_solicitud = s.id_solicitud
        WHERE f.fecha_firma >= DATE_SUB(NOW(), INTERVAL <cfqueryparam cfsqltype="cf_sql_integer" value="#url.rango#"> DAY)
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
