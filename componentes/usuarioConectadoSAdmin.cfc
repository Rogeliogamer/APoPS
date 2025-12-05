<!---
 * Nombre del componente: componentes/usuarioConectadoSAdmin.cfc
 * 
 * Descripción:
 * Este componente genera la sección que muestra la información del usuario conectado en el panel de superadministrador.
 * Incluye el nombre de usuario y rol.
 * 
 * Roles:
 * Ninguno específico, accesible para cualquier usuario autenticado.
 * 
 * Autor: Rogelio Perez Guevara
 * 
 * Fecha de creación: 01-12-2025
 * 
 * Versión: 1.0
--->

<cfcomponent displayName="UsuarioConectado">
    
    <cffunction name="render" access="public" returnType="string" output="false">
        <cfreturn '
            <img src="../elements/usuario.svg" alt="Usuario" width="16" height="16">
            <strong>' & session.usuario & '</strong> - <em>' & session.rol & '</em>  
        '>
    </cffunction>

</cfcomponent>
