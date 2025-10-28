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
<cfscript>
    function tieneAcceso(pagina) {
        var rol = session.rol;
        var accesos = {
            "Solicitante": ["pase.cfm", "firmados.cfm", "listaSolicitudes.cfm", "metricas.cfm"],
            "Jefe": ["pase.cfm", "listaUsuarios.cfm", "pendientes_firmar.cfm", "firmados.cfm", "listaSolicitudes.cfm", "metricas.cfm"],
            "RecursosHumanos": ["pase.cfm", "listaUsuarios.cfm", "pendientes_firmar.cfm", "firmados.cfm", "listaSolicitudes.cfm", "metricas.cfm"],
            "Autorizacion": ["pase.cfm", "pendientes_firmar.cfm", "firmados.cfm", "listaSolicitudes.cfm", "metricas.cfm"],
            "Expediente": ["pase.cfm", "listaUsuarios.cfm", "pendientes_firmar.cfm", "firmados.cfm", "listaSolicitudes.cfm", "metricas.cfm"],
            "Admin": ["registrarUsuarios.cfm", "listaUsuarios.cfm", "metricas.cfm"]
        };

        // Validar si el rol existe en el struct
        if (structKeyExists(accesos, rol)) {
            return arrayFind(accesos[rol], pagina) > 0;
        } else {
            return false;
        }
    }
</cfscript>

<!DOCTYPE html>
<html lang="es">
    <head>
        <!-- Metadatos y enlaces a estilos -->
        <meta charset="UTF-8">
        <!-- Vista adaptable para dispositivos móviles -->
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Título de la página -->
        <title>Menú Principal</title>
        <!-- Enlace a fuentes y hojas de estilo -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/menu.css">
        <link rel="stylesheet" href="css/barraSuperior.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!--- barra superior --->
        <cfset barra = createObject("component", "componentes/usuarioConectadoBarra").render()>
        <cfoutput>#barra#</cfoutput>
        
        <div class="menu-container">
            <!-- 1. pase.cfm -->
            <div class="menu-card">
                <h2>Permiso o Pase de salida</h2>
                <p>Solicitar un permiso o pase de salida</p>
                <cfif tieneAcceso("pase.cfm")>
                    <a href="pase.cfm" class="submit-btn-menu-original">Solicitar</a>
                <cfelse>
                    <a href="##" class="disabled">Solicitar</a>
                </cfif>
            </div>

            <!-- 2. registrarUsuarios.cfm -->
            <div class="menu-card">
                <h2>Registrar usuarios</h2>
                <p>Registra usuarios en el sistema</p>
                <cfif tieneAcceso("registrarUsuarios.cfm")>
                    <a href="registrarUsuarios.cfm" class="submit-btn-menu-original">Registrar</a>
                <cfelse>
                    <a href="##" class="disabled">Registrar</a>
                </cfif>
            </div>

            <!-- 3. listaUsuarios.cfm -->
            <div class="menu-card">
                <h2>Ver usuarios</h2>
                <p>Lista de usuarios</p>
                <cfif tieneAcceso("listaUsuarios.cfm")>
                    <a href="listaUsuarios.cfm" class="submit-btn-menu-original">Ver</a>
                <cfelse>
                    <a href="##" class="disabled">Ver</a>
                </cfif>
            </div>

            <!-- 4. pendientes_firmar.cfm -->
            <div class="menu-card">
                <h2>Solicitudes pendientes de firma</h2>
                <p>Revisar y firmar solicitudes pendientes</p>
                <cfif tieneAcceso("pendientesfirmar.cfm")>
                    <a href="pendientesFirmar.cfm" class="submit-btn-menu-original">Pendientes</a>
                <cfelse>
                    <a href="##" class="disabled">Pendientes</a>
                </cfif>
            </div>

            <!-- 5. firmados.cfm -->
            <div class="menu-card">
                <h2>Solicitudes ya firmados</h2>
                <p>Ver solicitudes que ya han sido firmados</p>
                <cfif tieneAcceso("firmados.cfm")>
                    <a href="firmados.cfm" class="submit-btn-menu-original">Firmados</a>
                <cfelse>
                    <a href="##" class="disabled">Firmados</a>
                </cfif>
            </div>

            <!-- 6. listaSolicitudes.cfm -->
            <div class="menu-card">
                <h2>Ver Pase Completo</h2>
                <p>Ver detalles completos de un pase</p>
                <cfif tieneAcceso("listaSolicitudes.cfm")>
                    <a href="listaSolicitudes.cfm" class="submit-btn-menu-original">Detalles</a>
                <cfelse>
                    <a href="##" class="disabled">Detalles</a>
                </cfif>
            </div>

            <!-- 7. metricas.cfm -->
            <div class="menu-card">
                <h2>Metricas</h2>
                <p>Ver graficas</p>
                <cfif tieneAcceso("metricas.cfm")>
                    <a href="metricas.cfm" class="submit-btn-menu-original">Detalles</a>
                <cfelse>
                    <a href="##" class="disabled">Detalles</a>
                </cfif>
            </div>
        </div>
    </body>
</html>
