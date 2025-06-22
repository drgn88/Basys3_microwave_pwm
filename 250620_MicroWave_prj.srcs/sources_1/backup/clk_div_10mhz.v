`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/20 20:43:20
// Design Name: 
// Module Name: clk_div_10mhz
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


module clk_div_10mhz(
    input clk,
    input rst,

    output reg oclk
    );

    parameter CLK_1MHZ = 50;

    reg [($clog2(CLK_1MHZ) - 1):0] cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt  = 0;
            oclk = 1'b0;
        end else if (cnt == (CLK_1MHZ - 1)) begin
            cnt  = 0;
            oclk = ~oclk;
        end else cnt = cnt + 1'b1;
    end
endmodule
