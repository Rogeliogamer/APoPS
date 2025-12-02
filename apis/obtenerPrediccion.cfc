<cfcomponent>
    <cffunction name="getPrediccion" access="remote" returnformat="json">
        <cfargument name="rangoDias" type="numeric" required="yes">
        <cfargument name="areaId" type="any" required="no" default="">

        <cfset fechaInicio = dateAdd("d", -arguments.rangoDias, now())>

        <cfquery name="qHistoria" datasource="Autorizacion">
            SELECT 
                CAST(fecha AS DATE) as dia,
                SUM(CASE WHEN status_final = 'Aprobado' THEN 1 ELSE 0 END) as total_aprobados,
                SUM(CASE WHEN status_final = 'Pendiente' THEN 1 ELSE 0 END) as total_pendientes,
                SUM(CASE WHEN status_final = 'Rechazado' THEN 1 ELSE 0 END) as total_rechazados,
                COUNT(*) as total_general
            FROM solicitudes
            WHERE fecha >= <cfqueryparam value="#fechaInicio#" cfsqltype="cf_sql_date">
            <cfif isNumeric(arguments.areaId)>
                AND id_area = <cfqueryparam value="#arguments.areaId#" cfsqltype="cf_sql_integer">
            </cfif>
            GROUP BY CAST(fecha AS DATE)
        </cfquery>

        <cfset statsDias = structNew()>
        <cfloop from="1" to="7" index="i">
            <cfset statsDias[i] = {
                "acum_aprobados" = 0, "acum_pendientes" = 0, "acum_rechazados" = 0, "conteo_dias" = 0
            }>
        </cfloop>

        <cfloop query="qHistoria">
            <cfset dow = DayOfWeek(qHistoria.dia)> <cfset statsDias[dow].acum_aprobados += qHistoria.total_aprobados>
            <cfset statsDias[dow].acum_pendientes += qHistoria.total_pendientes>
            <cfset statsDias[dow].acum_rechazados += qHistoria.total_rechazados>
            <cfset statsDias[dow].conteo_dias += 1>
        </cfloop>

        <cfset credibilidadBase = min(98, qHistoria.recordCount * 2)>
        
        <cfset prediccion = []>
        
        <cfset nombresDias = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"]>
        
        <cfloop from="1" to="7" index="k">
            <cfset fechaFutura = dateAdd("d", k, now())>
            <cfset dowFuturo = DayOfWeek(fechaFutura)> <cfset datosDia = statsDias[dowFuturo]>
            
            <cfset divisor = (datosDia.conteo_dias GT 0) ? datosDia.conteo_dias : 1>
            
            <cfset avgAprob = round(datosDia.acum_aprobados / divisor)>
            <cfset avgPend = round(datosDia.acum_pendientes / divisor)>
            <cfset avgRech = round(datosDia.acum_rechazados / divisor)>
            <cfset credibilidadDia = max(10, credibilidadBase - (k * 2))>

            <cfset arrayAppend(prediccion, {
                "fecha" = dateFormat(fechaFutura, "dd/mm"),
                "nombre_dia" = nombresDias[dowFuturo], 
                "aprobados" = avgAprob,
                "pendientes" = avgPend,
                "rechazados" = avgRech,
                "credibilidad" = credibilidadDia,
                "tipo_solicitud" = "Estimación", 
                "tipo_permiso" = "Basado en Historial"
            })>
        </cfloop>

        <cfreturn prediccion>
    </cffunction>
</cfcomponent>