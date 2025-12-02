<cfcomponent displayName="UsuarioConectado">

    <!--- Función para generar la barra superior --->
    <cffunction name="render" access="public" returnType="string" output="false">
        <cfreturn '
        <style>
            /* CSS Específico para esta barra */
            .menu-barra-superior .contenido {
                display: flex;
                justify-content: space-between; /* Extremos separados */
                align-items: center; /* Centrado vertical */
                position: relative; /* Clave para el centrado absoluto */
                width: 100%;
                padding: 0 20px; /* Un poco de aire a los lados */
            }

            .titulo-central {
                position: absolute;
                left: 50%;
                transform: translateX(-50%); /* Truco para centrado perfecto exacto */
                font-size: 18px;
                font-weight: 700;
                color: ##ffffff; /* Color blanco (asumiendo fondo oscuro) */
                text-transform: uppercase;
                letter-spacing: 1px;
                white-space: nowrap;
            }

            /* Aseguramos que los divs laterales tengan z-index para ser clickeables */
            .info-usuario, .info-logout {
                z-index: 2;
                display: flex;
                align-items: center;
                gap: 10px;
            }
        </style>

        <div class="menu-barra-superior">
            <!-- Fondo con gradiente y burbujas animadas -->
            <div class="gradiente"></div>
            <div class="burbujas"></div>
            <!-- Contenido de la barra -->
            <div class="contenido">
                <div class="info-usuario">
                    <img src="../elements/usuario.svg" alt="Usuario" width="16" height="16">
                    <strong>' & session.usuario & '</strong> - <em>' & session.rol & '</em>
                </div>

                <div class="titulo-central">
                    Metricas Administrativas
                </div>

                <div class="info-logout">
                    <a href="cerrarSesion.cfm" class="boton-salir">
                        Cerrar Sesion <img src="../elements/salir.svg" alt="Salir" width="16" height="16">
                    </a>
                </div>
            </div>
        </div>'
    >
    </cffunction>

</cfcomponent>
