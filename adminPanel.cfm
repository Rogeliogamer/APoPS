<!--- 
 * Nombre de la pagina: adminPanel.cfm
 * 
 * Descripción:
 * Esta pagina sirve como el panel de administración para usuarios con rol de administrador.
 * 
 *  Roles:
 * - Admin: Acceso completo a todas las funciones del sistema.
 * 
 * Páginas Relacionadas:
 * - login.cfm: Página de inicio de sesión.
 * - menu.cfm: Página principal del sistema tras el inicio de sesión.
 * - registrarUsuarios.cfm: Página para registrar nuevos usuarios.
 * - listaUsuariosEditar.cfm: Página para editar usuarios existentes.
 * - listaUsuariosEliminar.cfm: Página para eliminar usuarios.
 * - listaUsuariosReset.cfm: Página para restaurar contraseñas de usuarios.
 * - agregarAreas.cfm: Página para agregar nuevas áreas al sistema.
 * - listaUsuarios.cfm: Página para ver la lista de usuarios.
 * - listaSolicitudes.cfm: Página para ver la lista de solicitudes.
 * - listaFirmaSolicitudes.cfm: Página para ver la lista de firmas de solicitudes.
 * - listaAreas.cfm: Página para ver la lista de áreas.
 * - totalEstadoSolicitudes.cfm: Gráfica del total de estado de solicitudes.
 * - estadoSolicitudes.cfm: Gráfica del estado de solicitudes.
 * - etapasFirmar.cfm: Gráfica de las etapas de firma.
 * - tendenciaSolicitudes.cfm: Gráfica de tendencia de solicitudes.
 * - solicitudesArea.cfm: Gráfica de solicitudes por área.
 * - tiposPermiso.cfm: Gráfica de tipos de permiso.
 * - personalVSOficial.cfm: Gráfica de personal vs oficial.
 * - prediccion.cfm: Gráfica de predicción de solicitudes.
 * - rankingArea.cfm: Tabla de ranking por área.
 * - topSolicitantes.cfm: Tabla de los principales solicitantes.
 * - grafoSolicitudes.cfm: Red de nodos de solicitudes.
 * 
 * Autor: Rogelio Pérez Guevara
 * 
 * Fecha de creación: 28-11-2025
 * 
 * Versión: 1.0
--->

<!--- Función para verificar acceso basado en rol --->
<cfscript>
    <!--- Retorna true si el rol tiene acceso a la página dada --->
    function tieneAcceso(pagina) {
        <!--- Obtener el rol del usuario desde la sesión --->
        var rol = session.rol;
        <!--- Definir los accesos por rol --->
        var accesos = {
            "Admin": ["registrarUsuarios.cfm",
                        "listaUsuariosEditar.cfm",
                        "listaUsuariosEliminar.cfm",
                        "listaUsuariosReset.cfm",
                        "agregarAreas.cfm",
                        "listaUsuarios.cfm",
                        "listaSolicitudes.cfm",
                        "listaFirmaSolicitudes.cfm",
                        "listaAreas.cfm",
                        "totalEstadoSolicitudes.cfm", 
                        "estadoSolicitudes.cfm",
                        "etapasFirmar.cfm",
                        "tendenciaSolicitudes.cfm",
                        "solicitudesArea.cfm",
                        "tiposPermiso.cfm",
                        "personalVSOficial.cfm",
                        "prediccion.cfm",
                        "rankingArea.cfm",
                        "topSolicitantes.cfm",
                        "grafoSolicitudes.cfm"]
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
        <link rel="stylesheet" href="css/menu.css">
        <link rel="stylesheet" href="css/barraSuperior.css">
        <link rel="stylesheet" href="css/botones.css">
    </head>
    <body>
        <!--- Verificar si el usuario está autenticado --->
        <cfif NOT (structKeyExists(session, "rol") AND len(trim(session.usuario)))>
            <cflocation url="login.cfm" addtoken="no">
        <!--- Verificar si el rol es Admin --->
        <cfelseif listFindNoCase("Admin", session.rol) EQ 0>
            <!--- Redirigir a la página de menú si no es Admin --->
            <cflocation url="menu.cfm" addtoken="no">
        </cfif>

        <!--- Incluye la barra de usuario conectado --->
        <cfset barra = createObject("component", "componentes/usuarioConectadoBarraAdmin.cfc").render()>
        <!--- Mostrar la barra --->
        <cfoutput>#barra#</cfoutput>

        <h2 style="text-align: center; margin-top: 60px; margin-bottom: 0px;">
            OPCIONES DE USUARIO
        </h2>

        <!--- Contenedor del menú de CRUD --->
        <div class="menu-container">
            <!--- 1. registrarUsuarios.cfm --->
            <!--- Tarjeta de menú para registrar nuevos usuarios --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Registrar usuarios</h2>
                <p>Registra usuarios en el sistema</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("registrarUsuarios.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/registrarUsuarios.cfm" class="submit-btn-menu-original">Registrar</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Registrar</a>
                </cfif>
            </div>

            <!--- 2. listaUsuariosEditar.cfm --->
            <!--- Tarjeta de menú para editar usuarios --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Editar usuarios</h2>
                <p>Editar usuarios en el sistema</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaUsuariosEditar.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/listaUsuariosEditar.cfm" class="submit-btn-menu-original">Editar</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Editar</a>
                </cfif>
            </div>

            <!--- 3. listaUsuariosEliminar.cfm --->
            <!--- Tarjeta de menú para eliminar usuarios --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Eliminar usuarios</h2>
                <p>Eliminar usuarios en el sistema</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaUsuariosEliminar.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/listaUsuariosEliminar.cfm" class="submit-btn-menu-original">Eliminar</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Eliminar</a>
                </cfif>
            </div>

            <!--- 4. resetContraseña.cfm --->
            <!--- Tarjeta de menú para restaurar la contraseña del usuario --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Reset Contraseña</h2>
                <p>Restaurar la contraseña del usuario</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaUsuariosReset.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/listaUsuariosReset.cfm" class="submit-btn-menu-original">Reset</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Reset</a>
                </cfif>
            </div>
        </div>

        <h2 style="text-align: center;">
            OPCIONES DE AGREGADO DE DATOS
        </h2>

        <!--- Contenedor del menú de Datos --->
        <div class="menu-container">
            <!--- 1. agregarAreas.cfm --->
            <!--- Tarjeta de menú para agregar areas --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Agregar Areas</h2>
                <p>Registrar Areas al sistema</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("agregarAreas.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/agregarAreas.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>
        </div>

        <h2 style="text-align: center;">
            OPCIONES DE LISTAS
        </h2>

        <!--- Contenedor del menú de Listas --->
        <div class="menu-container">
            <!--- 1. listaUsuarios.cfm --->
            <!--- Tarjeta de menú para la lista de usuarios --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Lista Usuarios</h2>
                <p>Lista de Usuarios</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaUsuarios.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/listaUsuarios.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 2. listaSolicitudes.cfm --->
            <!--- Tarjeta de menú para la lista de solicitudes --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Lista Solicitudes</h2>
                <p>Lista de Solicitudes</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/listaSolicitudes.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 3. listaFirmasSolicitudes.cfm --->
            <!--- Tarjeta de menú para la lista de firmas de solicitudes --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Lista Firmas</h2>
                <p>Lista de Firmas de Solicitudes</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaFirmaSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/listaFirmaSolicitudes.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 4. listaAreas.cfm --->
            <!--- Tarjeta de menú para la lista de areas --->
            <div class="menu-card">
                <!--- Título y descripción --->
                <h2>Lista Areas</h2>
                <p>Lista de Areas</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("listaAreas.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/listaAreas.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>
        </div>

        <h2 style="text-align: center;">
            OPCIONES DE METRICAS
        </h2>

        <!--- Contenedor del menú de metricas --->
        <div class="menu-container">
            <!--- 1. totalEstadoSolicitudes.cfm.cfm --->
            <!--- Gráfica de total de solicitudes como el status --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Total estado solicitudes</h2>
                <p>Total de aprobadas, pendientes y rechazadas</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("totalEstadoSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/totalEstadoSolicitudes.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 2. estadoSolicitudes.cfm --->
            <!--- Gráfica del estado de las solicitudes --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Estado de solicitudes</h2>
                <p>Gráfica del estado de la solicitud</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("estadoSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/estadoSolicitudes.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 3. etapasFirmar.cfm --->
            <!--- Gráfica de las etapas de firma de la solicitudes --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Etapas de firma</h2>
                <p>Gráfica de las etapas de firma</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("etapasFirmar.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/etapasFirma.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 4. tendenciaSolicitudes.cfm --->
            <!--- Gráfica de tendencia de solicitudes --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Tendencia de solicitudes</h2>
                <p>Gráfica de tendencia de solicitudes</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("tendenciaSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/tendenciaSolicitudes.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 5. solicitudesArea.cfm --->
            <!--- Gráfica de solicitudes por area --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Solicitudes por Area</h2>
                <p>Gráfica de solicitudes por area</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("solicitudesArea.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/solicitudesArea.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 6. tiposPermiso.cfm --->
            <!--- Gráfica de tipos de permiso --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Tipos de Permiso</h2>
                <p>Gráfica de tipos de permiso</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("tiposPermiso.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/tiposPermiso.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 7. personalVSOficial.cfm --->
            <!--- Gráfica de tipo de solicitudes --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Personal VS Oficial</h2>
                <p>Gráfica del tipo de solicitud</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("personalVSOficial.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/personalVSOficial.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 8. prediccion.cfm --->
            <!--- Gráfica de prediccion --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Perdición</h2>
                <p>Gráfica de predicción de solicitudes</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("prediccion.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/prediccion.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 8. rankingArea.cfm --->
            <!--- Tabla de ranking de areas --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Ranking area</h2>
                <p>Tabla de ranking</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("rankingArea.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/rankingArea.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 9. topSolicitantes.cfm --->
            <!--- Tabla del top de solicitantes --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Top Solicitantes</h2>
                <p>Tabla del top solicitantes</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("topSolicitantes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/topSolicitantes.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 10. grafoSolicitudes.cfm --->
            <!--- Grafo de nodos de las solicitudes --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Red de solicitudes</h2>
                <p>Grafo de las solicitudes</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("grafoSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/grafoSolicitudes.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>
        </div>
    </body>
</html>
