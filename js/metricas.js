document.addEventListener("DOMContentLoaded", function () {
    const ctx = document.getElementById("graficoRoles");

    if (!ctx) {
        console.error("No se encontró el canvas con id 'graficoRoles'");
        return;
    }

    // Datos de ejemplo: reemplázalos por los tuyos desde ColdFusion
    const roles = ["Administrador", "Supervisor", "Usuario"];
    const solicitudes = [15, 8, 25];

    new Chart(ctx, {
        type: "bar",
        data: {
            labels: roles,
            datasets: [{
                label: "Solicitudes por Rol",
                data: solicitudes,
                borderWidth: 1,
                backgroundColor: "rgba(75, 192, 192, 0.5)",
                borderColor: "rgba(75, 192, 192, 1)"
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: { beginAtZero: true, title: { display: true, text: "Número de Solicitudes" } },
                x: { title: { display: true, text: "Roles de Usuario" } }
            },
            plugins: {
                legend: { display: true, position: "top" },
                title: { display: true, text: "Distribución de Solicitudes por Rol" }
            }
        }
    });
});
