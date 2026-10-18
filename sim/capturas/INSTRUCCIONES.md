# Capturas reales de GTKWave pendientes

Los VCD se generaron ejecutando los testbenches. Las sesiones `.gtkw` incluyen las señales solicitadas. La captura de la interfaz de GTKWave no pudo automatizarse porque el servicio local de control de aplicaciones falla al iniciar (`setup refresh had errors`). No se incluye una imagen fabricada como si fuera una captura.

1. Desde la raíz, abrir `gtkwave sim/alu4.vcd sim/alu4.gtkw`.
2. Mostrar 0–80 ns. Deben verse A, B, op e y; A/B/y están en hexadecimal y op en binario. Usar zoom si es necesario.
3. Guardar una captura de la ventana como `alu4_gtk.png` dentro de esta carpeta.
4. Abrir `gtkwave sim/lab02_top.vcd sim/lab02_top.gtkw`, usar Zoom Fit y capturar `sistema_gtk.png`.
5. Ampliar una pulsación con rebote; capturar `antirrebote_gtk.png` con BTN, press, op y rgb.
6. Insertar en el README las imágenes reales usando rutas relativas, por ejemplo `![ALU en GTKWave](sim/capturas/alu4_gtk.png)`.

En este momento esos PNG todavía no existen. La visualización y sus capturas deben completarse antes de la entrega académica.
