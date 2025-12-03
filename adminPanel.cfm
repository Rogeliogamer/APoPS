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
            "Admin": ["totalEstadoSolicitudes.cfm", 
                        "estadoSolicitudes.cfm",
                        "etapasFirmar.cfm",
                        "tendenciaSolicitudes.cfm",
                        "solicitudesArea.cfm",
                        "tiposPermiso.cfm",
                        "personalVSOficial.cfm",
                        "prediccion.cfm",
                        "rankingArea.cfm",
                        "topSolicitantes.cfm",
                        "grafoSolicitudes.cfm",
                        "registrarUsuarios.cfm",
                        "listaUsuariosEditar.cfm",
                        "listaUsuariosEliminar.cfm",
                        "listaUsuariosReset.cfm",
                        "agregarAreas.cfm",
                        "listaUsuarios.cfm",
                        "listaSolicitudes.cfm",
                        "listaFirmaSolicitudes.cfm",
                        "listaAreas.cfm"]
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
        <!--- Verificar si existe un usuario logeado --->
        <cfif structKeyExists(session, "rol") AND len(trim(session.usuario))>
            <!--- El usuario está logeado, puede continuar --->
        <cfelse>
            <!--- No hay sesión, redirigir al login --->
            <cflocation url="login.cfm" addtoken="no">
        </cfif>

        <!--- Incluye la barra de usuario conectado --->
        <cfset barra = createObject("component", "componentes/usuarioConectadoBarraAdmin.cfc").render()>
        <!--- Mostrar la barra --->
        <cfoutput>#barra#</cfoutput>

        <h2 style="text-align: center; margin-top: 60px; margin-bottom: 30px;">
            OPCIONES DE USUARIO
        </h2>

        <!--- Contedor del menú de CRUD --->
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

            <!--- 3. resetContraseña.cfm --->
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

        <h2 style="text-align: center; margin-top: 60px; margin-bottom: 30px;">
            OPCIONES DE AGRAGDO DE DATOS
        </h2>

        <!--- Contedor del menú de CRUD --->
        <div class="menu-container">
            <!--- 1. agregarAreas.cfm --->
            <!--- Tarjeta de menú para la lista de usuarios --->
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

        <h2 style="text-align: center; margin-top: 60px; margin-bottom: 30px;">
            OPCIONES DE LISTAS
        </h2>

        <!--- Contedor del menú de CRUD --->
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
            <!--- Tarjeta de menú para la lista de areassolicitudes --->
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

        <h2 style="text-align: center; margin-top: 60px; margin-bottom: 30px;">
            OPCIONES DE METRICAS
        </h2>

        <!--- Contenedor del menú de graficas --->
        <div class="menu-container">
            <!--- 1. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Total estado solicitudes</h2>
                <p>Tatal de aprobadas, pendientes y rechazadas</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("totalEstadoSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/totalEstadoSolicitudes.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 2. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Estado de solicitudes</h2>
                <p>Grafica del estado de la solicitud</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("estadoSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/estadoSolicitudes.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 3. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Etapas de firma</h2>
                <p>Grafica de las etapas de firma</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("etapasFirmar.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/etapasFirma.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 4. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Tendencia de solicitudes</h2>
                <p>Grafica de tendecia de solicitudes</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("tendenciaSolicitudes.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/tendenciaSolicitudes.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 5. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Solicitudes por Area</h2>
                <p>Grafica de solicitudes por area</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("solicitudesArea.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/solicitudesArea.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 6. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Tipos de Permiso</h2>
                <p>Grafica de tipos de permiso</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("tiposPermiso.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/tiposPermiso.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 7. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Personal VS Oficial</h2>
                <p>Grafica del tipo de solicitud</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("personalVSOficial.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/personalVSOficial.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 8. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Predicion</h2>
                <p>Grafica de prediccion de solicitudes</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("prediccion.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/prediccion.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 8. pagina.cfm --->
            <!--- Descripcion --->
            <div class="menu-card-graficas">
                <!--- Título y descripción --->
                <h2>Ranking area</h2>
                <p>Tabla de rankig</p>
                <!--- Verificar si el usuario tiene acceso a esta página --->
                <cfif tieneAcceso("rankingArea.cfm")>
                    <!--- Enlace habilitado --->
                    <a href="administracion/rankingArea.cfm" class="submit-btn-menu-original">Acceder</a>
                <!--- Enlace deshabilitado --->
                <cfelse>
                    <a href="##" class="disabled">Acceder</a>
                </cfif>
            </div>

            <!--- 9. pagina.cfm --->
            <!--- Descripcion --->
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

            <!--- 10. pagina.cfm --->
            <!--- Descripcion --->
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
