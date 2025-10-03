<cfcomponent displayName="UsuarioConectado">
    
    <cffunction name="render" access="public" returnType="string" output="false">
        <cfreturn '
            <img src="elements/usuario.svg" alt="Usuario" width="16" height="16">
            <strong>' & session.usuario & '</strong> - <em>' & session.rol & '</em>  
        '>
    </cffunction>

</cfcomponent>
