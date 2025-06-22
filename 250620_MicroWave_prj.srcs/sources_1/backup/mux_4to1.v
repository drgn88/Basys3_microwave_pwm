`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/15 14:50:40
// Design Name: 
// Module Name: mux_4to1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux_4to1(
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,

    output reg [3:0] bcd
    );

    always @(*) begin
        case (sel)
            2'b00:   bcd = digit_1;
            2'b01:   bcd = digit_10;
            2'b10:   bcd = digit_100;
            2'b11:   bcd = digit_1000;
            default: bcd = 4'h0;
        endcase
    end
endmodule
