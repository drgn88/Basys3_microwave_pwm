`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/16 09:50:45
// Design Name: 
// Module Name: tick_gen_100hz
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


module tick_gen_100hz (
    input clk,
    input rst,

    output reg o_tick_100
);

    parameter FCNT = 1_0000_0000;//1_000_000
    //Simulation 
    //parameter FCNT = 3;
    reg [($clog2(FCNT) - 1) : 0] cnt;

    //output도 항상 초기화해주기
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            o_tick_100 <= 0;
        end else if (cnt == (FCNT - 1)) begin
            cnt <= 0;
            o_tick_100 <= 1;
        end else begin
            cnt <= cnt + 1;
            o_tick_100 <= 0;
        end
    end

endmodule