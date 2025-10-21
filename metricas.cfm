<!---
 * Dashboard Integral para Sistema de Permisos
 * Integra datos reales desde getDashboardData.cfm
--->

<!--- Verificación de sesión --->
<cfif NOT structKeyExists(session, "rol")>
    <cflocation url="index.cfm" addtoken="no">
</cfif>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dashboard - Sistema de Permisos</title>

        <!-- Carga de jQuery (local) -->
        <script src="js/jquery-3.6.0.min.js"></script>

        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        
        <link rel="stylesheet" href="css/globalForm.css">
        <link rel="stylesheet" href="css/botones.css">
<link rel="stylesheet" href="css/temp.css">
        <style>
            /* Extensiones específicas para Dashboard */
            .kpi-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                margin-bottom: 25px;
            }

            .kpi-card {
                background: #ebebeb;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px rgba(0,0,0,0.15);
            }

            .kpi-header {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-totalSolicitudes {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-totalSolicitudes:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px #2B6CB0;
            }

            /* Cambia el color de los textos internos al hacer hover en el header */
            .kpi-header-totalSolicitudes:hover .kpi-title,
            .kpi-header-totalSolicitudes:hover .kpi-value,
            .kpi-header-totalSolicitudes:hover .kpi-subtitle {
                color: #2B6CB0; /* Azul principal */
                transition: color 0.3s ease;
                font-weight: 700;
            }

            .kpi-header-aprovadas {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-aprovadas:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px #2F855A;
            }

            /* Cambia el color de los textos internos al hacer hover en el header */
            .kpi-header-aprovadas:hover .kpi-title,
            .kpi-header-aprovadas:hover .kpi-value,
            .kpi-header-aprovadas:hover .kpi-subtitle {
                color: #2F855A; /* Azul principal */
                transition: color 0.3s ease;
                font-weight: 700;
            }

            .kpi-header-pendientes {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-pendientes:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px #D69E2E;
            }

            /* Cambia el color de los textos internos al hacer hover en el header */
            .kpi-header-pendientes:hover .kpi-title,
            .kpi-header-pendientes:hover .kpi-value,
            .kpi-header-pendientes:hover .kpi-subtitle {
                color: #D69E2E; /* Azul principal */
                transition: color 0.3s ease;
                font-weight: 700;
            }

            .kpi-header-rechazadas {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-rechazadas:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px #C53030;
            }

            /* Cambia el color de los textos internos al hacer hover en el header */
            .kpi-header-rechazadas:hover .kpi-title,
            .kpi-header-rechazadas:hover .kpi-value,
            .kpi-header-rechazadas:hover .kpi-subtitle {
                color: #C53030; /* Azul principal */
                transition: color 0.3s ease;
                font-weight: 700;
            }

            .kpi-header-tiempoPromedio {
                background: #ffffff;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: transform 0.3s;
            }

            .kpi-header-tiempoPromedio:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px #6B46C1;
            }

            /* Cambia el color de los textos internos al hacer hover en el header */
            .kpi-header-tiempoPromedio:hover .kpi-title,
            .kpi-header-tiempoPromedio:hover .kpi-value,
            .kpi-header-tiempoPromedio:hover .kpi-subtitle {
                color: #6B46C1; /* Azul principal */
                transition: color 0.3s ease;
                font-weight: 700;
            }

            .kpi-title { font-size: 14px; color: #4a5568; margin-bottom: 8px; }
            .kpi-value { font-size: 28px; font-weight: 700; color: #2d3748; }
            .kpi-subtitle { font-size: 12px; color: #718096; margin-top: 5px; }

            .charts-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
                gap: 20px;
                margin-bottom: 25px;
            }

            .chart-card {
                background: #ebebeb;
                padding: 25px;
                border-radius: 25px;                
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            }

            .chart-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 30px rgba(0,0,0,0.15);
            }

            .chart-title {
                font-size: 16px;
                font-weight: 600;
                color: #2d3748;
                margin-bottom: 15px;
            }

            .table-container { overflow-x: auto; margin-top: 10px; }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            th {
                background: #f8fafc;
                padding: 12px;
                font-weight: 600;
                border-bottom: 2px solid #e2e8f0;
                text-align: left;
            }

            td {
                padding: 12px;
                border-bottom: 1px solid #e2e8f0;
            }

            .loading-overlay {
                display: none;
                position: fixed;
                top:0; left:0;
                width:100%; height:100%;
                background: rgba(0,0,0,0.5);
                z-index: 9999;
                justify-content: center;
                align-items: center;
            }

            .loading-overlay.active { display:flex; }

            .spinner {
                width:50px; height:50px;
                border:5px solid #f3f3f3;
                border-top:5px solid #667eea;
                border-radius:50%;
                animation: spin 1s linear infinite;
            }

            @keyframes spin { 0%{transform:rotate(0deg);} 100%{transform:rotate(360deg);} }
        </style>
    </head>
    <body>
            <div class="loading-overlay" id="loadingOverlay">
                <div class="spinner"></div>
            </div>

            <div class="container">
                <div class="header">
                    <div class="logo">
                        <cfset usuarioRol = createObject("component", "componentes/usuarioConectadoS").render()>
                        <cfoutput>#usuarioRol#</cfoutput>
                    </div>
                    <h1>📊 Metricas de Permisos y Pases de Salida</h1>
                </div>

                <!-- Filtros -->
                <div class="form-container">
                    <div class="section">
                        <div class="field-group single">
                            <div class="section-title">
                                Rango de Fechas
                            </div>
                            <select class="form-input-general" id="rangoFechas">
                                <option value="30" selected>Últimos 30 días</option>
                                <option value="60">Últimos 60 días</option>
                                <option value="90">Últimos 90 días</option>
                            </select>

                            <div class="section-title">
                                Área
                            </div>

                            <!--- Select dinámico --->
                            <select class="form-input-general" id="areaSeleccionada">
                                <!--- Opción para todas las áreas --->
                                <option value="">-- Seleciona un área --</option>
                                
                                <!--- Consultar todas las áreas --->
                                <cfquery name="getAreas" datasource="Autorizacion">
                                    SELECT id_area, nombre
                                    FROM area_adscripcion
                                </cfquery>

                                <!--- Iterar sobre la consulta --->
                                <cfoutput query="getAreas">
                                    <option value="#id_area#">#nombre#</option>
                                </cfoutput>
                            </select>
                        </div>
                        <div class="submit-section">
                            <button class="submit-btn-actualizar" id="btnActualizar">
                                🔍 Actualizar
                            </button>
                        </div>
                    </div>   
                    
                    <!-- KPIs -->
                    <div class="section">
                        <div class="field-group">
                            <div class="kpi-header-totalSolicitudes">
                                <div class="kpi-title">Total Solicitudes</div>
                                <div class="kpi-value" id="totalSolicitudes">0</div>
                                <div class="kpi-subtitle">Este período</div>
                            </div>

                            <div class="kpi-header-aprovadas">
                                <div class="kpi-title">Aprobadas</div>
                                <div class="kpi-value" id="solicitudesAprobadas">0</div>
                                <div class="kpi-subtitle" id="solicitudesAprobadasPct">0% de aprobación</div>
                            </div>

                            <div class="kpi-header-pendientes">
                                <div class="kpi-title">Pendientes</div>
                                <div class="kpi-value" id="solicitudesPendientes">0</div>
                                <div class="kpi-subtitle" id="solicitudesPendientesPct">0% de aprobación</div>
                            </div>

                            <div class="kpi-header-rechazadas">
                                <div class="kpi-title">Rechazadas</div>
                                <div class="kpi-value" id="solicitudesRechazadas">0</div>
                                <div class="kpi-subtitle" id="solicitudesRechazadasPct">0% de rechazo</div>
                            </div>

                            <div class="kpi-header-tiempoPromedio">
                                <div class="kpi-title">Tiempo Promedio</div>
                                <div class="kpi-value" id="tiempoPromedio">0 días</div>
                                <div class="kpi-subtitle">Hasta aprobación final</div>
                            </div>
                        </div>
                    </div>

                    <!-- KPI Cards -->
                    <div class="section">
                        <div class="field-group">
                            <div class="kpi-header">
                                <div class="chart-title">Estado de solicitudes</div>
                                <canvas id="chartEstados" height="250"></canvas>

                                <!-- Overlay solo para este canvas -->
                                <div class="canvasOverlay">
                                    ¡A punto de revelar las estadísticas!
                                </div>
                            </div>

                            <div class="kpi-header">
                                <div class="chart-title">Por Etapa de Firma</div>
                                <canvas id="chartEtapas" height="250"></canvas>
                                <!-- Overlay solo para este canvas -->
                                <div class="canvasOverlay">
                                    ¡A punto de revelar las estadísticas!
                                </div>
                            </div>
                            
                            <div class="kpi-header">
                                <div class="chart-title">Tendencia de Solicitudes (Por periodo)</div>
                                <canvas id="chartTendencia" height="250"></canvas>
                                <!-- Overlay solo para este canvas -->
                                <div class="canvasOverlay">
                                    ¡A punto de revelar las estadísticas!
                                </div>
                            </div>

                            <div class="kpi-header">
                                <div class="chart-title">Solicitudes por Área sleccionada</div>
                                <canvas id="chartAreas" height="250"></canvas>
                                <!-- Overlay solo para este canvas -->
                                <div class="canvasOverlay">
                                    ¡A punto de revelar las estadísticas!
                                </div>
                            </div>

                            <div class="kpi-header">
                                <div class="chart-title">Tipos de Permiso por Área selecionada</div>
                                <canvas id="chartTipoPermiso" height="250"></canvas>
                                <!-- Overlay solo para este canvas -->
                                <div class="canvasOverlay">
                                    ¡A punto de revelar las estadísticas!
                                </div>
                            </div>

                            <div class="kpi-header">
                                <div class="chart-title">Personal vs Oficial por Area Seleccionada</div>
                                <canvas id="chartTipoSolicitud" height="250"></canvas>
                                <!-- Overlay solo para este canvas -->
                                <div class="canvasOverlay">
                                    ¡A punto de revelar las estadísticas!
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- prediccion a futuro -->
                    <div class="section">
                        
                            <div class="kpi-header">
                                <div class="chart-title">Predicion a 7 dias por area selecionada</div>
                                <canvas id="chartPredicion" height="250"></canvas>
                                <!-- Overlay solo para este canvas -->
                                <div class="canvasOverlay">
                                    ¡A punto de revelar las estadísticas!
                                </div>
                            </div>
                        
                    </div>

                    <!-- Tablas -->
                    <div class="section">
                        <div class="field-group">
                            <div class="kpi-header">
                                <div class="chart-title">Ranking por Área</div>
                                <div class="table-container">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Área</th>
                                                <th>Total</th>
                                                <th>Aprobadas</th>
                                                <th>Rechazadas</th>
                                                <th>Pendientes</th>
                                                <th>Tasa Aprobación</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tablaAreasBody">
    <cfif NOT structKeyExists(variables, "rankingAreas") OR rankingAreas.recordCount EQ 0>
        <tr>
            <td colspan="6" style="text-align:center;">No hay datos disponibles para el periodo seleccionado</td>
        </tr>
    <cfelse>
        <cfoutput query="rankingAreas">
            <tr
                <cfif rankingAreas.id_area EQ val(form.areaSeleccionada)>
                    style="font-weight:bold; background-color:##1b263b; color:white;"
                </cfif>
            >
                <td>#area#</td>
                <td>#total_solicitudes#</td>
                <td>#aprobadas#</td>
                <td>#rechazadas#</td>
                <td>#pendientes#</td>
                <td>#tasa_aprobacion#%</td>
            </tr>
        </cfoutput>
    </cfif>
</tbody>

                                    </table>
                                </div>
                            </div>

                            <div class="kpi-header">
                                <div class="chart-title">Top 10 Solicitantes por area selecionada</div>
                                    <div class="table-container">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>Firmante</th>
                                                    <th>Rol</th>
                                                    <th>Aprovadas</th>
                                                    <th>Rechazadas</th>
                                                    <th>Pendientes</th>
                                                </tr>
                                            </thead>
                                            <tbody id="tablaFirmantesBody">
                                                <tr><td colspan="5" style="text-align: center;>Cargando...</td></tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div> 
            </div>
        </div>

        
        <!--- Carga de jQuery (local o CDN) --->
        <script src="js/jquery-3.6.0.min.js"></script>
        
<script>
    $('#btnActualizar').click(function() {
    // Oculta todos los overlays
    $('.canvasOverlay').fadeOut(300);

    // Aquí tu lógica AJAX para actualizar gráficos
    let rangoDias = $('#rangoFechas').val();
    let areaId = $('#areaSeleccionada').val();

    $.ajax({
        url: 'prediccion.cfc?method=getPrediccion',
        type: 'GET',
        data: { rangoDias: rangoDias, areaId: areaId },
        dataType: 'json',
        success: function(response) {
            let data = (typeof response === 'string') ? JSON.parse(response) : response;
            renderAdvancedChart(data); // tu función de gráficas
        },
        error: function(err) {
            console.error('Error al obtener predicción', err);
        }
    });
});


</script>
        
        <script>
            $(document).ready(function(){

                // Función para actualizar las métricas
                function actualizarMetricas(){
                    let dias = $("#rangoFechas").val();
                    let area = $("#areaSeleccionada").val();

                    if(area === ""){
                        alert("Por favor selecciona un área.");
                        return;
                    }

                    $("#loadingOverlay").addClass("active");

                    $.ajax({
                        url: "obtenerMetricas.cfm",
                        method: "POST",
                        data: { rango: dias, area: area },
                        dataType: "json",
                        success: function(response){
                            // Total de solicitudes
                            $("#totalSolicitudes").text(response.totalSolicitudes);

                            // Aprobadas
                            $("#solicitudesAprobadas").text(response.solicitudesAprobadas);
                            $("#solicitudesAprobadasPct").text(response.porcentajeAprobadas.toFixed(1) + "% de aprobación");

                            // Pendientes
                            $("#solicitudesPendientes").text(response.solicitudesPendientes);
                            $("#solicitudesPendientesPct").text(response.porcentajePendientes.toFixed(1) + "% de aprobación");

                            // Rechazadas
                            $("#solicitudesRechazadas").text(response.solicitudesRechazadas);
                            $("#solicitudesRechazadasPct").text(response.porcentajeRechazadas.toFixed(1) + "% de rechazo");

                            // Tiempo promedio
                            $("#tiempoPromedio").text(response.tiempoPromedio + " días");
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false
                        }
                        error: function(xhr, status, error){
                            console.error("Error al obtener métricas:", error);
                            alert("Hubo un error al cargar las métricas.");
                        },
                        complete: function(){
                            $("#loadingOverlay").removeClass("active");
                        }
                    });
                }

                // Evento del botón
                $("#btnActualizar").click(function(){
                    actualizarMetricas();
                });

                // Opcional: cargar métricas automáticamente al cargar la página
                // actualizarMetricas();
            });
        </script>

        <script>
            $(document).ready(function(){

                let chartEstados; // Variable global para mantener la referencia de la gráfica

                function actualizarGraficaEstados(area, dias){
                    $.ajax({
                        url: "obtenerMetricas.cfm",
                        method: "POST",
                        data: { rango: dias, area: area },
                        dataType: "json",
                        success: function(response){
                
                            // Datos para el pie chart usando status_final
                            const data = {
                                labels: ['Aprobadas', 'Pendientes', 'Rechazadas'],
                                datasets: [{
                                    label: 'Estado de solicitudes',
                                    data: [
                                        response.solicitudesAprobadas,
                                        response.solicitudesPendientes,
                                        response.solicitudesRechazadas
                                    ],
                                    backgroundColor: [
                                        '#2F855A', // Verde
                                        '#D69E2E', // Amarillo
                                        '#C53030'  // Rojo
                                    ],
                                    borderWidth: 1
                                }]
                            };

                            const config = {
                                type: 'pie',
                                data: data,
                                options: {
                                    responsive: true,
                                    plugins: {
                                        legend: {
                                            position: 'bottom',
                                        },
                                        tooltip: {
                                            callbacks: {
                                                label: function(context){
                                                    let total = context.dataset.data.reduce((a,b)=>a+b,0);
                                                    let value = context.raw;
                                                    let pct = total ? ((value/total)*100).toFixed(1) : 0;
                                                    return `${context.label}: ${value} (${pct}%)`;
                                                }
                                            }
                                        }
                                    }
                                }
                            };

                            // Si la gráfica ya existe, destrúyela antes de crear una nueva
                            if(chartEstados) chartEstados.destroy();

                            chartEstados = new Chart(
                                document.getElementById('chartEstados'),
                                config
                            );
                        },
                        error: function(xhr, status, error){
                            console.error("Error al obtener datos para la gráfica:", error);
                        }
                    });
                }

                // Llamar la función al dar click en actualizar
                $("#btnActualizar").click(function(){
                    let dias = $("#rangoFechas").val();
                    let area = $("#areaSeleccionada").val();
                    if(area === ""){
                        alert("Por favor selecciona un área.");
                        return;
                    }
                    actualizarGraficaEstados(area, dias);
                });

                // Opcional: generar gráfico al cargar la página con valores por defecto
                // actualizarGraficaEstados($("#areaSeleccionada").val(), $("#rangoFechas").val());

            });
        </script>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
var chartTendencia; // Variable global para la gráfica

function actualizarTendencia() {
    var rango = $("#rangoFechas").val();
    var area = $("#areaSeleccionada").val();

    // Solo continuar si el usuario seleccionó un área
    if(area === "") {
        alert("Por favor selecciona un área para mostrar la gráfica.");
        return;
    }

    $.ajax({
        url: "obtenerTendencia.cfm",
        method: "POST",
        data: { rango: rango, area: area },
        dataType: "json",
        success: function(response) {
            var labels = [];
            var aprobadas = [];
            var pendientes = [];
            var rechazadas = [];

            response.tendencia.forEach(function(item) {
                // Convertir fecha a formato legible si quieres
                labels.push(item.fecha);
                aprobadas.push(item.aprobadas);
                pendientes.push(item.pendientes);
                rechazadas.push(item.rechazadas);
            });

            // Si ya existe la gráfica, la destruimos antes de crear una nueva
            if(chartTendencia) {
                chartTendencia.destroy();
            }

            var ctx = document.getElementById("chartTendencia").getContext("2d");
            chartTendencia = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: 'Aprobadas',
                            data: aprobadas,
                            borderColor: 'green',
                            backgroundColor: 'rgba(0,128,0,0.1)',
                            fill: true,
                            tension: 0.3
                        },
                        {
                            label: 'Pendientes',
                            data: pendientes,
                            borderColor: 'orange',
                            backgroundColor: 'rgba(255,165,0,0.1)',
                            fill: true,
                            tension: 0.3
                        },
                        {
                            label: 'Rechazadas',
                            data: rechazadas,
                            borderColor: 'red',
                            backgroundColor: 'rgba(255,0,0,0.1)',
                            fill: true,
                            tension: 0.3
                        }
                    ]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        tooltip: {
                            mode: 'index',
                            intersect: false,
                        }
                    },
                    interaction: {
                        mode: 'nearest',
                        intersect: false
                    },
                    scales: {
                        x: {
                            title: {
                                display: true,
                                text: 'Fecha'
                            }
                        },
                        y: {
                            title: {
                                display: true,
                                text: 'Cantidad de solicitudes'
                            },
                            beginAtZero: true,
                            precision: 0
                        }
                    }
                }
            });
        },
        error: function(err) {
            console.error("Error al obtener la tendencia:", err);
        }
    });
}

// Evento click del botón
$("#btnActualizar").click(function(e){
    e.preventDefault();
    actualizarTendencia();
});
</script>

<script>
// Variable global para la gráfica
let chartFirmantes = null;

$(document).ready(function() {
    $("#btnActualizar").click(function() {
        const areaSeleccionada = $("#areaSeleccionada").val();

        if (!areaSeleccionada) {
            alert("Selecciona un área primero.");
            return;
        }

        $.ajax({
            url: "obtenerFirmantes.cfm",
            method: "POST",
            data: { area: areaSeleccionada },
            dataType: "json",
            success: function(response) {
                if (!response.firmantes || response.firmantes.length === 0) {
                    alert("No hay datos de firmantes para el área seleccionada.");
                    // Limpiar gráfica anterior si existe
                    if (chartFirmantes) {
                        chartFirmantes.destroy();
                        chartFirmantes = null;
                    }
                    return;
                }

                // Preparar datos
                const labels = response.firmantes.map(f => f.nombre);
                const aprobadas = response.firmantes.map(f => f.aprobadas);
                const pendientes = response.firmantes.map(f => f.pendientes);
                const rechazadas = response.firmantes.map(f => f.rechazadas);

                // Si la gráfica ya existe, destruirla antes de crear otra
                if (chartFirmantes) {
                    chartFirmantes.destroy();
                }

                const ctx = document.getElementById("chartAreas").getContext("2d");
                chartFirmantes = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [
                            {
                                label: 'Aprobadas',
                                data: aprobadas,
                                backgroundColor: 'rgba(75, 192, 192, 0.7)'
                            },
                            {
                                label: 'Pendientes',
                                data: pendientes,
                                backgroundColor: 'rgba(255, 206, 86, 0.7)'
                            },
                            {
                                label: 'Rechazadas',
                                data: rechazadas,
                                backgroundColor: 'rgba(255, 99, 132, 0.7)'
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            legend: {
                                position: 'top',
                            },
                            title: {
                                display: true,
                                text: 'Solicitudes por Firmante'
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                title: {
                                    display: true,
                                    text: 'Cantidad de Solicitudes'
                                }
                            },
                            x: {
                                title: {
                                    display: true,
                                    text: 'Firmantes'
                                }
                            }
                        }
                    }
                });
            },
            error: function(err) {
                console.error("Error al obtener datos de firmantes:", err);
                alert("Hubo un error al cargar los datos de firmantes.");
            }
        });
    });
});
</script>

<script>
document.getElementById("btnActualizar").addEventListener("click", function () {
    const idArea = document.getElementById("areaSeleccionada").value;
    const rangoDias = document.getElementById("rangoFechas").value;

    if (!idArea) {
        alert("Por favor selecciona un área.");
        return;
    }

    // Llamada AJAX a obtener_tipos_permiso.cfm
    fetch(`obtenerTiposPermiso.cfm?id_area=${idArea}&rangoDias=${rangoDias}`)
        .then(response => response.json())
        .then(data => {
            console.log("Respuesta de permisos:", data);

            const ctx = document.getElementById("chartTipoPermiso").getContext("2d");

            // Si existe una gráfica previa, destruirla
            if (window.graficoTipoPermiso) {
                window.graficoTipoPermiso.destroy();
            }

            // Validar si hay datos
            if (!data.tiposPermiso || data.tiposPermiso.length === 0) {
                ctx.font = "16px Arial";
                ctx.fillText("No hay datos disponibles para el área seleccionada.", 50, 100);
                return;
            }

            // Preparar datos para la gráfica
            const labels = data.tiposPermiso.map(item => item.tipo_permiso);
            const valores = data.tiposPermiso.map(item => item.cantidad);

            // Crear gráfica
            window.graficoTipoPermiso = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Cantidad de Solicitudes',
                        data: valores,
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { display: true },
                        title: {
                            display: true,
                            text: 'Tipos de Permiso por Área Seleccionada'
                        }
                    },
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });
        })
        .catch(err => {
            console.error("Error al obtener los tipos de permiso:", err);
        });
});
</script>

<script>
$('#btnActualizar').on('click', function(e) {
    e.preventDefault();

    const rango = $('#rangoFechas').val();
    const area = $('#areaSeleccionada').val();

    $.ajax({
        url: 'obtenerTipoSolicitud.cfm',
        method: 'GET',
        data: { rango: rango, area: area },
        dataType: 'json',
        success: function(response) {
            console.log("Datos recibidos:", response);

            const labels = response.TIPOSSOLICITUD.map(item => item.TIPO);
            const cantidades = response.TIPOSSOLICITUD.map(item => item.CANTIDAD);

            if (labels.length === 0) {
                $('#chartTipoSolicitud').hide();
                $('#chartTipoSolicitud').after('<div>No hay datos disponibles para el área seleccionada.</div>');
                return;
            }

            $('#chartTipoSolicitud').show();
            // Limpiar canvas anterior si existe
            if (window.tipoSolicitudChart) {
                window.tipoSolicitudChart.destroy();
            }

            const ctx = document.getElementById('chartTipoSolicitud').getContext('2d');
            window.tipoSolicitudChart = new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: labels,
                    datasets: [{
                        data: cantidades,
                        backgroundColor: ['#36A2EB', '#FF6384'],
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { position: 'bottom' }
                    }
                }
            });
        },
        error: function(err) {
            console.error(err);
            alert("Ocurrió un error al cargar la gráfica.");
        }
    });
});

</script>

<script>
    $('#btnActualizar').on('click', function(e) {
    e.preventDefault();

    const rango = $('#rangoFechas').val();
    const area = $('#areaSeleccionada').val();

    // --- Graficar Etapas de Firma ---
    $.ajax({
        url: 'obtenerFirmasPorRol.cfm',
        method: 'GET',
        data: { rango: rango, area: area },
        dataType: 'json',
        success: function(response) {
            console.log("Datos de firmas por rol:", response);

            const labels = response.FIRMASROL.map(item => item.ROL);
            const cantidades = response.FIRMASROL.map(item => item.CANTIDAD);

            if (labels.length === 0) {
                $('#chartEtapas').hide();
                $('#chartEtapas').after('<div>No hay datos de firmas para el área seleccionada.</div>');
                return;
            }

            $('#chartEtapas').show();
            if (window.firmasRolChart) {
                window.firmasRolChart.destroy();
            }

            const ctx = document.getElementById('chartEtapas').getContext('2d');
            window.firmasRolChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Cantidad de Firmas',
                        data: cantidades,
                        backgroundColor: '#36A2EB'
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: { stepSize: 1 }
                        }
                    },
                    plugins: {
                        legend: { display: false }
                    }
                }
            });
        },
        error: function(err) {
            console.error(err);
            alert("Ocurrió un error al cargar la gráfica de firmas.");
        }
    });
});

</script>

<script>
    $(document).ready(function() {
    $('#btnActualizar').click(function() {
        let rangoDias = $('#rangoFechas').val();
        let areaId = $('#areaSeleccionada').val();

        $.ajax({
            url: 'prediccion.cfc?method=getPrediccion',
            type: 'GET',
            data: { rangoDias: rangoDias, areaId: areaId },
            dataType: 'json',
            success: function(response) {
                // Asegurarse de parsear JSON si viene como string
                let data = (typeof response === 'string') ? JSON.parse(response) : response;
                console.log('Datos AJAX:', data);
                renderAdvancedChart(data);
            },
            error: function(err) {
                console.error('Error al obtener predicción', err);
            }
        });
    });
});

function renderAdvancedChart(data) {
    const labels = data.map(d => d.fecha);
    const ctx = document.getElementById('chartPredicion').getContext('2d');

    // Gradientes futuristas
    const gradientAprobados = ctx.createLinearGradient(0,0,0,400);
    gradientAprobados.addColorStop(0,'rgba(0,255,128,0.5)');
    gradientAprobados.addColorStop(1,'rgba(0,128,64,0.1)');

    const gradientPendientes = ctx.createLinearGradient(0,0,0,400);
    gradientPendientes.addColorStop(0,'rgba(255,200,0,0.5)');
    gradientPendientes.addColorStop(1,'rgba(128,100,0,0.1)');

    const gradientRechazados = ctx.createLinearGradient(0,0,0,400);
    gradientRechazados.addColorStop(0,'rgba(255,0,0,0.5)');
    gradientRechazados.addColorStop(1,'rgba(128,0,0,0.1)');

    const gradientCredibilidad = ctx.createLinearGradient(0,0,0,400);
    gradientCredibilidad.addColorStop(0,'rgba(0,128,255,0.5)');
    gradientCredibilidad.addColorStop(1,'rgba(0,64,128,0.1)');

    // Destruir instancia previa
    if(window.chartInstance) window.chartInstance.destroy();

    window.chartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Aprobados',
                    data: data.map(d => d.aprobados + 0.5),
                    borderColor: 'green',
                    backgroundColor: gradientAprobados,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 5,
                    pointHoverRadius: 8
                },
                {
                    label: 'Pendientes',
                    data: data.map(d => d.pendientes + 0.5),
                    borderColor: 'orange',
                    backgroundColor: gradientPendientes,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 5,
                    pointHoverRadius: 8,
                    borderDash: [5,5]
                },
                {
                    label: 'Rechazados',
                    data: data.map(d => d.rechazados + 0.5),
                    borderColor: 'red',
                    backgroundColor: gradientRechazados,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 5,
                    pointHoverRadius: 8,
                    borderDash: [10,5]
                },
                {
                    label: 'Credibilidad (%)',
                    data: data.map(d => d.credibilidad),
                    borderColor: 'blue',
                    backgroundColor: gradientCredibilidad,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 3,
                    pointHoverRadius: 6,
                    yAxisID: 'yCredibilidad',
                    borderDash: [2,3]
                }
            ]
        },
        options: {
            responsive: true,
            interaction: { mode: 'index', intersect: false },
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let d = data[context.dataIndex];
                            return `${context.dataset.label}: ${Math.round(context.parsed.y)} | Tipo: ${d.tipo_solicitud} | Permiso: ${d.tipo_permiso}`;
                        }
                    }
                },
                legend: { labels: { usePointStyle: true, pointStyle: 'rectRounded' } }
            },
            scales: {
                y: {
                    title: { display: true, text: 'Cantidad de solicitudes' },
                    suggestedMin: 0,
                    suggestedMax: Math.max(...data.map(d=>Math.max(d.aprobados,d.pendientes,d.rechazados))) + 2
                },
                yCredibilidad: {
                    position: 'right',
                    min: 0,
                    max: 100,
                    title: { display: true, text: 'Credibilidad (%)' },
                    grid: { drawOnChartArea: false }
                },
                x: {
                    title: { display: true, text: 'Fecha' }
                }
            }
        }
    });
}

</script>

<script>
document.getElementById("btnActualizar").addEventListener("click", function(e) {
    e.preventDefault();

    // Obtener valores del formulario
    const rango = document.getElementById("rangoFechas").value;
    const area = document.getElementById("areaSeleccionada").value;

    // Mostrar mensaje de carga
    document.getElementById("tablaAreasBody").innerHTML =
        '<tr><td colspan="6" style="text-align:center;">Cargando...</td></tr>';

    // Llamar al archivo CFM que genera la tabla
    fetch("ranking.cfm", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: `rangoFechas=${rango}&areaSeleccionada=${area}`
    })
    .then(response => response.text())
    .then(html => {
        document.getElementById("tablaAreasBody").innerHTML = html;
    })
    .catch(err => {
        console.error(err);
        document.getElementById("tablaAreasBody").innerHTML =
            '<tr><td colspan="6" style="text-align:center;color:red;">Error al cargar los datos</td></tr>';
    });
});
</script>


    </body>
</html>