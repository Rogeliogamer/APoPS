<cfscript>
    /* Destruir todas las variables de sesión */
    structClear(session);

    /* Opcional: destruir la sesión completamente */
    sessionInvalidate();
</cfscript>

<!-- Redirigir al login -->
<cflocation url="login.cfm" addtoken="no">