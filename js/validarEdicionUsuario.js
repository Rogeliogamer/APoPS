// Se ejecuta cuando el DOM ya está listo
document.addEventListener("DOMContentLoaded", function() {

    // ==============================
    // 1. Permitir solo letras y espacios
    // ==============================
    window.soloLetrasNumeros = function(input) {
        // Variable original
        let valorOriginal = input.value;

        // Reemplaza cualquier caracter que no sea letra, número o espacio
        let valorLimpio = valorOriginal.replace(/[^A-Za-z0-9ÁÉÍÓÚáéíóúÑñüÜ\s]/g, '');

        // Si hubo cambios (es, decir, si se ingresaron caracteres inválidos), actualiza el valor del input
        if (valorLimpio !== valorOriginal) {
            input.value = valorLimpio;
        }
    };

    // ==============================
    // 2. Sanitización del usuario (sin HTML, sin espacios extras)
    // ==============================
    window.sanitizarUsuario = function(input) {
        // Variable original
        let valorOriginal = input.value;

        // Reemplaza cualquier caracter que no sea letra, número o letras con tilde
        // El simbolo ^ dentro de [] significa negación
        let valorLimpio = valorOriginal.replace(/[^a-zA-ZñÑáéíóúÁÉÍÓÚüÜ]/g, '');

        // Si hubo cambios (es, decir, si se ingresaron caracteres inválidos), actualiza el valor del input
        if (valorLimpio !== valorOriginal) {
            input.value = valorLimpio;
        }
    };
});
