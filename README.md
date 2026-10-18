# Laboratorio 02 — ALU de 4 bits en Zybo Z7-10

Electrónica Digital II · Universidad Nacional de Colombia, sede Bogotá · 2026-2

| Integrante | Correo |
|---|---|
| Julián David Saavedra Pacheco | jusaavedrap@unal.edu.co |
| Juan Sebastián Cortés Gutiérrez | jcortesgu@unal.edu.co |
| Carlos Eduardo Matheus Quintero | cmatheus@unal.edu.co |

## Descripción general del sistema

El diseño implementa una unidad aritmético-lógica de cuatro bits capaz de efectuar suma, resta, AND y OR. Los switches de la tarjeta forman un bus de entrada compartido: primero se coloca un dato y se almacena como operando `A`; después se coloca un segundo dato y se almacena como operando `B`. Dos botones adicionales modifican y conservan el código de operación `op[1:0]`.

La ALU es combinacional y no almacena información. Los registros de operandos y de operación se encuentran en el datapath, fuera de la ALU. El resultado de cuatro bits se conecta a `LED[3:0]`, mientras que el LED RGB identifica la operación seleccionada.

## Arquitectura propuesta

```mermaid
flowchart LR
    SW[SW3:SW0] --> SWS[Sincronizador]
    BTN[BTN3:BTN0] --> BTNS[Sincronizador]
    BTNS --> FILTRO[Antirrebote y pulso único]
    SWS --> REGA[Registro A]
    SWS --> REGB[Registro B]
    FILTRO -->|BTN0| REGA
    FILTRO -->|BTN1| REGB
    FILTRO -->|BTN2 y BTN3| REGOP[Registro op]
    REGA --> ALU[ALU combinacional]
    REGB --> ALU
    REGOP --> ALU
    ALU --> LED[LED3:LED0]
    REGOP --> RGB[Decodificador RGB]
```

Todas las partes secuenciales trabajan con el reloj de 125 MHz. Los switches y botones se sincronizan antes de usarse. Cada botón pasa por un filtro de antirrebote que produce un pulso de un ciclo, por lo que mantenerlo presionado no repite la acción. La ALU y el decodificador RGB son bloques combinacionales.

## Módulos desarrollados

### `alu4` — ALU combinacional

El módulo [`src/alu4.v`](src/alu4.v) recibe `a[3:0]`, `b[3:0]` y `op[1:0]`, y entrega `y[3:0]`. Un bloque `always @*` con una sentencia `case` selecciona suma, resta, AND u OR. Todas las ramas asignan la salida, por lo que no se infieren latches. El módulo no tiene reloj, reset ni realimentación: el resultado depende únicamente de las entradas actuales. Los resultados aritméticos se truncan a cuatro bits.

### `sync_inputs` — Sincronización de entradas

El módulo [`src/sync_inputs.v`](src/sync_inputs.v) tiene ancho parametrizable y se instancia dos veces: una para `SW[3:0]` y otra para `BTN[3:0]`. Cada bit atraviesa los registros `meta` y `synced` en flancos positivos de `clk`. Los atributos `ASYNC_REG` y `SHREG_EXTRACT` indican a las herramientas que estas etapas forman un sincronizador y evitan su conversión en registros de desplazamiento. Su función es reducir el riesgo de metastabilidad al introducir señales externas en el dominio de 125 MHz; no almacena el operando funcional del datapath.

### `button_onepulse` — Antirrebote y pulso único

[`src/button_onepulse.v`](src/button_onepulse.v) recibe un botón ya sincronizado y utiliza un contador para exigir que el nuevo nivel permanezca estable durante `DEBOUNCE_CYCLES`. El registro `stable` conserva el último nivel aceptado. Cuando se valida una transición estable de 0 a 1, `pressed` se activa durante un solo ciclo; mantener el botón presionado no genera pulsos adicionales. La liberación también debe estabilizarse antes de permitir otra presión. El ancho del contador se calcula con `$clog2` a partir del parámetro.

### `datapath_regs` — Registros de operandos y operación

[`src/datapath_regs.v`](src/datapath_regs.v) contiene los elementos de almacenamiento del sistema. En cada flanco positivo, `press[0]` copia `data_in` en `a`, `press[1]` lo copia en `b`, `press[2]` invierte `op[0]` y `press[3]` invierte `op[1]`. Las cuatro condiciones son independientes y no existe prioridad artificial entre ellas. Si no aparece el pulso correspondiente, cada registro conserva su valor aunque cambien los switches o se suelte el botón. El reset síncrono inicializa `a`, `b` y `op` en cero.

### `op_rgb` — Decodificador de operación

[`src/op_rgb.v`](src/op_rgb.v) es un bloque combinacional que convierte `op[1:0]` en `rgb[2:0]`, usando el orden `{rojo, verde, azul}` y salidas activas en alto. El `case` produce `010` para suma, `100` para resta, `001` para AND y `110` para OR. Como depende del registro `op`, el color permanece estable después de soltar los botones de selección.

### `lab02_top` — Integración con la FPGA

[`src/lab02_top.v`](src/lab02_top.v) conecta el reloj, los cuatro switches, los cuatro botones, los cuatro LEDs y los tres canales RGB. Instancia dos sincronizadores, cuatro filtros mediante un bloque `generate`, el datapath, la ALU y el decodificador de color. Un registro de desplazamiento `startup` mantiene un reset interno durante los primeros cuatro flancos después de configurar la FPGA. La salida de `alu4` se conecta directamente a `LED[3:0]`; las operaciones aritméticas y lógicas no se duplican dentro del módulo superior.

## Almacenamiento de operandos y conservación de la operación

`BTN0` carga en `A` el valor sincronizado de `SW[3:0]`; `BTN1` realiza la misma acción sobre `B`. Después de la carga, mover los switches no modifica el registro: el operando permanece almacenado hasta que se acepta una nueva pulsación de su botón.

El código de operación también se guarda en flip-flops. `BTN2` conmuta `op[0]` y `BTN3` conmuta `op[1]`. Al soltar los botones el código no se borra, por lo que no es necesario mantenerlos presionados durante la operación. El reset interno de arranque inicializa `A`, `B` y `op` en cero.

## Operaciones implementadas e indicador RGB

| `op[1:0]` | Operación | Resultado `LED[3:0]` | Color | `{R,G,B}` |
|---|---|---|---|---|
| `00` | Suma | `(A + B) mod 16` | Verde | `010` |
| `01` | Resta | `(A - B) mod 16` | Rojo | `100` |
| `10` | AND bit a bit | `A & B` | Azul | `001` |
| `11` | OR bit a bit | `A \| B` | Amarillo | `110` |

La salida tiene cuatro bits. Por esta razón se descarta el acarreo de la suma y una resta negativa se representa en complemento a dos módulo 16. No se implementan banderas de acarreo, préstamo u overflow.

## Verificación mediante simulación

El banco [`sim/tb_alu4.v`](sim/tb_alu4.v) verifica el sistema integrado. Para cada prueba coloca el primer operando en `SW`, pulsa `BTN0`, coloca el segundo operando, pulsa `BTN1` y selecciona la operación con `BTN2` y `BTN3`. Además de generar ondas, el testbench compara automáticamente los registros, el resultado y el color RGB con los valores esperados.

En simulación se reduce `DEBOUNCE_CYCLES` a cuatro ciclos para observar las cargas sin ejecutar los 1.250.000 ciclos usados por la implementación. Esta reducción solo pertenece a la instancia del testbench y no modifica el valor sintetizable de hardware.

| Prueba | Operación | `op` | `A` | `B` | Resultado esperado | RGB esperado |
|---:|---|---|---|---|---|---|
| 1 | Suma | `00` | `0101` (5) | `0011` (3) | `1000` (8) | `010`, verde |
| 2 | Resta | `01` | `0111` (7) | `0101` (5) | `0010` (2) | `100`, rojo |
| 3 | AND | `10` | `0011` (3) | `1001` (9) | `0001` (1) | `001`, azul |
| 4 | OR | `11` | `0101` (5) | `1010` (10) | `1111` (15) | `110`, amarillo |

### Captura general de GTKWave

![Simulación general de las cuatro pruebas](evidencias/generalidades/gtkwave_general.png)

La señal `prueba` divide la simulación en las cuatro verificaciones. Las señales mostradas permiten seguir el recorrido completo de cada dato:

| Señal | Interpretación |
|---|---|
| `clk` | Reloj de 125 MHz que gobierna sincronizadores, filtros y registros. |
| `prueba` | Número de la prueba activa: 1 suma, 2 resta, 3 AND y 4 OR. |
| `SW[3:0]` | Dato que el testbench coloca en los switches. |
| `btn_cargar_a`, `btn_cargar_b` | Intervalo durante el cual se mantiene presionado `BTN0` o `BTN1`. |
| `pulso_carga_a`, `pulso_carga_b` | Pulso de un ciclo producido cuando el filtro acepta la pulsación. |
| `a[3:0]`, `b[3:0]` | Valores almacenados después de cada pulso de carga. |
| `op[1:0]` | Código de operación almacenado. |
| `rgb[2:0]` | Color asociado a `op`, en orden `{R,G,B}`. |
| `LED[3:0]` | Resultado combinacional de la ALU. GTKWave lo presenta en hexadecimal. |

En cada carga se observa primero el cambio de `SW`, luego el nivel alto del botón, después el pulso aceptado y finalmente el cambio de `a` o `b`. Los registros no siguen directamente a los switches: conservan su valor hasta la pulsación correspondiente.

`LED` puede mostrar valores intermedios mientras se preparan los operandos. Esto es correcto porque la ALU responde inmediatamente a los registros disponibles y al `op` que estuviera almacenado. Por ejemplo, durante la prueba 2 se observan `A` y `C` mientras se cargan 7 y 5 bajo la suma anterior; al cambiar `op` a `01`, el resultado definitivo pasa a `2` y el RGB a `100`. De forma análoga, la prueba AND termina en `1` y la prueba OR pasa por `0` antes de terminar en `F` hexadecimal.

El resultado final de la ejecución fue satisfactorio para las cuatro pruebas. Los archivos reproducibles son el testbench [`sim/tb_alu4.v`](sim/tb_alu4.v), el ejecutable [`sim/tb_alu4.vpp`](sim/tb_alu4.vpp) y las ondas [`sim/tb_alu4.vcd`](sim/tb_alu4.vcd).

## Evidencias de cada prueba

Cada ficha contiene la tabla de entradas y salidas, la captura recortada y una explicación del comportamiento observado.

| Evidencia | Ficha | Archivo principal |
|---:|---|---|
| Generalidades | [`evidencias/generalidades/README.md`](evidencias/generalidades/README.md) | [`gtkwave_general.png`](evidencias/generalidades/gtkwave_general.png) |
| 1 — Suma | [`evidencias/01_suma/README.md`](evidencias/01_suma/README.md) | [`gtkwave_suma.png`](evidencias/01_suma/gtkwave_suma.png) |
| 2 — Resta | [`evidencias/02_resta/README.md`](evidencias/02_resta/README.md) | [`gtkwave_resta.png`](evidencias/02_resta/gtkwave_resta.png) |
| 3 — AND | [`evidencias/03_and/README.md`](evidencias/03_and/README.md) | [`gtkwave_and.png`](evidencias/03_and/gtkwave_and.png) |
| 4 — OR | [`evidencias/04_or/README.md`](evidencias/04_or/README.md) | [`gtkwave_or.png`](evidencias/04_or/gtkwave_or.png) |

## Correspondencia con la implementación en FPGA

| Recurso físico | Función |
|---|---|
| `SW0`–`SW3` | Bus de datos de cuatro bits. |
| `BTN0` | Cargar el bus en `A`. |
| `BTN1` | Cargar el bus en `B`. |
| `BTN2` | Conmutar `op[0]`. |
| `BTN3` | Conmutar `op[1]`. |
| `LED0`–`LED3` | Mostrar el resultado de cuatro bits. |
| LED RGB | Identificar la operación mediante verde, rojo, azul o amarillo. |

La asignación concreta de estos recursos se encuentra en [`constraints/zybo_z7.xdc`](constraints/zybo_z7.xdc). Las capturas incluidas demuestran la simulación RTL del mismo flujo de switches, botones, registros, resultado y color que utiliza el módulo superior.

### Evidencia física en video

Los videos proporcionados documentan la ejecución en la tarjeta y se asignaron mediante sus duraciones reales. El video de generalidades verifica específicamente la propiedad de almacenamiento: mover los switches no altera los operandos ni el resultado hasta que se pulsa el botón de carga correspondiente.

| Evidencia | Duración aproximada | Video |
|---|---:|---|
| Retención frente a cambios en los switches | 25 s | [`retencion_operandos.mp4`](evidencias/generalidades/retencion_operandos.mp4) |
| Prueba 1 — Suma | 1 min 10 s | [`prueba_suma.mp4`](evidencias/01_suma/prueba_suma.mp4) |
| Prueba 2 — Resta | 47 s | [`prueba_resta.mp4`](evidencias/02_resta/prueba_resta.mp4) |
| Prueba 3 — AND | 42 s | [`prueba_and.mp4`](evidencias/03_and/prueba_and.mp4) |
| Prueba 4 — OR | 38 s | [`prueba_or.mp4`](evidencias/04_or/prueba_or.mp4) |

Cada prueba dispone así de dos evidencias complementarias: la captura de GTKWave muestra las señales internas y el video permite contrastar el comportamiento sobre la FPGA mediante switches, botones, LEDs y color RGB.

## Conclusiones

La arquitectura separa correctamente la lógica combinacional de los elementos de almacenamiento. Los operandos y el código de operación permanecen guardados después de mover los switches o soltar los botones, mientras que la salida se actualiza de forma combinacional. Las ondas confirman las cargas independientes, la permanencia de `op`, los cuatro resultados esperados y la correspondencia entre cada operación y su color RGB.
