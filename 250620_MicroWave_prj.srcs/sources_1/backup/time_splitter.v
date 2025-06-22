`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/15 14:49:51
// Design Name: 
// Module Name: time_splitter
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


module time_splitter #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH - 1:0] i_time,

    output [3:0] time_1,
    output [3:0] time_10
);

    assign time_1  = i_time % 10;
    assign time_10 = i_time / 10;

endmodule
