<cftry>
    <!--- Obtener variables del formulario --->
    <cfset id_solicitud = form.id_solicitud>
    <cfset rol = form.rol>
    <cfset aprobado = form.submit> <!-- 'Aprobado' o 'Rechazado' -->
    <cfset svg_firma = form.firma_superior_svg>
    <cfset id_usuario = session.id_usuario> <!-- Usuario en sesión -->

    <!--- Validar que se envió la firma --->
    <cfif len(trim(svg_firma)) eq 0>
        <!--- Mostrar mensaje de error en la misma página --->
        <cflocation url="firmarSolicitud.cfm?id_solicitud=#id_solicitud#&error=1" addtoken="no">
        <cfabort>
    </cfif>

    <!--- Verificar si ya existe una firma de este rol para la solicitud --->
    <cfquery name="qCheckFirma" datasource="autorizacion">
        SELECT id_firma 
        FROM firmas
        WHERE id_solicitud = <cfqueryparam value="#id_solicitud#" cfsqltype="cf_sql_integer">
          AND rol = <cfqueryparam value="#rol#" cfsqltype="cf_sql_varchar">
        LIMIT 1
    </cfquery>

    <!--- Si existe, actualizar; si no, insertar --->
    <cfif qCheckFirma.recordcount>
        <cfquery name="qUpdateFirma" datasource="autorizacion">
            UPDATE firmas
            SET svg = <cfqueryparam value="#svg_firma#" cfsqltype="cf_sql_longvarchar">,
                aprobado = <cfqueryparam value="#aprobado#" cfsqltype="cf_sql_varchar">,
                fecha_firma = NOW(),
                id_usuario = <cfqueryparam value="#id_usuario#" cfsqltype="cf_sql_integer">
            WHERE id_firma = <cfqueryparam value="#qCheckFirma.id_firma#" cfsqltype="cf_sql_integer">
        </cfquery>
    <cfelse>
        <cfquery name="qInsertFirma" datasource="autorizacion">
            INSERT INTO firmas (id_solicitud, id_usuario, rol, svg, aprobado)
            VALUES (
                <cfqueryparam value="#id_solicitud#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#id_usuario#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#rol#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#svg_firma#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#aprobado#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
    </cfif>

    <!--- Redirigir a la página de solicitud firmada --->
    <cflocation url="pendientesFirmar.cfm" addtoken="no">

<cfcatch type="any">
    <cfoutput>
        <p>Error: #cfcatch.message#</p>
    </cfoutput>
</cfcatch>
</cftry>
