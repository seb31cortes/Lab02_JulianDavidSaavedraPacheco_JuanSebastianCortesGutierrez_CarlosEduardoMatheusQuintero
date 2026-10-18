`timescale 1ns / 1ps

module tb_alu4;
    // Reloj de 125 MHz, igual al utilizado en la Zybo Z7.
    reg clk = 1'b0;
    always #4 clk = ~clk;

    reg  [3:0] SW;
    reg  [3:0] BTN;
    wire [3:0] LED;
    wire rgb_r;
    wire rgb_g;
    wire rgb_b;

    // Alias de nivel superior para encontrarlos facilmente en GTKWave.
    wire [3:0] a = dut.a;
    wire [3:0] b = dut.b;
    wire [1:0] op = dut.op;
    wire [3:0] y = LED;
    wire [2:0] rgb = {rgb_r, rgb_g, rgb_b};
    wire btn_cargar_a = BTN[0];
    wire btn_cargar_b = BTN[1];
    wire pulso_carga_a = dut.press[0];
    wire pulso_carga_b = dut.press[1];

    integer prueba;
    integer errores;

    // Se reduce el antirrebote solo en simulacion para que las pulsaciones
    // sean visibles sin simular los 1.250.000 ciclos usados en hardware.
    lab02_top #(.DEBOUNCE_CYCLES(4)) dut (
        .clk(clk),
        .SW(SW),
        .BTN(BTN),
        .LED(LED),
        .RGB_R(rgb_r),
        .RGB_G(rgb_g),
        .RGB_B(rgb_b)
    );

    task esperar_ciclos;
        input integer cantidad;
        begin
            repeat (cantidad) @(negedge clk);
        end
    endtask

    task poner_switches;
        input [3:0] valor;
        begin
            @(negedge clk);
            SW = valor;
            // Tiempo para observar SW y para que atraviese el sincronizador.
            esperar_ciclos(4);
        end
    endtask

    task pulsar_boton;
        input [3:0] mascara;
        begin
            @(negedge clk);
            BTN = mascara;
            esperar_ciclos(10);
            BTN = 4'b0000;
            esperar_ciclos(10);
        end
    endtask

    task cargar_a;
        input [3:0] valor;
        begin
            poner_switches(valor);
            pulsar_boton(4'b0001); // BTN0: cargar A.
            if (a !== valor) begin
                errores = errores + 1;
                $display("ERROR carga A: SW=%b A=%b esperado=%b", SW, a, valor);
            end
        end
    endtask

    task cargar_b;
        input [3:0] valor;
        begin
            poner_switches(valor);
            pulsar_boton(4'b0010); // BTN1: cargar B.
            if (b !== valor) begin
                errores = errores + 1;
                $display("ERROR carga B: SW=%b B=%b esperado=%b", SW, b, valor);
            end
        end
    endtask

    task verificar_resultado;
        input [1:0] op_esperado;
        input [3:0] y_esperado;
        input [2:0] rgb_esperado;
        begin
            #1;
            if ((op !== op_esperado) ||
                (y !== y_esperado) ||
                (rgb !== rgb_esperado)) begin
                errores = errores + 1;
                $display("ERROR prueba %0d: A=%b B=%b op=%b y=%b RGB=%b",
                         prueba, a, b, op, y, rgb);
            end else begin
                $display("OK prueba %0d: A=%b B=%b op=%b y=%b RGB={R,G,B}=%b",
                         prueba, a, b, op, y, rgb);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_alu4.vcd");
        $dumpvars(0, tb_alu4);

        SW = 4'b0000;
        BTN = 4'b0000;
        prueba = 0;
        errores = 0;

        // Esperar el reset interno de arranque.
        esperar_ciclos(12);

        // 1. SUMA: cargar A=0101 y B=0011; op inicial 00.
        prueba = 1;
        cargar_a(4'b0101);
        cargar_b(4'b0011);
        verificar_resultado(2'b00, 4'b1000, 3'b010);

        // 2. RESTA: cargar A=0111 y B=0101; BTN2 cambia op[0].
        prueba = 2;
        cargar_a(4'b0111);
        cargar_b(4'b0101);
        pulsar_boton(4'b0100);
        verificar_resultado(2'b01, 4'b0010, 3'b100);

        // 3. AND: cargar A=0011 y B=1001; BTN2 y BTN3 cambian 01 a 10.
        prueba = 3;
        cargar_a(4'b0011);
        cargar_b(4'b1001);
        pulsar_boton(4'b1100);
        verificar_resultado(2'b10, 4'b0001, 3'b001);

        // 4. OR: cargar A=0101 y B=1010; BTN2 cambia 10 a 11.
        prueba = 4;
        cargar_a(4'b0101);
        cargar_b(4'b1010);
        pulsar_boton(4'b0100);
        verificar_resultado(2'b11, 4'b1111, 3'b110);

        if (errores == 0)
            $display("PASS: cargas mediante switches y botones, ALU y RGB correctos.");
        else
            $fatal(1, "FAIL: %0d error(es) durante la simulacion.", errores);

        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "Timeout del testbench");
    end
endmodule
