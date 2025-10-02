<cfcomponent displayName="UsuarioConectado">

    <!--- Función para generar la barra superior --->
    <cffunction name="render" access="public" returnType="string" output="false">
        <cfreturn '
        <div class="menu-barra-superior">
            <!-- Fondo con gradiente y burbujas animadas -->
            <div class="gradiente"></div>
            <div class="burbujas"></div>
            <!-- Contenido de la barra -->
            <div class="contenido">
                <div>
                    <img src="elements/usuario.svg" alt="Usuario" width="16" height="16">
                    <strong>' & session.usuario & '</strong> - <em>' & session.rol & '</em>
                </div>
                <div>
                    <a href="cerrarSesion.cfm" class="boton-salir">
                        Salir <img src="elements/salir.svg" alt="Salir" width="16" height="16">
                    </a>
                </div>
            </div>
        </div>'
    >
    </cffunction>

</cfcomponent>
