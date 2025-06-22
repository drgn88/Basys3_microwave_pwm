`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/19 11:55:19
// Design Name: 
// Module Name: clk_divider
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


module clk_divider #(
    parameter FCNT = 500
) (
    input clk,
    input rst,

    output reg oclk
);

    reg [($clog2(FCNT) - 1) : 0] cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            oclk <= 0;
        end else if (cnt == (FCNT - 1)) begin
            cnt <= 0;
            oclk <= ~oclk;
        end else begin
            cnt <= cnt + 1;
            oclk <= oclk;
        end
    end
endmodule
