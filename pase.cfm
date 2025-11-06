<!--- 
 * Página `pase.cfm` para el llenado del formulario de solicitud.
 *
 * Funcionalidad:
 * - Permite al solicitante completar los campos necesarios para generar la solicitud.
 * - La solicitud será posteriormente revisada y firmada por las autoridades correspondientes.
 * - Todos los campos requeridos deben ser llenados; de lo contrario, no se podrá enviar la solicitud.
 *
 * Uso:
 * - Esta página centraliza la captura de información antes de iniciar el proceso de aprobación.
--->
<!DOCTYPE html>
<html lang="es">
    <head>
        <!--- Metadatos y enlaces a estilos --->
        <meta charset="UTF-8">
        <!--- Vista adaptable para dispositivos móviles --->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!--- Icono de la pagina --->
        <link rel="icon" href="elements/icono.ico" type="image/x-icon">
        <!--- Título de la página --->
        <title>Permiso o Pase de Salida</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/svgFirma.css">
        <link rel="stylesheet" href="css/pase.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!--- Validar que exista un sesión activa --->
        <cfif NOT structKeyExists(session, "rol") OR len(trim(session.rol)) EQ 0>
            <!--- No hay sesión activa, redirigir al login --->
            <cflocation url="login.cfm" addtoken="no">
        </cfif>

        <!--- Si el usuario es administrador, redirigir al menú principal --->
        <cfif session.rol EQ "admin">
            <cflocation url="menu.cfm" addtoken="no">
        </cfif>
        
        <div class="container">
            <div class="header">
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <h1>AUTORIZACIÓN DE PERMISO O PASE DE SALIDA</h1>
            </div>

            <!--- Contenedor del formulario --->
            <div class="form-container">
                <!--- Formulario de Solicitud de Permiso o Pase de Salida --->
                <form action="procesar_permiso.cfm" method="post" name="permisoForm">
                    
                    <!--- Datos del Solicitante --->
                    <div class="section">
                        <!--- Título de la sección --->
                        <div class="section-title">
                            Datos del Solicitante
                        </div>

                        <!--- Nombre Completo y Área de Adscripción --->
                        <div class="field-group">
                            <div class="form-field">

                                <!--- Consulta para obtener el nombre completo del usuario logueado --->
                                <cfquery name="qTiposPermiso" datasource="autorizacion">
                                    SELECT nombre, 
                                        apellido_paterno, 
                                        apellido_materno
                                    FROM datos_usuario
                                    WHERE id_datos = <cfqueryparam value="#session.id_usuario#" cfsqltype="cf_sql_integer">
                                </cfquery>

                                <!--- Nombre Completo --->
                                <label for="nombre" class="form-label">Nombre:</label>
                                <cfoutput>
                                <input type="text" 
                                    name="nombre" 
                                    id="nombre" 
                                    class="form-input-general" 
                                    required="yes" 
                                    message="Por favor ingrese el nombre completo"
                                    maxlength="100"
                                    value="#qTiposPermiso.nombre# #qTiposPermiso.apellido_paterno# #qTiposPermiso.apellido_materno#"
                                    readonly>
                                </cfoutput>
                            </div>
                            
                            <!--- Área de Adscripción --->
                            <div class="form-field">

                                <!--- Consulta para obtener el área de adscripción del usuario logueado --->
                                <cfquery name="qTipoAdscripcion" datasource="autorizacion">
                                    SELECT aa.nombre 
                                        AS nombre_area
                                    FROM datos_usuario du
                                    LEFT JOIN area_adscripcion aa
                                    ON du.id_area = aa.id_area
                                    WHERE du.id_datos = <cfqueryparam value="#session.id_usuario#" cfsqltype="cf_sql_integer">
                                </cfquery>

                                <!--- Etiqueta y campo de Área de Adscripción --->
                                <label for="area_adscripcion" class="form-label">Área de Adscripción:</label>
                                
                                <!--- Área de Adscripción --->
                                <cfoutput>
                                    <input type="text" 
                                        name="area_adscripcion" 
                                        id="area_adscripcion" 
                                        class="form-input-general" 
                                        required="yes" 
                                        message="Por favor ingrese el área de adscripción"
                                        maxlength="100"
                                        value="#qTipoAdscripcion.nombre_area#"
                                        readonly>
                                </cfoutput>
                            </div>
                        </div>
                    </div>

                    <!--- Descripción de la Solicitud --->
                    <div class="section">
                        <div class="section-title">
                            Descripción de la Solicitud
                        </div>
                        
                        <div class="form-field">
                            <!--- Seleccion del tipo de motivo --->
                            <label class="form-label">
                                Motivo:
                            </label>

                            <div class="checkbox-group">
                                <div class="checkbox-item">
                                    <input type="checkbox" 
                                        name="motivo" 
                                        value="Personal" 
                                        id="motivo_personal" 
                                        class="checkbox-input">
                                    <label for="motivo_personal" class="checkbox-label">Personal</label>
                                </div>

                                <div class="checkbox-item">
                                    <input type="checkbox" 
                                        name="motivo" 
                                        value="Oficial" 
                                        id="motivo_oficial" 
                                        class="checkbox-input">
                                    <label for="motivo_oficial" class="checkbox-label">Oficial</label>
                                </div>
                            </div>
                        </div>

                        <div class="field-group">
                            <div class="form-field">
                                <!--- Selecion del tipo de permiso --->
                                <label class="form-label">
                                    Tipo de permiso:
                                </label>

                                <div class="checkbox-group">
                                    <div class="checkbox-item">
                                        <input type="checkbox" 
                                            name="tipo_permiso" 
                                            value="Pase de Salida" 
                                            id="pase_salida" 
                                            class="checkbox-input">
                                        <label for="pase_salida" class="checkbox-label">Pase de Salida</label>
                                    </div>

                                    <div class="checkbox-item">
                                        <input type="checkbox" 
                                            name="tipo_permiso" 
                                            value="Llegar Tarde" 
                                            id="llegar_tarde" 
                                            class="checkbox-input">
                                        <label for="llegar_tarde" class="checkbox-label">Llegar Tarde</label>
                                    </div>

                                    <div class="checkbox-item">
                                        <input type="checkbox" 
                                            name="tipo_permiso" 
                                            value="Por día completo" 
                                            id="dia_completo" 
                                            class="checkbox-input">
                                        <label for="dia_completo" class="checkbox-label">Por día completo</label>
                                    </div>

                                    <div class="checkbox-item">
                                        <input type="checkbox" 
                                            name="tipo_permiso" 
                                            value="Salida temprano" 
                                            id="salida_temprano" 
                                            class="checkbox-input">
                                        <label for="salida_temprano" class="checkbox-label">Salida temprano</label>
                                    </div>
                                </div>
                            </div>

                            <!--- Fecha que se esta solicitando --->
                            <div class="form-field">
                                <label for="fecha" class="form-label">
                                    Fecha:
                                </label>

                                <!--- Obtener la fecha actual en formato YYYY-MM-DD --->
                                <cfset hoy = dateFormat(now(), "yyyy-mm-dd")>

                                <input type="date"
                                    name="fecha" 
                                    id="fecha" 
                                    class="form-input-general" 
                                    required="yes" 
                                    message="Por favor seleccione una fecha"
                                    min="<cfoutput>#hoy#</cfoutput>">
                            </div>
                        </div>

                        <!--- Tiempo que se esta solicitando --->
                        <div class="field-group triple">
                            <!--- Tiempo solicitado --->
                            <div class="form-field">
                                <label for="tiempo_solicitado" class="form-label">Tiempo Solicitado:</label>
                                <input type="number"
                                    min="0"
                                    max="24"
                                    step="1"
                                    name="tiempo_solicitado" 
                                    id="tiempo_solicitado" 
                                    class="form-input-general" 
                                    placeholder="ej: 2"
                                    required="yes">
                            </div>

                            <!--- Hora de salida --->
                            <div class="form-field">
                                <label for="hora_salida" class="form-label">Hora de Salida:</label>
                                <input type="time"
                                    name="hora_salida" 
                                    id="hora_salida" 
                                    class="form-input-general"
                                    required="yes">
                            </div>

                            <!--- Hora de llegada --->
                            <div class="form-field">
                                <label for="hora_llegada" class="form-label">Hora de llegada:</label>
                                <input type="time"
                                    name="hora_llegada" 
                                    id="hora_llegada" 
                                    class="form-input-general"
                                    required="yes">
                            </div>
                        </div>
                    </div>

                    <!--- Firmas --->
                    <div class="section">
                        <div class="section-title">
                            Firmas de Autorización
                        </div>
                        
                        <div class="signature-section">
                            <!--- Solicitud - Firmante (solo solicitante firma en esta versión) --->
                            <div class="signature-field">
                                <div class="signature-label">
                                    Solicitante
                                </div>

                                <!--- Área de firma --->
                                <div id="signature-wrapper-solicitante" class="signature-wrapper" role="application" aria-label="Área de firma">
                                    <svg id="signature-svg-solicitante" class="signature-svg"
                                        xmlns="http://www.w3.org/2000/svg" width="100%" height="100%"
                                        viewBox="0 0 1000 200" preserveAspectRatio="none"></svg>
                                </div>

                                <div class="signature-controls">
                                    <button id="clearBtn-solicitante" type="button" class="submit-btn-limpiar">
                                        Limpiar
                                    </button>
                                </div>

                                <!--- CAMPO OCULTO: debe estar dentro del form para que ColdFusion lo reciba --->
                                <input type="hidden" name="firma_svg" id="firma_svg">
                            </div>

                            <!--- Firmara la solicitud el jefe de area --->
                            <div class="signature-field">
                                <div class="signature-label">
                                    Firma del Jefe Inmediato
                                </div>

                                <!--- Área de firma --->
                                <div id="signature-wrapper" class="signature-wrapper" role="application" aria-label="Área de firma">
                                    <svg id="signature-svg" class="signature-svg" xmlns="http://www.w3.org/2000/svg" width="100%" height="200" viewBox="0 0 1000 200" preserveAspectRatio="xMidYMid meet"></svg>
                                </div>

                                <!--- Borra la firma --->
                                <div class="signature-controls">
                                    <button id="clearBtn" type="button" class="submit-btn-limpiar-disabled" disabled>
                                        Limpiar
                                    </button>
                                </div>
                            </div>

                            <!--- Firmara la solicitud los de Recusos Humanos --->
                            <div class="signature-field">
                                <div class="signature-label">
                                    Firma Dirección de Recursos Humanos
                                </div>

                                <!--- Área de firma --->
                                <div id="signature-wrapper" class="signature-wrapper" role="application" aria-label="Área de firma">
                                    <svg id="signature-svg" class="signature-svg" xmlns="http://www.w3.org/2000/svg" width="100%" height="200" viewBox="0 0 1000 200" preserveAspectRatio="xMidYMid meet"></svg>
                                </div>

                                <!--- Borra la firma --->
                                <div class="signature-controls">
                                    <button id="clearBtn" type="button" class="submit-btn-limpiar-disabled" disabled>
                                        Limpiar
                                    </button>
                                </div>
                            </div>

                            <!--- Firmara la solicitud para los de autorizacion --->
                            <div class="signature-field">
                                <div class="signature-label">
                                    Firma de Autorización
                                </div>

                                <!--- Área de firma --->
                                <div id="signature-wrapper" class="signature-wrapper" role="application" aria-label="Área de firma">
                                    <svg id="signature-svg" class="signature-svg" xmlns="http://www.w3.org/2000/svg" width="100%" height="200" viewBox="0 0 1000 200" preserveAspectRatio="xMidYMid meet"></svg>
                                </div>

                                <!--- Borra la firma --->
                                <div class="signature-controls">
                                    <button id="clearBtn" type="button" class="submit-btn-limpiar-disabled" disabled>
                                        Limpiar
                                    </button>
                                </div>
                            </div>

                            <!--- Firmara la solicitud para los de expediente --->
                            <div class="signature-field">
                                <div class="signature-label">
                                    Para Expediente y Control de Asistencia
                                </div>

                                <!--- Área de firma --->
                                <div id="signature-wrapper" class="signature-wrapper" role="application" aria-label="Área de firma">
                                    <svg id="signature-svg" class="signature-svg" xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" viewBox="0 0 1000 200" preserveAspectRatio="none"></svg>
                                </div>

                                <!--- Borra la firma --->
                                <div class="signature-controls">
                                    <button id="clearBtn" type="button" class="submit-btn-limpiar-disabled" disabled>
                                        Limpiar
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!--- Botón de Envío --->
                    <div class="submit-section">
                        <button type="submit" name="submit" class="submit-btn-enviar">
                            Enviar Solicitud
                        </button>
                    </div>
                </form>

                <div class="submit-section">
                    <!--- Enlace para regresar al menú principal --->
                    <div class="field-group">
                        <a href="menu.cfm" class="submit-btn-menu submit-btn-menu-text">
                            Menu
                        </a>
                    
                        <a href="cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                        Cerrar Sesion
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <script src="js/validacionForm.js"></script>

        <script src="js/svgFirma.js"></script>
    </body>
</html>