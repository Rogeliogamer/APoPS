<!-- procesarRegistroUsuario.cfm -->
<cftry>
    <!-- Obtener y limpiar los datos del formulario -->
    <cfset nombre = trim(form.nombre)>
    <cfset apellido_paterno = trim(form.apellido_paterno)>
    <cfset apellido_materno = trim(form.apellido_materno)>

    <!-- Obtener el ID del área del formulario -->
    <cfset id_area = form.id_area>

    <!-- Asegurarse de que el nombre de usuario no tenga espacios en blanco al inicio o al final -->
    <cfset usuario = trim(form.usuario)>
    <!-- Eliminar cualquier etiqueta HTML del nombre de usuario para evitar inyecciones -->
    <cfset usuario = trim(reReplace(form.usuario, "<[^>]*>", "", "all"))>

    <!-- Obtener el rol y la contraseña del formulario -->
    <cfset rol = form.rol>
    <cfset contrasena = form.contrasena>

    <!-- Validación de seguridad de la contraseña -->
    <cfif len(contrasena) LT 8 
        OR NOT refind("[A-Z]", contrasena) 
        OR NOT refind("[a-z]", contrasena) 
        OR NOT refind("[0-9]", contrasena) 
        OR NOT refind("[°\|¬!\##$%&/()=?'\\¡¿¨´*+~\]\}`\[\{^;,:._<>/*\-+.]", contrasena)>
        
        <cfset session.mensajeRegistro = "La contraseña no cumple con los requisitos de seguridad.">
        <cfset session.tipoMensaje = "error">
        <cflocation url="registrarUsuarios.cfm" addtoken="no">
        <cfabort>
    </cfif>

    <!-- Hashear la contraseña usando SHA-256 para mayor seguridad -->
    <cfset contrasenaHash = hash(contrasena, "SHA-256")>

    <!-- Verificar si el usuario ya existe -->
    <cfquery name="checkUsuario" datasource="autorizacion">
        SELECT COUNT(*) AS total
        FROM usuarios
        WHERE usuario = <cfqueryparam value="#usuario#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <!-- Si ya existe, redirigir con mensaje de error -->
    <cfif checkUsuario.total GT 0>
        <cfset session.mensajeRegistro = "El usuario '#usuario#' ya existe. Intente con otro.">
        <cfset session.tipoMensaje = "error">
        <cflocation url="registrarUsuarios.cfm" addtoken="no">
    </cfif>

    <!-- Validar que solo contengan letras y espacios -->
    <cfif NOT REFindNoCase("^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$", nombre)>
        <cfset session.mensajeRegistro = "El campo Nombre solo debe contener letras.">
        <cfset session.tipoMensaje = "error">
        <cflocation url="registrarUsuarios.cfm" addtoken="no">
    </cfif>

    <cfif NOT REFindNoCase("^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$", apellido_paterno)>
        <cfset session.mensajeRegistro = "El campo Apellido Paterno solo debe contener letras.">
        <cfset session.tipoMensaje = "error">
        <cflocation url="registrarUsuarios.cfm" addtoken="no">
    </cfif>

    <cfif NOT REFindNoCase("^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$", apellido_materno)>
        <cfset session.mensajeRegistro = "El campo Apellido Materno solo debe contener letras.">
        <cfset session.tipoMensaje = "error">
        <cflocation url="registrarUsuarios.cfm" addtoken="no">
    </cfif>

    <!-- Insertar los datos del usuario en la tabla datos_usuario -->
    <cfquery name="insertDatos" datasource="autorizacion">
        INSERT INTO datos_usuario (nombre, apellido_paterno, apellido_materno, id_area)
        VALUES (
            <cfqueryparam value="#nombre#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#apellido_paterno#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#apellido_materno#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#id_area#" cfsqltype="cf_sql_integer">
        )
    </cfquery>

    <!-- Obtener el ID del último registro insertado en datos_usuario -->
    <cfquery name="getIdDatos" datasource="autorizacion">
        SELECT MAX(id_datos) AS id_datos FROM datos_usuario
    </cfquery>

    <!-- Almacenar el ID obtenido en una variable -->
    <cfset id_datos = getIdDatos.id_datos>

    <!-- Insertar los datos del usuario en la tabla usuarios -->
    <cfquery name="insertUsuario" datasource="autorizacion">
        INSERT INTO usuarios (usuario, rol, contraseña, id_datos)
        VALUES (
            <cfqueryparam value="#usuario#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#rol#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#contrasenaHash#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#id_datos#" cfsqltype="cf_sql_integer">
        )
    </cfquery>

    <!-- Establecer mensajes de éxito en la sesión -->
    <cfset session.mensajeRegistro = "Usuario registrado correctamente.">
    <cfset session.tipoMensaje = "exito">
    
    <!-- Redirigir de vuelta al formulario de registro -->
    <cflocation url="registrarUsuarios.cfm" addtoken="no">

    <!-- Manejo de errores -->
    <cfcatch type="any">
        <!-- Establecer mensajes de error en la sesión -->
        <cfset session.mensajeRegistro = "Error al registrar el usuario: #cfcatch.message#">
        <!-- Indicar que es un mensaje de error -->
        <cfset session.tipoMensaje = "error">
        <!-- Redirigir de vuelta al formulario de registro -->
        <cflocation url="registrarUsuario.cfm" addtoken="no">
    </cfcatch>
</cftry>