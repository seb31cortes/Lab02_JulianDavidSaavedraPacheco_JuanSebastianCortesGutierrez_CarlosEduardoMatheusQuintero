`timescale 1ns / 1ps
`default_nettype none
module lab02_top #(parameter integer DEBOUNCE_CYCLES = 1250000) (
    input wire clk,
    input wire [3:0] SW, BTN,
    output wire [3:0] LED,
    output wire RGB_R, RGB_G, RGB_B
);
    // INIT de flip-flops soportado por Vivado para Zynq-7000.
    // Reset sincronico de arranque durante cuatro flancos de reloj.
    reg [3:0] startup = 4'b1111;
    wire rst = startup[3];
    always @(posedge clk) startup <= {startup[2:0], 1'b0};

    wire [3:0] sw_sync, btn_sync, press;
    wire [3:0] a, b;
    wire [1:0] op;
    sync_inputs u_sw_sync (.clk(clk), .async_in(SW), .sync_out(sw_sync));
    sync_inputs u_btn_sync (.clk(clk), .async_in(BTN), .sync_out(btn_sync));
    genvar i;
    generate for (i = 0; i < 4; i = i + 1) begin : g_btn
        button_onepulse #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) u_filter (
            .clk(clk), .rst(rst), .button_sync(btn_sync[i]), .pressed(press[i]));
    end endgenerate
    datapath_regs u_regs (.clk(clk), .rst(rst), .data_in(sw_sync),
        .press(press), .a(a), .b(b), .op(op));
    alu4 u_alu (.a(a), .b(b), .op(op), .y(LED));
    op_rgb u_rgb (.op(op), .rgb({RGB_R, RGB_G, RGB_B}));
endmodule
`default_nettype wire
