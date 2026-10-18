`timescale 1ns / 1ps
`default_nettype none
// Entrada previamente sincronizada. Filtra presion Y liberacion.
// DEBOUNCE_CYCLES >= 1; 1_250_000 ciclos a 125 MHz = 10 ms.
module button_onepulse #(parameter integer DEBOUNCE_CYCLES = 1250000) (
    input wire clk, rst, button_sync,
    output reg pressed
);
    localparam integer CW = (DEBOUNCE_CYCLES <= 1) ? 1 : $clog2(DEBOUNCE_CYCLES);
    reg [CW-1:0] count;
    reg stable;
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            stable <= 0;
            pressed <= 0;
        end else begin
            pressed <= 0;
            if (button_sync == stable) begin
                count <= 0;
            end else if (count == DEBOUNCE_CYCLES - 1) begin
                count <= 0;
                stable <= button_sync;
                pressed <= button_sync; // Solo flanco estable 0 -> 1.
            end else begin
                count <= count + 1'b1;
            end
        end
    end
endmodule
`default_nettype wire
