<cfcomponent>
    <cffunction name="getPrediccion" access="remote" returnformat="json">
        <cfargument name="rangoDias" type="numeric" required="yes">
        <cfargument name="areaId" type="numeric" required="no">

        <!--- Fecha inicial del histórico --->
        <cfset fechaInicio = dateAdd("d", -arguments.rangoDias, now())>

        <!--- Consulta histórica --->
        <cfquery name="solicitudesHist" datasource="Autorizacion">
            SELECT fecha, tipo_solicitud, tipo_permiso, status_final, COUNT(*) as total
            FROM solicitudes
            WHERE fecha >= <cfqueryparam value="#fechaInicio#" cfsqltype="cf_sql_date">
            <cfif arguments.areaId neq "">
                AND id_area = <cfqueryparam value="#arguments.areaId#" cfsqltype="cf_sql_integer">
            </cfif>
            GROUP BY fecha, tipo_solicitud, tipo_permiso, status_final
            ORDER BY fecha ASC
        </cfquery>

        <!--- Transformar datos en array plano --->
        <cfset datos = []>
        <cfloop query="solicitudesHist">
            <cfset arrayAppend(datos, {
                "fecha" = fecha,
                "tipo_solicitud" = tipo_solicitud,
                "tipo_permiso" = tipo_permiso,
                "aprobados" = (status_final EQ "Aprobado") ? total : 0,
                "pendientes" = (status_final EQ "Pendiente") ? total : 0,
                "rechazados" = (status_final EQ "Rechazado") ? total : 0
            })>
        </cfloop>

        <!--- Credibilidad según cantidad de datos --->
        <cfset totalRegistros = arrayLen(datos)>
        <cfset credibilidad = min(100, totalRegistros * 10)>

        <!--- Predicción simple para próximos 7 días --->
        <cfset prediccion = []>
        <cfloop from="1" to="7" index="i">
            <cfset arrayAppend(prediccion, {
                "fecha" = dateFormat(dateAdd("d", i, now()), "yyyy-mm-dd"),
                "tipo_solicitud" = "Personal",
                "tipo_permiso" = "Por día completo",
                "aprobados" = round(avgArray(datos, "aprobados")),
                "pendientes" = round(avgArray(datos, "pendientes")),
                "rechazados" = round(avgArray(datos, "rechazados")),
                "credibilidad" = credibilidad
            })>
        </cfloop>

        <cfreturn prediccion>
    </cffunction>

    <cffunction name="avgArray">
        <cfargument name="arr" type="array" required="yes">
        <cfargument name="key" type="string" required="yes">
        <cfset var sum = 0>
        <cfset var count = 0>
        <cfloop array="#arguments.arr#" index="item">
            <cfset sum += item[arguments.key]>
            <cfset count += 1>
        </cfloop>
        <cfreturn (count GT 0) ? (sum / count) : 0>
    </cffunction>
</cfcomponent>
