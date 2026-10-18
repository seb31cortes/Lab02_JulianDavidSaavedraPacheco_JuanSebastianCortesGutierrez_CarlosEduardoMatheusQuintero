`timescale 1ns / 1ps
`default_nettype none
// Dos etapas por entrada asincrona. No garantiza coherencia de un bus
// que cambia varios bits: fijar los switches antes de pulsar CARGAR.
module sync_inputs #(parameter integer WIDTH = 4) (
    input wire clk,
    input wire [WIDTH-1:0] async_in,
    output wire [WIDTH-1:0] sync_out
);
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
    reg [WIDTH-1:0] meta = {WIDTH{1'b0}};
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
    reg [WIDTH-1:0] synced = {WIDTH{1'b0}};
    always @(posedge clk) begin
        meta <= async_in;
        synced <= meta;
    end
    assign sync_out = synced;
endmodule
`default_nettype wire
