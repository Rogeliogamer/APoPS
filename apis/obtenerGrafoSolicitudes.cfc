<cfcomponent>
    <cffunction name="getDatosGrafo" access="remote" returnformat="json">
        
        <cfset resultado = { "nodes" = [], "edges" = [] }>
        <cfset usuariosAgregados = "">

        <cfquery name="qSolicitudes" datasource="autorizacion">
            SELECT 
                s.id_solicitud, 
                s.tipo_solicitud, 
                s.tipo_permiso, 
                s.status_final, 
                s.id_solicitante,
                d.nombre,
                d.apellido_paterno
            FROM solicitudes s
            LEFT JOIN usuarios u ON s.id_solicitante = u.id_usuario
            LEFT JOIN datos_usuario d ON u.id_datos = d.id_datos
            ORDER BY s.id_solicitud DESC
            
        </cfquery>

        <cfset listaSolicitudes = valueList(qSolicitudes.id_solicitud)>
        
        <cfif listLen(listaSolicitudes) EQ 0>
            <cfreturn resultado>
        </cfif>

        <cfloop query="qSolicitudes">
            <cfset grupoStatus = "solicitud_pending">
            <cfif status_final EQ 'Aprobado'><cfset grupoStatus = "solicitud_ok"></cfif>
            <cfif status_final EQ 'Rechazado'><cfset grupoStatus = "solicitud_bad"></cfif>

            <cfset arrayAppend(resultado.nodes, {
                "id": "sol_" & id_solicitud,
                "label": "Sol ##" & id_solicitud & "\n(" & tipo_solicitud & ")",
                "group": grupoStatus,
                "title": "Permiso: " & tipo_permiso & "<br>Estado: " & status_final
            })>

            <cfif NOT listFind(usuariosAgregados, id_solicitante)>
                <cfset arrayAppend(resultado.nodes, {
                    "id": "user_" & id_solicitante,
                    "label": nombre & " " & left(apellido_paterno, 1) & ".",
                    "group": "usuario_solicitante",
                    "title": "Solicitante Original"
                })>
                <cfset usuariosAgregados = listAppend(usuariosAgregados, id_solicitante)>
            </cfif>

            <cfset arrayAppend(resultado.edges, {
                "from": "user_" & id_solicitante,
                "to": "sol_" & id_solicitud,
                "arrows": "to",
                "label": "Creo",
                "color": { "color": "##2B7CE9" }
            })>
        </cfloop>

        <cfquery name="qFirmas" datasource="autorizacion">
            SELECT 
                f.id_solicitud, 
                f.id_usuario, 
                f.rol, 
                f.aprobado,
                d.nombre,
                d.apellido_paterno
            FROM firmas f
            INNER JOIN usuarios u ON f.id_usuario = u.id_usuario
            INNER JOIN datos_usuario d ON u.id_datos = d.id_datos
            WHERE f.id_solicitud IN (<cfqueryparam value="#listaSolicitudes#" list="true">)
        </cfquery>

        <cfloop query="qFirmas">
            <cfif NOT listFind(usuariosAgregados, id_usuario)>
                <cfset arrayAppend(resultado.nodes, {
                    "id": "user_" & id_usuario,
                    "label": nombre & " " & left(apellido_paterno, 1) & ".",
                    "group": "usuario_autoridad",
                    "title": "Rol: " & rol
                })>
                <cfset usuariosAgregados = listAppend(usuariosAgregados, id_usuario)>
            </cfif>

            <cfset colorFirma = "##888888"> 
            <cfif aprobado EQ 'Aprobado'><cfset colorFirma = "##00cc66"></cfif>
            <cfif aprobado EQ 'Rechazado'><cfset colorFirma = "##ff4444"></cfif>

            <cfset arrayAppend(resultado.edges, {
                "from": "user_" & id_usuario,
                "to": "sol_" & id_solicitud,
                "arrows": "to",
                "label": "Firmo (" & left(rol,3) & ")",
                "dashes": true,
                "color": { "color": colorFirma }
            })>
        </cfloop>

        <cfreturn resultado>
    </cffunction>
</cfcomponent>