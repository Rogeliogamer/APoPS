<!--- 
 * Nombre de la pagina: solicitante/pase.cfm
 * 
 * Descripción:
 * Formulario para la solicitud de permisos o pases de salida por parte del solicitante.
 * 
 * Roles:
 * - Solicitante: Acceso completo para llenar y enviar el formulario de solicitud.
 * - Jefe: Acceso completo para llenar y enviar el formulario de solicitud como Solicitante.
 * - RecursosHumanos: Acceso completo para llenar y enviar el formulario de solicitud como Solicitante.
 * - Admin: Acceso completo para llenar y enviar el formulario de solicitud como Solicitante.
 * 
 * Paginas relacionadas:
 * login.cfm: Página de inicio de sesión.
 * adminPanel.cfm: Panel de administración al que son redirigidos los administradores.
 * procesarPermiso.cfm: Página que procesa la solicitud enviada desde este formulario.
 * http://www.w3.org/2000/svg: Espacio de nombres SVG utilizado para las firmas digitales.
 * menu.cfm: Página principal del menú para navegar por el sistema.
 * cerrarSesion.cfm: Página para cerrar la sesión del usuario.
 * validacionForm.js: Script para validar el formulario antes de enviarlo.
 * svgFirma.js: Script para manejar la captura de firmas digitales en formato SVG.
 * 
 * Autor: Rogelio Pérez Guevara
 * 
 * Fecha de creación: 24-09-2025
 * 
 * Versión: 1.0
--->

<!DOCTYPE html>
<html lang="es">
    <head>
        <!--- Metadatos y enlaces a estilos --->
        <meta charset="UTF-8">
        <!--- Vista adaptable para dispositivos móviles --->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!--- Icono de la pagina --->
        <link rel="icon" href="../elements/icono.ico" type="image/x-icon">
        <!--- Título de la página --->
        <title>Permiso o Pase de Salida</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/svgFirma.css">
        <link rel="stylesheet" href="../css/pase.css">
        <link rel="stylesheet" href="../css/botones.css">
    </head>
    <body>
        <!--- Verificación de sesión y rol --->
        <cfif NOT (structKeyExists(session, "rol") AND len(trim(session.usuario)))>
            <!--- Redirigir a la página de login si no hay sesión activa --->
            <cflocation url="../login.cfm" addtoken="no">
        <!--- Verificar si el rol del usuario es Admin --->
        <cfelseif ListFindNoCase("Solicitante,Jefe,RecursosHumanos,Admin", session.rol) EQ 0>
            <!--- Redirigir a la página de menú si el rol no es Admin --->
            <cflocation url="../menu.cfm" addtoken="no">
        </cfif>

        <!--- Contenedor principal --->
        <div class="container">
            <!--- Encabezado de la página --->
            <div class="header">
                <!--- Logo y título --->
                <div class="logo">
                    <cfset usuarioRol = createObject("component", "../componentes/usuarioConectadoSSoli").render()>
                    <cfoutput>#usuarioRol#</cfoutput>
                </div>
                <!--- Título de la página --->
                <h1>AUTORIZACIÓN DE PERMISO O PASE DE SALIDA</h1>
            </div>

            <!--- Contenedor del formulario --->
            <div class="form-container">
                <!--- Formulario de Solicitud de Permiso o Pase de Salida --->
                <form id="formPermiso" action="procesarPermiso.cfm" method="post" name="permisoForm">
                    
                    <!--- Datos del Solicitante --->
                    <div class="section">
                        <!--- Título de la sección --->
                        <div class="section-title">
                            Datos del Solicitante
                        </div>

                        <!--- Nombre Completo y Área de Adscripción --->
                        <div class="field-group">
                            <!--- Nombre Completo --->
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
                        <!--- Título de la sección --->
                        <div class="section-title">
                            Descripción de la Solicitud
                        </div>

                        <!--- Grupo de campos para tipo de solicitud, tipo de permiso, fecha y tiempo solicitado --->
                        <div class="form-field">
                            <!--- Selección del tipo de solicitud --->
                            <label class="form-label">
                                Tipo de solicitud:
                            </label>

                            <!--- Grupo de checkboxes para tipo de solicitud --->
                            <div class="checkbox-group">
                                <!--- Solicitud Personal --->
                                <div class="checkbox-item">
                                    <input type="checkbox" 
                                        name="solicitud" 
                                        value="Personal" 
                                        id="solicitud_personal" 
                                        class="checkbox-input">
                                    <label for="solicitud_personal" class="checkbox-label">Personal</label>
                                </div>
                                <!--- Solicitud Oficial --->
                                <div class="checkbox-item">
                                    <input type="checkbox" 
                                        name="solicitud" 
                                        value="Oficial" 
                                        id="Solicitud_oficial" 
                                        class="checkbox-input">
                                    <label for="Solicitud_oficial" class="checkbox-label">Oficial</label>
                                </div>
                            </div>
                        </div>

                        <!--- Grupo de campos para tipo de permiso, fecha y tiempo solicitado --->
                        <div class="field-group">
                            <!--- Tipo de permiso --->
                            <div class="form-field">
                                <!--- Selección del tipo de permiso --->
                                <label class="form-label">
                                    Tipo de permiso:
                                </label>

                                <!--- Grupo de checkboxes para tipo de permiso --->
                                <div class="checkbox-group">
                                    <!--- Tipo de permiso Pase de Salida --->
                                    <div class="checkbox-item">
                                        <input type="checkbox" 
                                            name="tipo_permiso" 
                                            value="Pase de Salida" 
                                            id="pase_salida" 
                                            class="checkbox-input">
                                        <label for="pase_salida" class="checkbox-label">Pase de Salida</label>
                                    </div>

                                    <!--- Tipo de permiso Llegar Tarde --->
                                    <div class="checkbox-item">
                                        <input type="checkbox" 
                                            name="tipo_permiso" 
                                            value="Llegar Tarde" 
                                            id="llegar_tarde" 
                                            class="checkbox-input">
                                        <label for="llegar_tarde" class="checkbox-label">Llegar Tarde</label>
                                    </div>

                                    <!--- Tipo de permiso Salir Temprano --->
                                    <div class="checkbox-item">
                                        <input type="checkbox" 
                                            name="tipo_permiso" 
                                            value="Por día completo" 
                                            id="dia_completo" 
                                            class="checkbox-input">
                                        <label for="dia_completo" class="checkbox-label">Por día completo</label>
                                    </div>

                                    <!--- Tipo de permiso Salida Temprano --->
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

                            <!--- Fecha del permiso --->
                            <div class="form-field">
                                <!--- Etiqueta y campo de Fecha --->
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
                                    min="1"
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

                    <!--- Sección de Firmas --->
                    <div class="section">
                        <!--- Título de la sección --->
                        <div class="section-title">
                            Firmas de Autorización
                        </div>
                        
                        <!--- Área de firmas --->
                        <div class="signature-section">
                            <!--- Firmara la solicitud el solicitante --->
                            <div class="signature-field">
                                <!--- Etiqueta de la firma --->
                                <div class="signature-label">
                                    Solicitante
                                </div>

                                <!--- Área de firma --->
                                <div id="signature-wrapper-solicitante" class="signature-wrapper" role="application" aria-label="Área de firma">
                                    <!--- SVG para la firma del solicitante --->
                                    <svg id="signature-svg-solicitante" class="signature-svg"
                                        xmlns="http://www.w3.org/2000/svg" width="100%" height="100%"
                                        viewBox="0 0 1000 200" preserveAspectRatio="none"></svg>
                                </div>

                                <!--- Borra la firma --->
                                <div class="signature-controls">
                                    <!--- Botón para limpiar la firma del solicitante --->
                                    <button id="clearBtn-solicitante" type="button" class="submit-btn-limpiar">
                                        Limpiar
                                    </button>
                                </div>

                                <!--- Campo oculto para almacenar la firma en formato SVG --->
                                <input type="hidden" name="firma_svg" id="firma_svg">
                            </div>

                            <!--- Firmara la solicitud el Jefe Inmediato --->
                            <div class="signature-field">
                                <!--- Etiqueta de la firma --->
                                <div class="signature-label">
                                    Firma del Jefe Inmediato
                                </div>

                                <!--- Área de firma --->
                                <div id="signature-wrapper" class="signature-wrapper" role="application" aria-label="Área de firma">
                                    <!--- SVG para la firma del Jefe Inmediato --->
                                    <svg id="signature-svg" class="signature-svg" xmlns="http://www.w3.org/2000/svg" width="100%" height="200" viewBox="0 0 1000 200" preserveAspectRatio="xMidYMid meet"></svg>
                                </div>

                                <!--- Borra la firma --->
                                <div class="signature-controls">
                                    <!--- Botón para limpiar la firma del Jefe Inmediato --->
                                    <button id="clearBtn" type="button" class="submit-btn-limpiar-disabled" disabled>
                                        Limpiar
                                    </button>
                                </div>
                            </div>

                            <!--- Firmara la solicitud para los de Recursos Humanos --->
                            <div class="signature-field">
                                <!--- Etiqueta de la firma --->
                                <div class="signature-label">
                                    Firma Dirección de Recursos Humanos
                                </div>

                                <!--- Área de firma --->
                                <div id="signature-wrapper" class="signature-wrapper" role="application" aria-label="Área de firma">
                                    <!--- SVG para la firma de Recursos Humanos --->
                                    <svg id="signature-svg" class="signature-svg" xmlns="http://www.w3.org/2000/svg" width="100%" height="200" viewBox="0 0 1000 200" preserveAspectRatio="xMidYMid meet"></svg>
                                </div>

                                <!--- Borra la firma --->
                                <div class="signature-controls">
                                    <!--- Botón para limpiar la firma de Recursos Humanos --->
                                    <button id="clearBtn" type="button" class="submit-btn-limpiar-disabled" disabled>
                                        Limpiar
                                    </button>
                                </div>
                            </div>                            
                        </div>
                    </div>

                    <!--- Botón de Envío --->
                    <div class="submit-section">
                        <!--- Botón para enviar la solicitud --->
                        <button type="submit" name="submit" class="submit-btn-enviar">
                            Enviar Solicitud
                        </button>
                    </div>
                </form>

                <!--- Sección de botones para menú y cerrar sesión --->
                <div class="submit-section">
                    <!---- Grupo de botones --->
                    <div class="field-group">
                        <!--- Botón para ir al menú principal --->
                        <a href="../menu.cfm" class="submit-btn-menu submit-btn-menu-text">
                            Menu
                        </a>
                        
                        <!--- Botón para cerrar sesión --->
                        <a href="../cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                            Cerrar Sesión
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!--- Enlace a scripts de validación y firma SVG --->
        <script src="../js/validacionForm.js"></script>

        <script src="../js/svgFirma.js"></script>

        <script>
            document.addEventListener("DOMContentLoaded", function() {
                <!--- 1. Localizamos el formulario por su nombre "permisoForm" --->
                const form = document.forms["permisoForm"];
    
                if (!form) return; <!--- Seguridad por si el script carga antes --->

                form.addEventListener("submit", async function(event) {
                    <!--- DETENER EL ENVÍO INMEDIATAMENTE --->
                    event.preventDefault();

                    <!--- 2. Localizamos los elementos SIN usar ID en el botón de envío --->
                    <!--- Buscamos el botón dentro del formulario por su clase CSS --->
                    const botón = form.querySelector(".submit-btn-enviar"); 
                    <!---  Buscamos el checkbox por su ID (ese sí lo tiene) --->
                    const checkPersonal = document.getElementById("solicitud_personal");

                    <!--- Función segura para enviar el formulario --->
                    <!--- (Esto evita el error si el botón se llama name="submit") --->
                    const forzarEnvio = () => {
                        HTMLFormElement.prototype.submit.call(form);
                    };

                    <!--- LÓGICA DE NEGOCIO --->

                    <!--- Si el checkbox "Personal" NO existe o NO está marcado: --->
                    if (!checkPersonal || !checkPersonal.checked) {
                        <!--- Se va directo, sin preguntas, sin AJAX --->
                        forzarEnvio(); 
                        return;
                    }

                    <!--- Si es PERSONAL, procedemos: --->
                    if(boton) {
                        boton.disabled = true; // Deshabilitar visualmente
                        <!--- Guardamos texto original por si cancela el usuario --->
                        if(!boton.dataset.textoOriginal) boton.dataset.textoOriginal = boton.innerText;
                        boton.innerText = "Verificando...";
                    }

                    try {
                        <!--- Consulta AJAX para verificar solicitudes personales --->
                        const response = await fetch("../apis/verificarSolicitudes.cfm", {
                            method: "GET",
                            headers: { "Cache-Control": "no-cache" }
                        });

                        const text = await response.text();
                        let data = {};

                        try {
                            data = JSON.parse(text);
                        } catch (e) {
                            <!--- Si falla el JSON, asumimos que está bien y enviamos --->
                            forzarEnvio();
                            return;
                        }

                        <!--- Verificar límite de solicitudes personales --->
                        let confirmar = true;
                        if (data.totalSolicitudes > 3) {
                            confirmar = confirm(`⚠️ AVISO:\n\nLlevas ${data.totalSolicitudes} solicitudes personales.\nEste número excede el límite sugerido (3).\n\n¿Deseas enviarla de todos modos?`);
                        }

                        if (confirmar) {
                            forzarEnvio();
                        } else {
                            <!--- CANCELADO POR EL USUARIO --->
                            if(boton) {
                                boton.disabled = false;
                                boton.innerText = boton.dataset.textoOriginal || "Enviar Solicitud";
                            }
                        }
                    } catch (error) {
                        console.error("Error de red:", error);
                        <!--- Ante error de red, dejamos pasar la solicitud --->
                        alert("No se pudo verificar el historial, pero se intentará enviar la solicitud.");
                        forzarEnvio();
                    }
                });
            });
        </script>
    </body>
</html>