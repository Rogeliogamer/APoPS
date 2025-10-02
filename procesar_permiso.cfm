<!--- DEBUG temporal: ver qué llega en FORM --->
<!--- <cfdump var="#FORM#"><cfabort> --->

<cfif NOT StructKeyExists(FORM, "firma_svg") OR Len(Trim(FORM.firma_svg)) EQ 0>
  <cfoutput>
    <p style="color:red">Error: no se recibió la firma. Asegúrate de firmar y de que el campo oculto &quot;firma_svg&quot; esté presente en el formulario.</p>
  </cfoutput>
  <cfabort>
</cfif>

<!--- Ahora insertar con seguridad --->
<cfquery datasource="autorizacion" name="qInsertSolicitud">
  INSERT INTO Solicitudes (
    id_solicitante, id_area, tipo_solicitud, motivo, tipo_permiso, fecha,
    tiempo_solicitado, hora_salida, hora_llegada, status_final, fecha_creacion
  ) VALUES (
    <cfqueryparam value="#session.id_usuario#" cfsqltype="cf_sql_integer">,
    (SELECT id_area FROM datos_usuario WHERE id_datos = <cfqueryparam value="#session.id_usuario#" cfsqltype="cf_sql_integer">),
    <cfqueryparam value="#FORM.motivo#" cfsqltype="cf_sql_varchar">,
    <cfqueryparam value="#FORM.motivo#" cfsqltype="cf_sql_varchar">,
    <cfqueryparam value="#FORM.tipo_permiso#" cfsqltype="cf_sql_varchar">,
    <cfqueryparam value="#FORM.fecha#" cfsqltype="cf_sql_date">,
    <cfqueryparam value="#FORM.tiempo_solicitado#" cfsqltype="cf_sql_integer">,
    <cfqueryparam value="#FORM.hora_salida#" cfsqltype="cf_sql_time">,
    <cfqueryparam value="#FORM.hora_llegada#" cfsqltype="cf_sql_time">,
    'Pendiente',
    NOW()
  )
</cfquery>

<cfquery name="qGetID" datasource="autorizacion">
  SELECT LAST_INSERT_ID() AS id_solicitud
</cfquery>

<cfquery datasource="autorizacion" name="qInsertFirma">
  INSERT INTO firmas (id_solicitud, id_usuario, rol, svg, aprobado, fecha_firma)
  VALUES (
    <cfqueryparam value="#qGetID.id_solicitud#" cfsqltype="cf_sql_integer">,
    <cfqueryparam value="#session.id_usuario#" cfsqltype="cf_sql_integer">,
    'Solicitante',
    <cfqueryparam value="#FORM.firma_svg#" cfsqltype="cf_sql_longvarchar">,
    'Aprobado',
    NOW()
  )
</cfquery>

<!--- Redirige después de guardar --->
<cflocation url="menu.cfm" addtoken="false">