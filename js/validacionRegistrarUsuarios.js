// Se ejecuta cuando el DOM ya está listo
document.addEventListener("DOMContentLoaded", function() {

    // ==============================
    // 1. Permitir solo letras y espacios
    // ==============================
    window.soloLetras = function(input) {
        input.value = input.value.replace(/[^A-Za-zÁÉÍÓÚáéíóúÑñ\s]/g, '');
    };

    // ==============================
    // 2. Sanitización del usuario (sin HTML, sin espacios extras)
    // ==============================
    window.sanitizarUsuario = function(input) {
        // Variable original
        let valorOriginal = input.value;

        // Reemplaza cualquier caracter que no sea letra, número o letras con tilde
        // El simbolo ^ dentro de [] significa negación
        let valorLimpio = valorOriginal.replace(/[^a-zA-Z0-9ñÑáéíóúÁÉÍÓÚüÜ]/g, '');

        // Si hubo cambios (es, decir, si se ingresaron caracteres inválidos), actualiza el valor del input
        if (valorLimpio !== valorOriginal) {
            input.value = valorLimpio;
        }
    };

    // ==============================
    // 3. Validación de contraseña
    // ==============================
    const contrasenaInput = document.getElementById('contrasena');
    const submitBtn = document.querySelector('button[type="submit"]');
    const passwordMsg = document.getElementById('passwordMsg');

    if (contrasenaInput && submitBtn && passwordMsg) {
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
                submitBtn.disabled = true;
            } else {
                passwordMsg.textContent = "";
                submitBtn.disabled = false;
            }
        });
    }

});
