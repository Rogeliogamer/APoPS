<!---
 * Componente responsable de la gestión de sesiones y control de acceso.
 *
 * Funcionalidad principal:
 * - Valida si existe una sesión activa (usuario autenticado).
 * - En caso de no estar autenticado, redirige automáticamente a `login.cfm`.
 * - Excepción: `login.cfm` permanece accesible sin autenticación (página pública).
 *
 * Uso recomendado:
 * - Incluir este componente en las páginas que requieran validación de sesión.
 * - Centralizar aquí la lógica de control de acceso para evitar duplicación de código.
--->

<cfcomponent output="false">
    <!--- Configuración de la aplicación --->
    <cfset this.name = "Autorización y Pases de Salida">
    <!--- Habilitar la gestión de sesiones --->
    <cfset this.sessionManagement = true>
    <!--- Tiempo de expiración de la sesión --->
    <cfset this.sessionTimeout = createTimeSpan(0,0,30,0)> <!--- 30 min --->

    <!--- Se ejecuta en cada request/petición --->
    <cffunction name="onRequestStart" returnType="boolean" output="false">
        <!--- Argumento que recibe la página objetivo --->
        <cfargument name="targetPage" type="string" required="true">

        <!--- Evitar caché del navegador --->
        <cfheader name="Cache-Control" value="no-cache, no-store, must-revalidate">
        <cfheader name="Pragma" value="no-cache">
        <cfheader name="Expires" value="0">

        <!--- Lista de páginas públicas (no necesitan login) --->
        <cfset var paginasPublicas = "login.cfm">

        <!--- Si la página no está en la lista pública y no hay sesión, redirigir --->
        <cfif NOT structKeyExists(session, "usuario") 
              AND listFindNoCase(paginasPublicas, listLast(arguments.targetPage, "/")) EQ 0>
            <cflocation url="login.cfm" addtoken="false">
            <cfreturn false>
        </cfif>

        <cfreturn true>
    </cffunction>
</cfcomponent>