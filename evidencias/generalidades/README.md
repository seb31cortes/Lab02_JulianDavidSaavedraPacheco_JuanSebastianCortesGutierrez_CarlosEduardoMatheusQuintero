# Generalidades — Simulación y retención de operandos

Esta carpeta reúne la vista completa de las cuatro pruebas y la evidencia física de que los registros aíslan la operación frente a cambios posteriores en los switches.

## Captura general de GTKWave

![Vista general de las cuatro pruebas](gtkwave_general.png)

La captura permite seguir `SW`, los botones, los pulsos aceptados, los registros `a` y `b`, `op`, `rgb` y `LED`. Primero cambia el bus de switches; el registro correspondiente solo cambia después de `pulso_carga_a` o `pulso_carga_b`. La señal `prueba` separa suma, resta, AND y OR.

Los resultados intermedios son una consecuencia normal de la ALU combinacional: cuando se actualiza un operando, la salida se recalcula usando el otro operando y el código de operación que aún estén almacenados. Al finalizar cada secuencia aparecen los resultados definitivos 8, 2, 1 y 15.

## Video de retención ante cambios en los switches

[Ver o descargar el video de generalidades](retencion_operandos.mp4) — duración aproximada: 25 segundos.

El video verifica que mover repetidamente los switches no cambia por sí solo los operandos almacenados ni la operación observada. El nuevo valor solo entra al datapath cuando se pulsa el botón de carga de `A` o de `B`. Este comportamiento demuestra la separación entre el bus físico de entrada y los registros que alimentan la ALU.
