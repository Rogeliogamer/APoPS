// js/graficasKPI.js

// Almacena las gráficas activas para poder actualizarlas sin recrearlas
let chartsKPI = {};

function actualizarGraficasKPI(data) {
    if (!data || !data.tendencia) return;

    // Configuración base de las gráficas
    const opciones = {
        responsive: false,
        plugins: { legend: { display: false } },
        scales: {
            x: { display: false },
            y: { display: false, min: 0 }
        },
        elements: {
            line: { tension: 0.3, borderWidth: 2 },
            point: { radius: 0 }
        }
    };

    // Función genérica para crear o actualizar una gráfica
    const renderGraficaLinea = (idCanvas, valores, color) => {
        const canvas = document.getElementById(idCanvas);
        if (!canvas)  return;
        const ctx = canvas.getContext("2d");

        // Si ya existe, actualizamos los datos
        if (chartsKPI[idCanvas]) {
            chartsKPI[idCanvas].data.labels = data.tendencia.labels;
            chartsKPI[idCanvas].data.datasets[0].data = valores;
            chartsKPI[idCanvas].update();
        } else {
            chartsKPI[idCanvas] = new Chart(ctx, {
                type: "line",
                data: {
                    labels: data.tendencia.labels,
                    datasets: [{
                        data: valores,
                        borderColor: color,
                        backgroundColor: "transparent",
                        fill: false
                    }]
                },
                options: opciones
            });
        }
    };

    // Crear/actualizar gráficas con colores consistentes
    renderGraficaLinea("graficoTotalSolicitudes", data.tendencia.total, "#007bff");
    renderGraficaLinea("graficoAprobadas", data.tendencia.aprobadas, "#28a745");
    renderGraficaLinea("graficoPendientes", data.tendencia.pendientes, "#ffc107");
    renderGraficaLinea("graficoRechazadas", data.tendencia.rechazadas, "#dc3545");
    renderGraficaLinea("graficoTiempo", data.tendencia.tiempoPromedio, "#17a2b8");
}
