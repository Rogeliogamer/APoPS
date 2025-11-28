<!--- 
 * Página de menú de adminitracion del sistema.
 *
 * Funcionalidad:
 * - Muestra las opciones disponibles para el adminstrador autenticado.
 * - Las opciones se habilitan o deshabilitan dinámicamente según el rol del usuario.
 * - Algunas opciones pueden no estar disponibles dependiendo de los permisos asignados.
 *
 * Uso:
 * - Incluir esta página como interfaz de navegación principal para usuarios logueados.
--->

<!--- Función para verificar acceso basado en rol --->
<cfscript>
    <!--- Retorna true si el rol tiene acceso a la página dada --->
    function tieneAcceso(pagina) {
        <!--- Obtener el rol del usuario desde la sesión --->
        var rol = session.rol;
        <!--- Definir los accesos por rol --->
        var accesos = {
            "Admin": [""]
        };

        <!--- Validar si el rol existe en el struct --->
        if (structKeyExists(accesos, rol)) {
            <!--- Verificar si la página está en la lista de accesos del rol --->
            return arrayFind(accesos[rol], pagina) > 0;
            <!--- Retorna true si se encuentra, false si no --->
        } else {
            <!--- Rol no reconocido, negar acceso --->
            return false;
        }
    }
</cfscript>

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
        <title>Menú Principal</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/menu.css">
        <link rel="stylesheet" href="../css/barraSuperior.css">
        <link rel="stylesheet" href="../css/botones.css">
    </head>
    <body>
        <!--- Verificar si existe un usuario logeado --->
        <cfif structKeyExists(session, "rol") AND len(trim(session.usuario))>
            <!--- El usuario está logeado, puede continuar --->
        <cfelse>
            <!--- No hay sesión, redirigir al login --->
            <cflocation url="login.cfm" addtoken="no">
        </cfif>

        <!--- Incluye la barra de usuario conectado --->
        <cfset barra = createObject("component", "../componentes/usuarioConectadoBarraAdmin.cfc").render()>
        <!--- Mostrar la barra --->
        <cfoutput>#barra#</cfoutput>

        <!--- Contenedor del menú --->
        <div class="menu-container">
            <!--- 1. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Titulo 1</h2>
                <p>Subtitulo</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("pase.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="pase.cfm" class="submit-btn-menu-original">Text</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Text</a>
                </cfif>
            </div>

            <!--- 2. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Titulo</h2>
                <p>Subtitulo</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("registrarUsuarios.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="registrarUsuarios.cfm" class="submit-btn-menu-original">Text</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Text</a>
                </cfif>
            </div>

            <!--- 3. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Titulo</h2>
                <p>Subtitulo</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaUsuarios.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="listaUsuarios.cfm" class="submit-btn-menu-original">Text</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Text</a>
                </cfif>
            </div>

            <!--- 4. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Titulo</h2>
                <p>Subtitulo</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("pendientesFirmar.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="pendientesFirmar.cfm" class="submit-btn-menu-original">Text</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Text</a>
                </cfif>
            </div>

            <!--- 5. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Titulo</h2>
                <p>Subtitulo</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("firmados.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="firmados.cfm" class="submit-btn-menu-original">Text</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Text</a>
                </cfif>
            </div>

            <!--- 6. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Titulo</h2>
                <p>Subtitulo</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="listaSolicitudes.cfm" class="submit-btn-menu-original">Text</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Text</a>
                </cfif>
            </div>

            <!--- 7. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Titulo</h2>
                <p>Subtitulo</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("metricas.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="metricas.cfm" class="submit-btn-menu-original">Text</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Text</a>
                </cfif>
            </div>

            <!--- 8. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Titulo</h2>
                <p>Subtitulo</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaTodasSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="listaTodasSolicitudes.cfm" class="submit-btn-menu-original">Text</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Text</a>
                </cfif>
            </div>

            <!--- 8. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Titulo</h2>
                <p>Subtitulo</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaTodasSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="listaTodasSolicitudes.cfm" class="submit-btn-menu-original">Text</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Text</a>
                </cfif>
            </div>
        </div>
    </body>
</html>
