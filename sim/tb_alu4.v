`timescale 1ns / 1ps
module tb_alu4;
    reg [3:0] a = 0, b = 0;
    reg [1:0] op = 0;
    wire [3:0] y;
    integer ia, ib, io, expected, checks = 0;
    alu4 dut (.a(a), .b(b), .op(op), .y(y));
    task check;
        input integer want;
        begin
            #10;
            if (y !== (want & 15))
                $fatal(1, "ALU A=%d B=%d OP=%b Y=%d esperado=%d", a,b,op,y,want&15);
            checks = checks + 1;
        end
    endtask
    initial begin
        $dumpfile("sim/alu4.vcd");
        $dumpvars(0, tb_alu4);
        // Ventana didactica: 0..80 ns. No hay reloj en esta prueba.
        a=9; b=3; op=0; check(12);
        op=1; check(6);
        op=2; check(1);
        op=3; check(11);
        a=6; check(7); // Solo cambia A.
        b=8; check(14); // Solo cambia B.
        a=15; b=1; op=0; check(0); // Truncamiento.
        a=3; b=5; op=1; check(14); // Resta modulo 16.
        for (ia=0; ia<16; ia=ia+1)
            for (ib=0; ib<16; ib=ib+1)
                for (io=0; io<4; io=io+1) begin
                    a=ia; b=ib; op=io;
                    case (io)
                        0: expected=(ia+ib)%16;
                        1: expected=(ia-ib+16)%16;
                        2: expected=ia&ib;
                        3: expected=ia|ib;
                    endcase
                    check(expected);
                end
        $display("PASS ALU: %0d comprobaciones (1024 exhaustivas + 8 dirigidas)",checks);
        $finish;
    end
endmodule
