// Validación de checkboxes mutuamente excluyentes para motivo
document.querySelectorAll('input[name="motivo"]').forEach(checkbox => {
    checkbox.addEventListener('change', function() {
        if (this.checked) {
            document.querySelectorAll('input[name="motivo"]').forEach(other => {
                if (other !== this) other.checked = false;
            });
        }
    });
});

// Validación de formulario
document.addEventListener('DOMContentLoaded', function() {
    const form = document.forms['permisoForm'];
    
    form.addEventListener('submit', function(e) {
        const motivoChecked = document.querySelectorAll('input[name="motivo"]:checked').length > 0;
        const tipoPermisoChecked = document.querySelectorAll('input[name="tipo_permiso"]:checked').length > 0;
        
        if (!motivoChecked) {
            alert('Por favor seleccione un motivo para la solicitud.');
            e.preventDefault();
            return false;
        }
        
        if (!tipoPermisoChecked) {
            alert('Por favor seleccione al menos un tipo de permiso.');
            e.preventDefault();
            return false;
        }
    });

    // ===============================
    // 🕒 Validación de tiempo solicitado y horas coherentes
    // ===============================
    const horaSalida = document.getElementById('hora_salida');
    const horaLlegada = document.getElementById('hora_llegada');
    const tiempoSolicitado = document.getElementById('tiempo_solicitado');

    // Función para actualizar restricciones y calcular hora de llegada
    function actualizarRestricciones() {
        if (horaSalida && horaSalida.value) {
            // La hora de llegada no puede ser anterior a la salida
            horaLlegada.min = horaSalida.value;

            // Si hay tiempo solicitado, calcular hora estimada de llegada
            if (tiempoSolicitado && tiempoSolicitado.value) {
                const salida = new Date(`1970-01-01T${horaSalida.value}:00`);
                const horas = parseFloat(tiempoSolicitado.value) || 0;
                salida.setHours(salida.getHours() + horas);
                
                // Ajustar llegada automáticamente
                const llegadaCalculada = salida.toTimeString().slice(0,5);
                horaLlegada.value = llegadaCalculada;
            }
        }
    }

    // Validar que la llegada no sea antes de la salida
    function validarHoras() {
        if (horaSalida && horaLlegada && horaSalida.value && horaLlegada.value && horaLlegada.value < horaSalida.value) {
            alert('La hora de llegada no puede ser anterior a la hora de salida.');
            horaLlegada.value = ''; // limpiar valor inválido
        }
    }

    // Asignar eventos
    if (horaSalida && horaLlegada && tiempoSolicitado) {
        horaSalida.addEventListener('change', actualizarRestricciones);
        tiempoSolicitado.addEventListener('input', actualizarRestricciones);
        horaLlegada.addEventListener('change', validarHoras);
    }
});

// Evitar entrada de caracteres no numéricos en tiempo solicitado
document.getElementById("tiempo_solicitado").addEventListener("input", function () {
    this.value = this.value.replace(/[eE\+\-]/g, "");
});

// checkboxControl.js
document.addEventListener("DOMContentLoaded", function () {
    const checkboxes = document.querySelectorAll('input[name="tipo_permiso"]');

    checkboxes.forEach((checkbox) => {
        checkbox.addEventListener("change", function () {
            if (this.checked) {
                checkboxes.forEach((other) => {
                    if (other !== this) {
                        other.checked = false;
                    }
                });
            }
        });
    });
});

