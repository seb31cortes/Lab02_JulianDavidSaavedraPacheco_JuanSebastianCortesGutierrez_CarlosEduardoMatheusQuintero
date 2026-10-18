`timescale 1ns / 1ps

module tb_alu4;
    reg  [3:0] a;
    reg  [3:0] b;
    reg  [1:0] op;
    wire [3:0] y;

    integer prueba;
    integer errores;

    alu4 dut (
        .a(a),
        .b(b),
        .op(op),
        .y(y)
    );

    task ejecutar_prueba;
        input integer numero;
        input [3:0] valor_a;
        input [3:0] valor_b;
        input [1:0] operacion;
        input [3:0] esperado;
        begin
            prueba = numero;
            a = valor_a;
            b = valor_b;
            op = operacion;
            #10;

            if (y !== esperado) begin
                errores = errores + 1;
                $display("ERROR prueba %0d: A=%b B=%b op=%b y=%b esperado=%b",
                         prueba, a, b, op, y, esperado);
            end else begin
                $display("OK prueba %0d: A=%b B=%b op=%b y=%b",
                         prueba, a, b, op, y);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_alu4.vcd");
        $dumpvars(0, tb_alu4);

        a = 4'b0000;
        b = 4'b0000;
        op = 2'b00;
        prueba = 0;
        errores = 0;

        // 1. Suma: 5 + 3 = 8
        ejecutar_prueba(1, 4'b0101, 4'b0011, 2'b00, 4'b1000);

        // 2. Resta: 7 - 5 = 2
        ejecutar_prueba(2, 4'b0111, 4'b0101, 2'b01, 4'b0010);

        // 3. AND: 3 & 9 = 1
        ejecutar_prueba(3, 4'b0011, 4'b1001, 2'b10, 4'b0001);

        // 4. OR: 5 | 10 = 15
        ejecutar_prueba(4, 4'b0101, 4'b1010, 2'b11, 4'b1111);

        if (errores == 0)
            $display("PASS: las 4 pruebas de la ALU fueron correctas.");
        else
            $fatal(1, "FAIL: %0d prueba(s) incorrecta(s).", errores);

        $finish;
    end
endmodule
