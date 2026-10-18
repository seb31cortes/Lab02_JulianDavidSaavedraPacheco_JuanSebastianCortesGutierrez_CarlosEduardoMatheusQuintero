`timescale 1ns / 1ps
`default_nettype none
module op_rgb (input wire [1:0] op, output reg [2:0] rgb);
    // Orden {ROJO, VERDE, AZUL}; LEDs de la Zybo activos en alto.
    always @* begin
        case (op)
            2'b00: rgb = 3'b010; // Suma: verde.
            2'b01: rgb = 3'b100; // Resta: rojo.
            2'b10: rgb = 3'b001; // AND: azul.
            2'b11: rgb = 3'b110; // OR: amarillo.
            default: rgb = 3'b000;
        endcase
    end
endmodule
`default_nettype wire
