<!---
 * Nombre de la pagina: application.cfc
 * 
 * Descripción:
 * Configuración del sistema de Autorización de Permisos y Pases de Salida.
 * 
 * Roles:
 * - Todos los roles definidos en el sistema.
 * 
 * Páginas Relacionadas:
 * - Todas las páginas del sistema están sujetas a esta configuración.
 * 
 * Autor: Rogelio Pérez Guevara
 * 
 * Fecha de creación: 02-10-2025
 * 
 * Versión: 1.0
--->

<!--- Configuración de la aplicación --->
<cfcomponent output="false">
    <!--- Nombre de la aplicación --->
    <cfset this.name = "Autorización de Permisos y Pases de Salida">

    <!--- Habilitar la gestión de sesiones --->
    <cfset this.sessionManagement = true>

    <!--- Tiempo de expiración de la sesión --->
    <cfset this.sessionTimeout = createTimeSpan(0,0,30,0)> <!--- 30 min --->

    <!--- Habilitar cookies para la sesión --->
    <cfset this.setClientCookies = true>

    <!--- Protección contra ataques de script --->
    <cfset this.scriptProtect = "all">

    <!--- Configuración de la cookie de sesión --->
    <cfset this.sessionCookie.httpOnly = true>

    <!---
    <!--- Se ejecuta al iniciar la aplicación --->
    <cffunction name="onApplicationStart" returnType="boolean" output="false">
        <!--- Configuración de la base de datos (DSN) --->
        <cfset application.dsn = "NombreTuODBC">
        <!--- Retorna true para indicar que la aplicación se inició correctamente --->
        <cfreturn true>
    </cffunction>
    --->

    <!--- Se ejecuta en cada request/petición --->
    <cffunction name="onRequestStart" returnType="boolean" output="false">
        <!--- Argumento que recibe la página objetivo --->
        <cfargument name="targetPage" type="string" required="true">

        <!--- Control de caché para evitar almacenamiento en el navegador --->
        <cfheader name="Cache-Control" value="no-cache, no-store, must-revalidate">
        <!--- Control de caché adicional --->
        <cfheader name="Pragma" value="no-cache">
        <!--- Expira inmediatamente --->
        <cfheader name="Expires" value="0">

        <!--- Definir páginas públicas que no requieren sesión --->
        <cfset var paginasPublicas = "login.cfm">

        <!--- Obtener el nombre de la página actual --->
        <cfset var paginaActual = listLast(arguments.targetPage, "/")>

        <!--- Si la página no está en la lista pública y no hay sesión, redirigir --->
        <cfif NOT structKeyExists(session, "usuario") 
              AND listFindNoCase(paginasPublicas, paginaActual) EQ 0>
            <cflocation url="../login.cfm" addtoken="false">
            <cfreturn false>
        </cfif>

        <cfreturn true>
    </cffunction>

    <!--- Se ejecuta al ocurrir un error en la aplicación --->
    <cffunction name="onError" returnType="void" output="true">
        <!--- Argumentos del error --->
        <cfargument name="exception" required="true">
        <cfargument name="eventname" required="true">

        <!--- Loguear el error para análisis --->
        <cflog file="Error_AppPases" type="error" text="Error: #arguments.exception.message#">
        
        <!--- Mostrar una página de error amigable --->
        <div style="text-align:center; margin-top:50px; font-family:sans-serif;">
            <h2>Ocurrió un error inesperado</h2>
            <p>Por favor intente nuevamente o contacte a soporte.</p>
            <p>By Rogelio Perez Guevara</p>
            <a href="../menu.cfm">Volver al inicio</a>
        </div>
    </cffunction>
</cfcomponent>