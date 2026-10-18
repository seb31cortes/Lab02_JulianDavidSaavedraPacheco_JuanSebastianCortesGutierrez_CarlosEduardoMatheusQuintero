`timescale 1ns / 1ps
`default_nettype none
module datapath_regs (
    input wire clk, rst,
    input wire [3:0] data_in,
    input wire [3:0] press,
    output reg [3:0] a, b,
    output reg [1:0] op
);
    always @(posedge clk) begin
        if (rst) begin
            a <= 0;
            b <= 0;
            op <= 0;
        end else begin
            if (press[0]) a <= data_in;
            if (press[1]) b <= data_in;
            if (press[2]) op[0] <= ~op[0];
            if (press[3]) op[1] <= ~op[1];
        end
    end
endmodule
`default_nettype wire
