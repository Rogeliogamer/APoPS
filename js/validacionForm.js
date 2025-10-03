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
});

// Evitar entrada de caracteres no numéricos en tiempo solicitado
document.getElementById("tiempo_solicitado").addEventListener("input", function () {
    this.value = this.value.replace(/[eE\+\-]/g, "");
});