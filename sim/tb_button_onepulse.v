`timescale 1ns / 1ps
module tb_button_onepulse;
    parameter integer N = 4;
    reg clk = 0, rst = 1, button_sync = 0;
    wire pressed;
    integer pulses = 0, i;
    always #4 clk=~clk;
    button_onepulse #(.DEBOUNCE_CYCLES(N)) dut (clk,rst,button_sync,pressed);
    task tick;
        begin @(posedge clk); #1; if(pressed) pulses=pulses+1; @(negedge clk); end
    endtask
    initial begin
        tick(); rst=0; tick();
        button_sync=1;
        for(i=1;i<N;i=i+1) begin tick(); if(pressed) $fatal(1,"Pulso prematuro"); end
        tick(); if(!pressed || pulses!=1) $fatal(1,"Falta pulso en el ciclo N");
        repeat(8) begin tick(); if(pressed) $fatal(1,"Repite al mantener"); end
        button_sync=0;
        for(i=1;i<N;i=i+1) tick();
        if(N>1) begin
            button_sync=1; repeat(3) tick();
            if(pulses!=1) $fatal(1,"Liberacion incompleta rearma");
            button_sync=0;
        end
        repeat(N+1) tick();
        button_sync=1; repeat(N+2) tick();
        if(pulses!=2) $fatal(1,"No se rearma tras liberar");
        rst=1; tick(); if(pressed) $fatal(1,"Reset no limpia");
        $display("PASS BUTTON: N=%0d, umbral exacto, retencion, liberacion y reset",N);
        $finish;
    end
endmodule
