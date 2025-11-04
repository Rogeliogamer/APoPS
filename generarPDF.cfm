<!--- generarPDF.cfm --->
<cfparam name="url.id_solicitud" default="0">

<!--- Consultas --->
<cfquery name="qSolicitud" datasource="autorizacion">
    SELECT 
        s.id_solicitud,
        CONCAT(d.nombre, ' ', d.apellido_paterno, ' ', d.apellido_materno) AS solicitante,
        s.tipo_solicitud,
        s.motivo,
        s.tipo_permiso,
        s.fecha,
        s.tiempo_solicitado,
        s.hora_salida,
        s.hora_llegada,
        s.status_final
    FROM solicitudes s
    INNER JOIN usuarios u ON s.id_solicitante = u.id_usuario
    INNER JOIN datos_usuario d ON u.id_datos = d.id_datos
    WHERE s.id_solicitud = <cfqueryparam value="#url.id_solicitud#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="qFirmas" datasource="autorizacion">
    SELECT id_solicitud,
        rol, 
        aprobado, 
        fecha_firma, 
        svg
    FROM firmas
    WHERE id_solicitud = <cfqueryparam value="#url.id_solicitud#" cfsqltype="cf_sql_integer">
    ORDER BY FIELD(rol, 'Solicitante','Jefe','RecursosHumanos','Autorizacion','Expediente')
</cfquery>

<!--- Generar PDF --->
<cfdocument format="PDF" pageType="A4" orientation="portrait" marginTop="0.5" marginBottom="0.5" marginLeft="0.5" marginRight="0.5">

<style>
    body { 
        font-family: Arial, sans-serif; 
        margin: 0;
        padding: 25px;
        font-size: 11px;
        color: #333;
        line-height: 1.4;
    }
    
    .container { 
        width: 100%; 
    }
    
    .header {
        text-align: center;
        margin-bottom: 25px;
        border-bottom: 3px double #000080;
        padding-bottom: 15px;
    }
    
    .title {
        color: #000080;
        font-size: 19px;
        font-weight: bold;
        margin-bottom: 5px;
    }
    
    .subtitle {
        color: #666;
        font-size: 13px;
        font-weight: normal;
    }
    
    .section-title {
        background-color: #000080;
        color: white;
        padding: 10px 15px;
        font-weight: bold;
        margin: 10px 0 15px 0;
        border-radius: 5px;
        font-size: 12px;
        text-align: center;
    }
    
    .field-group {
        display: block;
        width: 100%;
    }
    
    .form-field {
        margin-bottom: 0px;
        page-break-inside: avoid;
        padding: 6px 0;
        border-bottom: 1px dotted #eee;
    }
    
    .form-label {
        font-weight: bold;
        display: inline-block;
        width: 170px;
        vertical-align: top;
        color: #333;
    }
    
    .form-value {
        display: inline-block;
        vertical-align: top;
        width: calc(100% - 180px);
        background-color: #f9f9f9;
        padding: 6px 10px;
        border-radius: 4px;
        border-left: 3px solid #000080;
    }
    
    .signature-section {
        display: block;
        width: 100%;
        margin-top: 30px;
        border-top: 2px solid #ccc;
        padding-top: 10px;
    }
    
    /* ESTILOS PARA TABLA HORIZONTAL */
    .signatures-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
        padding: 0;
    }
    
    .signature-cell {
        width: 20%; /* Para 5 firmas, 20% cada una */
        text-align: center;
        vertical-align: top;
        padding: 8px 4px;
    }
    
    .signature-box {
        border: 2px solid #ddd;
        border-radius: 6px;
        background: linear-gradient(to bottom, #fafafa, #f0f0f0);
        padding: 10px 6px;
        margin: 0 2px;
        min-height: 120px;
        display: inline-block;
        width: 95%;
    }
    
    .signature-role {
        font-weight: bold;
        font-size: 11px;
        color: #000080;
        text-transform: uppercase;
        margin-bottom: 8px;
        min-height: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .signature-status {
        font-size: 9px;
        margin: 6px 0;
        padding: 5px 3px;
        border-radius: 4px;
        font-weight: bold;
    }
    
    .status-aprobado {
        background-color: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }
    
    .status-rechazado {
        background-color: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }
    
    .status-pendiente {
        background-color: #fff3cd;
        color: #856404;
        border: 1px solid #ffeaa7;
    }
    
    .firma-digital {
        background-color: #e8f5e8;
        border: 1px solid #4caf50;
        color: #2e7d32;
        padding: 5px 3px;
        border-radius: 3px;
        margin: 5px 0;
        font-weight: bold;
        font-size: 8px;
    }
    
    .sin-firma {
        background-color: #fff3cd;
        border: 1px dashed #ffc107;
        color: #856404;
        padding: 5px 3px;
        border-radius: 3px;
        margin: 5px 0;
        font-style: italic;
        font-size: 8px;
    }
    
    .signature-date {
        font-size: 8px;
        color: #666;
        margin-top: 5px;
    }
    
    .footer {
        margin-top: 10px;
        padding: 15px;
        border-top: 2px solid #ccc;
        text-align: center;
        font-size: 9px;
        color: #666;
        background-color: #f9f9f9;
        border-radius: 5px;
    }
    
    .estado-general {
        text-align: center;
        margin: 10px 0;
        padding: 10px;
        border-radius: 5px;
        font-weight: bold;
        font-size: 12px;
    }
    
    .estado-aprobado {
        background-color: #d4edda;
        color: #155724;
        border: 2px solid #c3e6cb;
    }
    
    .estado-rechazado {
        background-color: #f8d7da;
        color: #721c24;
        border: 2px solid #f5c6cb;
    }
    
    .estado-pendiente {
        background-color: #fff3cd;
        color: #856404;
        border: 2px solid #ffeaa7;
    }

    .tamaño_letra {
        font-size: 11px;
    }
</style>

<div class="container">
    <div class="header">
        <div class="title">SOLICITUD DE PERMISO LABORAL</div>
        <div class="subtitle">Sistema de Autorización de Permisos</div>
    </div>
    
    <cfoutput>
        <div style="text-align: center; font-size: 15px; margin: 0px 0; padding: 10px; background-color: ##e3f2fd; border-radius: 5px;">
            <strong>Número de Solicitud:</strong> #qSolicitud.id_solicitud# | 
            <strong>Fecha de Generación:</strong> #DateFormat(now(), 'dd/mm/yyyy')# #TimeFormat(now(), 'HH:mm')#
        </div>
        
        <!-- Estado General de la Solicitud -->
        <div class="estado-general estado-#lcase(qSolicitud.status_final)#">
            <cfif qSolicitud.status_final EQ "Aprobado">
                ✓ SOLICITUD APROBADA
            <cfelseif qSolicitud.status_final EQ "Rechazado">
                ✗ SOLICITUD RECHAZADA
            <cfelse>
                ⏳ SOLICITUD PENDIENTE
            </cfif>
        </div>
    </cfoutput>
    
    <div class="section-title">
        INFORMACIÓN DE LA SOLICITUD
    </div>

    <div class="field-group">
        <cfoutput>
            <div class="form-field">
                <span class="form-label tamaño_letra">Solicitante:</span>
                <span class="form-value tamaño_letra">#qSolicitud.solicitante#</span>
            </div>

            <div class="form-field">
                <span class="form-label tamaño_letra">Tipo de Solicitud:</span>
                <span class="form-value tamaño_letra">#qSolicitud.tipo_solicitud#</span>
            </div>

            <div class="form-field">
                <span class="form-label tamaño_letra">Motivo:</span>
                <span class="form-value tamaño_letra">#qSolicitud.motivo#</span>
            </div>

            <div class="form-field">
                <span class="form-label tamaño_letra">Tipo de Permiso:</span>
                <span class="form-value tamaño_letra">#qSolicitud.tipo_permiso#</span>
            </div>

            <div class="form-field">
                <span class="form-label tamaño_letra">Fecha del Permiso:</span>
                <span class="form-value tamaño_letra">#DateFormat(qSolicitud.fecha, 'dd/mm/yyyy')#</span>
            </div>

            <div class="form-field">
                <span class="form-label tamaño_letra">Hora de Salida:</span>
                <span class="form-value tamaño_letra">#TimeFormat(qSolicitud.hora_salida, 'HH:mm')#</span>
            </div>

            <div class="form-field">
                <span class="form-label tamaño_letra">Hora de Llegada:</span>
                <span class="form-value tamaño_letra">#TimeFormat(qSolicitud.hora_llegada, 'HH:mm')#</span>
            </div>

            <div class="form-field">
                <span class="form-label tamaño_letra">Tiempo Solicitado:</span>
                <span class="form-value tamaño_letra">#qSolicitud.tiempo_solicitado#</span>
            </div>
        </cfoutput>
    </div>

    <div class="section-title">
        FIRMAS DE AUTORIZACIÓN
    </div>

    <div class="signature-section">
        <!-- TABLA CON UNA SOLA FILA PARA TODAS LAS FIRMAS EN HORIZONTAL -->
        <table class="signatures-table">
            <tr>
                <cfoutput query="qFirmas">
                    <td class="signature-cell">
                        <div class="signature-box">
                            <div class="signature-role">
                                #rol#
                            </div>
                            <span class="signature-label tamaño_letra">Estado:</span>
                            <div class="signature-status status-#lcase(aprobado)#">
                                <cfif aprobado EQ "Aprobado">
                                    ✓ APROBADO
                                <cfelseif aprobado EQ "Rechazado">
                                    ✗ RECHAZADO
                                <cfelse>
                                    ⏳ PENDIENTE
                                </cfif>
                            </div>
                            <span class="signature-label tamaño_letra">Firma:</span>
                            <div class="<cfif len(trim(svg))>firma-digital<cfelse>sin-firma</cfif>">
                                <cfif len(trim(svg))>
                                    ✓ FIRMADO
                                <cfelse>
                                    ⚠ SIN FIRMA
                                </cfif>
                            </div>
                            
                            <div class="signature-date">
                                <cfif isDate(fecha_firma)>
                                    #DateFormat(fecha_firma, "dd/mm/yyyy")#<br>
                                    #TimeFormat(fecha_firma, "HH:mm")#
                                <cfelse>
                                    Sin fecha
                                </cfif>
                            </div>
                        </div>
                    </td>
                </cfoutput>
            </tr>
        </table>
    </div>
    
    <!-- Nota sobre el proceso de firmas -->
    <!--- 
    <div style="margin-top: 15px; padding: 10px; background-color: #f8f9fa; border-radius: 5px; border-left: 4px solid #6c757d; font-size: 10px;">
        <strong>Nota:</strong> Todas las firmas mostradas representan el estado actual del proceso de autorización. 
        La solicitud requiere la aprobación de todas las instancias correspondientes.
    </div>
    --->

    <div class="footer">
        <cfoutput>
            <div><strong>Documento generado automáticamente</strong></div>
            <div>Sistema de Autorización de Permisos | #DateFormat(now(), 'dd/mm/yyyy')# #TimeFormat(now(), 'HH:mm:ss')#</div>
            <div style="margin-top: 4px; color: ##999;">
                Este documento tiene validez oficial una vez completado el proceso de firmas correspondiente.
            </div>
        </cfoutput>
    </div>
</div>

</cfdocument>

<cfabort>