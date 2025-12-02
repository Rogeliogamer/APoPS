<!--- 
 * Página de menú principal del sistema.
 *
 * Funcionalidad:
 * - Muestra las opciones disponibles para el usuario autenticado.
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
            "Solicitante": ["pase.cfm", "firmados.cfm", "listaSolicitudes.cfm", "metricas.cfm"],
            "Jefe": ["pase.cfm", "listaUsuarios.cfm", "pendientesFirmar.cfm", "firmados.cfm", "listaSolicitudes.cfm", "metricas.cfm"],
            "RecursosHumanos": ["pase.cfm", "listaUsuarios.cfm", "pendientesFirmar.cfm", "firmados.cfm", "listaSolicitudes.cfm", "metricas.cfm", "listaTodasSolicitudes.cfm"],
            "Autorizacion": ["pase.cfm", "firmados.cfm", "listaSolicitudes.cfm", "metricas.cfm"],
            "Expediente": ["pase.cfm", "listaUsuarios.cfm", "firmados.cfm", "listaSolicitudes.cfm", "metricas.cfm"],
            "Admin": ["registrarUsuarios.cfm", "listaUsuarios.cfm", "metricas.cfm"]
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
        <link rel="icon" href="elements/icono.ico" type="image/x-icon">
        <!--- Título de la página --->
        <title>Menú Principal</title>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/menu.css">
        <link rel="stylesheet" href="css/barraSuperior.css">
        <link rel="stylesheet" href="css/botones.css">
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
        <cfset barra = createObject("component", "componentes/usuarioConectadoBarra").render()>
        <!--- Mostrar la barra --->
        <cfoutput>#barra#</cfoutput>

        <!--- Contenedor del menú --->
        <div class="menu-container">
            <!--- 1. pase.cfm --->
            <!--- Tarjeta de menú para solicitar permiso o pase de salida --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Permiso o Pase de salida</h2>
                <p>Solicitar un permiso o pase de salida</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("pase.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="solicitante/pase.cfm" class="submit-btn-menu-original">Solicitar</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Solicitar</a>
                </cfif>
            </div>

            <!--- 2. listaUsuarios.cfm --->
            <!--- Tarjeta de menú para ver la lista de usuarios --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Ver usuarios</h2>
                <p>Lista de usuarios</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaUsuarios.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="solicitante/listaUsuarios.cfm" class="submit-btn-menu-original">Ver</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Ver</a>
                </cfif>
            </div>

            <!--- 3. pendientesFirmar.cfm --->
            <!--- Tarjeta de menú para ver solicitudes pendientes de firma --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Solicitudes pendientes de firma</h2>
                <p>Revisar y firmar solicitudes pendientes</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("pendientesFirmar.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="solicitante/pendientesFirmar.cfm" class="submit-btn-menu-original">Pendientes</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Pendientes</a>
                </cfif>
            </div>

            <!--- 4. firmados.cfm --->
            <!--- Tarjeta de menú para ver solicitudes ya firmadas --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Solicitudes ya firmados</h2>
                <p>Ver solicitudes que ya han sido firmados</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("firmados.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="solicitante/firmados.cfm" class="submit-btn-menu-original">Firmados</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Firmados</a>
                </cfif>
            </div>

            <!--- 5. listaSolicitudes.cfm --->
            <!--- Tarjeta de menú para ver el pase completo --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Ver Pase Completo</h2>
                <p>Ver detalles completos de un pase</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="solicitante/listaSolicitudes.cfm" class="submit-btn-menu-original">Detalles</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Detalles</a>
                </cfif>
            </div>

            <!--- 6. metricas.cfm --->
            <!--- Tarjeta de menú para ver métricas y gráficos --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Metricas</h2>
                <p>Ver graficas</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("metricas.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="solicitante/metricas.cfm" class="submit-btn-menu-original">Detalles</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Detalles</a>
                </cfif>
            </div>

            <!--- 7. listaTodasSolicitudes.cfm --->
            <!--- Tarjeta de menú para ver todas las solicitudes --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Todas las solicitudes</h2>
                <p>Ver todos los pases solicitados</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaTodasSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="solicitante/listaTodasSolicitudes.cfm" class="submit-btn-menu-original">Detalles</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Detalles</a>
                </cfif>
            </div>
        </div>
    </body>
</html>
