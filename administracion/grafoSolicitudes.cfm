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
        <title>Grafo de solicitudes</title>
        <!-- Scripts del sistema -->
        <script src="../js/jquery-3.6.0.min.js"></script>
        <script type="text/javascript" src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
        <!--- Enlace a fuentes y hojas de estilo --->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="../css/globalForm.css">
        <link rel="stylesheet" href="../css/botones.css">
        <style>
            body { 
                margin: 0; 
                padding: 0; 
                font-family: 'Inter', sans-serif; 
                background-color: #f3f4f6; 
                overflow: hidden; 
            }
        
            #mynetwork {
                width: 100vw;
                height: 100vh;
                background-color: #ffffff;
            }

            /* Panel de control flotante */
            .dashboard-panel {
                position: absolute;
                top: 20px;
                left: 20px;
                background: rgba(255, 255, 255, 0.95);
                padding: 20px;
                border-radius: 12px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.1);
                z-index: 100;
                width: 300px;
                border: 1px solid #e5e7eb;
            }

            .dashboard-panel h3 { 
                margin-top: 0; 
                color: #111827; 
                font-size: 18px; 
            }
        
            .legend-item { 
                display: flex; 
                align-items: center; 
                gap: 10px; 
                margin-bottom: 8px; 
                font-size: 13px; 
                color: #4b5563; 
            }
        
            .dot { width: 12px; height: 12px; border-radius: 50%; display: inline-block;}
            .square { width: 12px; height: 12px; border-radius: 2px; display: inline-block;}
            .line { width: 25px; height: 2px; display: inline-block; background: #ccc; }
            .line-dashed { width: 25px; height: 2px; border-bottom: 2px dashed #ccc; display: inline-block; }

            .btn-back {
                display: block;
                width: 100%;
                padding: 10px;
                margin-top: 15px;
                background: #2563eb;
                color: white;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-weight: 600;
                text-align: center;
                text-decoration: none;
            }
            .btn-back:hover { 
                background: #1d4ed8; 
            }
        
            /* Loading Spinner */
            #loading {
                position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
                font-size: 20px; color: #666; font-weight: bold;
            }
        </style>
    </head>
    <body>

        <div class="dashboard-panel">
            <h3>Red de Solicitudes</h3>
            <hr style="border:0; border-top:1px solid #eee; margin:10px 0;">
            
            <strong>Nodos</strong>
            <div class="legend-item"><div class="dot" style="background:#97C2FC; border: 2px solid #2B7CE9"></div> Solicitante</div>
            <div class="legend-item"><div class="dot" style="background:#FFD700; border: 2px solid #FF8C00"></div> Autoridad (Jefe/RH)</div>
            <div class="legend-item"><div class="square" style="background:#00cc66"></div> Solicitud Aprobada</div>
            <div class="legend-item"><div class="square" style="background:#ffaa00"></div> Solicitud Pendiente</div>
            <div class="legend-item"><div class="square" style="background:#ff4444"></div> Solicitud Rechazada</div>
            
            <strong>Conexiones</strong>
            <div class="legend-item"><div class="line" style="background:#2B7CE9"></div> Creación</div>
            <div class="legend-item"><div class="line-dashed" style="border-color:#888"></div> Firma</div>

            <div class="submit-section">
                <div class="field-group">
                    <a href="../adminPanel.cfm" class="submit-btn-menu submit-btn-menu-text">
                        Menú
                    </a>
                
                    <a href="../cerrarSesion.cfm" class="submit-btn-cerrarSesion submit-btn-cerrarSesion-text">
                        Cerrar Sesion
                    </a>
                </div>
            </div>
        </div>

        <div id="loading">Cargando datos de la BD...</div>
        <div id="mynetwork"></div>

        <script type="text/javascript">
            $(document).ready(function() {
                // Cargar datos
                $.ajax({
                    url: '../apis/obtenerGrafoSolicitudes.cfc?method=getDatosGrafo',
                    method: 'GET',
                    dataType: 'json',
                    success: function(data) {
                        $('#loading').hide();
                        drawGraph(data);
                    },
                    error: function(err) {
                        $('#loading').text("Error al cargar datos.");
                        console.error(err);
                    }
                });
            });

            function drawGraph(serverData) {
                var container = document.getElementById('mynetwork');
                
                var data = {
                    nodes: new vis.DataSet(serverData.nodes),
                    edges: new vis.DataSet(serverData.edges)
                };

                var options = {
                    nodes: {
                        borderWidth: 2,
                        shadow: true,
                        font: { size: 12, face: 'Inter' }
                    },
                    groups: {
                        usuario_solicitante: {
                            shape: 'dot', color: { background: '#97C2FC', border: '#2B7CE9' }, size: 20
                        },
                        usuario_autoridad: {
                            shape: 'dot', color: { background: '#FFD700', border: '#FF8C00' }, size: 25
                        },
                        solicitud_ok: {
                            shape: 'box', color: { background: '#00cc66', border: '#006633' }, 
                            font: { color: 'white' }, margin: 10
                        },
                        solicitud_pending: {
                            shape: 'box', color: { background: '#ffaa00', border: '#cc8800' },
                            font: { color: 'white' }, margin: 10
                        },
                        solicitud_bad: {
                            shape: 'box', color: { background: '#ff4444', border: '#990000' },
                            font: { color: 'white' }, margin: 10
                        }
                    },
                    edges: {
                        width: 2,
                        smooth: { type: 'dynamic' },
                        arrows: { to: { enabled: true, scaleFactor: 0.5 } }
                    },
                    physics: {
                        stabilization: false,
                        forceAtlas2Based: {
                            gravitationalConstant: -100,
                            centralGravity: 0.005,
                            springLength: 230,
                            springConstant: 0.18
                        },
                        maxVelocity: 146,
                        solver: 'forceAtlas2Based',
                        timestep: 0.35,
                        stabilization: { iterations: 150 }
                    },
                    interaction: { hover: true, tooltipDelay: 200 }
                };

                var network = new vis.Network(container, data, options);
                
                // Evento click para debug o acciones futuras
                network.on("click", function (params) {
                    if(params.nodes.length > 0) {
                        console.log("Nodo clickeado:", params.nodes[0]);
                    }
                });
            }
        </script>
        
        
    </body>
</html>