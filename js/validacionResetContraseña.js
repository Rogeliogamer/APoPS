// Se ejecuta cuando el DOM ya está listo
document.addEventListener("DOMContentLoaded", function() {

    // ==============================
    // 1. Validación de contraseña
    // ==============================
    const contrasenaInput = document.getElementById('contrasena');
    const submitBtn = document.querySelector('button[type="reset"]');
    const passwordMsg = document.getElementById('passwordMsg');

    if (contrasenaInput && submitBtn && passwordMsg) {

        // Bloquear botón al inicio por seguridad
        submitBtn.disabled = true;
        submitBtn.style.opacity = "0.6";
        submitBtn.style.cursor = "not-allowed";

        contrasenaInput.addEventListener('input', function() {
            const valor = this.value;

            // Regex para validar contraseña
            const regex = new RegExp(
                "^(?=.*[a-z])" +                 // Al menos una minúscula
                "(?=.*[A-Z])" +                  // Al menos una mayúscula
                "(?=.*\\d)" +                    // Al menos un número
                "(?=.*[°\\|¬!@#$%&/()=?'\\\\¡¿¨´*+~\\]\\}`\\[\\{\\^;,:._<>/*\\-+\\.])" + // Al menos un caracter especial
                ".{8,}$"                         // Mínimo 8 caracteres
            );

            if (!regex.test(valor)) {
                passwordMsg.textContent = 
                    "La contraseña debe tener al menos 8 caracteres, incluyendo mayúsculas, minúsculas, número y un carácter especial.";
                    passwordMsg.style.color = "#d32f2f"; // Rojo

                    // Deshabilitar botón
                    submitBtn.disabled = true;
                    submitBtn.style.opacity = "0.6";
                    submitBtn.style.cursor = "not-allowed";
            } else {
                passwordMsg.textContent = "Contraseña válida ✔";
                passwordMsg.style.color = "#388e3c"; // Verde
                
                // Habilitar botón
                submitBtn.disabled = false;
                submitBtn.style.opacity = "1";
                submitBtn.style.cursor = "pointer";

                contrasenaInput.style.borderColor = "#388e3c";
            }
        });
    }

});
