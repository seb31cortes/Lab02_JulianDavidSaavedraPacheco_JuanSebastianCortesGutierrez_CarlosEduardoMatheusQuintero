`timescale 1ns / 1ps
module tb_lab02_top;
    reg clk = 0;
    always #4 clk = ~clk; // 125 MHz, igual que la tarjeta.
    reg [3:0] SW = 0, BTN = 0;
    wire [3:0] LED;
    wire R, G, B;
    wire [2:0] rgb = {R,G,B};
    integer checks = 0;
    lab02_top #(.DEBOUNCE_CYCLES(4)) dut (
        .clk(clk), .SW(SW), .BTN(BTN), .LED(LED), .RGB_R(R), .RGB_G(G), .RGB_B(B));
    task cycles;
        input integer n;
        begin repeat(n) @(negedge clk); end
    endtask
    task verify;
        input [3:0] want_a, want_b, want_y;
        input [1:0] want_op;
        input [2:0] want_rgb;
        begin
            #1;
            if ({dut.a,dut.b,dut.op,LED,rgb} !== {want_a,want_b,want_op,want_y,want_rgb})
                $fatal(1,"TOP t=%0t A=%h B=%h OP=%b LED=%h RGB=%b",$time,dut.a,dut.b,dut.op,LED,rgb);
            checks=checks+1;
        end
    endtask
    task data;
        input [3:0] value;
        begin @(negedge clk); SW=value; cycles(10); end
    endtask
    task tap;
        input [3:0] mask;
        begin @(negedge clk); BTN=mask; cycles(12); BTN=0; cycles(12); end
    endtask
    initial begin
        $dumpfile("sim/lab02_top.vcd");
        $dumpvars(0,tb_lab02_top);
        cycles(12); verify(0,0,0,0,3'b010);
        data(9); tap(1); verify(9,0,9,0,3'b010);
        data(3); verify(9,0,9,0,3'b010);
        tap(2); verify(9,3,12,0,3'b010);
        data(0); verify(9,3,12,0,3'b010);
        tap(4); verify(9,3,6,1,3'b100);
        tap(8); verify(9,3,11,3,3'b110);
        tap(4); verify(9,3,1,2,3'b001);
        tap(8); verify(9,3,12,0,3'b010);
        // Rebotes en BTN2: pulsos menores al umbral no cambian el opcode.
        BTN=4; cycles(1); BTN=0; cycles(2);
        BTN=4; cycles(2); BTN=0; cycles(10);
        verify(9,3,12,0,3'b010);
        BTN=4; cycles(12); verify(9,3,6,1,3'b100);
        cycles(40); verify(9,3,6,1,3'b100); // Mantener no repite.
        BTN=0; cycles(1); BTN=4; cycles(1); BTN=0; cycles(12);
        verify(9,3,6,1,3'b100); // Rebotes de liberacion.
        tap(4); verify(9,3,12,0,3'b010); // Se rearma tras soltar.
        // Carga una vez: mover SW mientras BTN0 sigue alto no recarga A.
        data(5); BTN=1; cycles(12); verify(5,3,8,0,3'b010);
        data(7); verify(5,3,8,0,3'b010);
        BTN=0; cycles(12); tap(1); verify(7,3,10,0,3'b010);
        // Ambos botones de carga: A y B capturan el mismo bus.
        data(15); tap(3); verify(15,15,14,0,3'b010);
        // Ambos selectores: se invierten los dos bits (sin prioridad).
        tap(12); verify(15,15,15,3,3'b110);
        data(1); tap(2); verify(15,1,15,3,3'b110);
        tap(12); verify(15,1,0,0,3'b010); // Overflow descartado.
        data(3); tap(1); data(5); tap(2); tap(4);
        verify(3,5,14,1,3'b100);
        tap(1); verify(5,5,0,1,3'b100); // Resultado cero no cambia RGB.
        $display("PASS TOP: %0d comprobaciones de almacenamiento, operaciones, RGB y rebotes",checks);
        $finish;
    end
    initial begin #100000; $fatal(1,"Timeout TOP"); end
endmodule
