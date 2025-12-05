<!---
 * Nombre de la pagina: cerrarsesion.cfm
 * 
 * Descripción:
 * Página para cerrar la sesión del usuario actual.
 * Destruye todas las variables de sesión y redirige al usuario a la página de inicio de sesión.
 * 
 * Roles:
 * - Todos los roles pueden acceder a esta página para cerrar su sesión.
 * 
 * Páginas Relacionadas:
 * - `login.cfm`: Página de inicio de sesión a la que se redirige después de cerrar sesión.
 * 
 * Autor: Rogelio Pérez Guevara
 * 
 * Fecha de creación: 02-10-2025
 * 
 * Versión: 1.0
--->

<cfscript>
    /* Destruir todas las variables de sesión */
    structClear(session);

    /* Opcional: destruir la sesión completamente */
    sessionInvalidate();
</cfscript>

<!-- Redirigir al login -->
<cflocation url="login.cfm" addtoken="no">