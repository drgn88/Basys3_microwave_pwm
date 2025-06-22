`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/19 12:18:15
// Design Name: 
// Module Name: btn_debouncer
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


module btn_debouncer (
    input clk,
    input rst,
    input i_btn,

    output o_btn
);

    wire oclk_100khz;
    wire w_btn_deb;

    clk_divider #(
        .FCNT(500)//500
    ) U_CLK_100KHZ (
        .clk (clk),
        .rst (rst),
        .oclk(oclk_100khz)
    );

    shift_debounce U_DEB_BTN (
        .clk(oclk_100khz),
        .rst(rst),
        .btn(i_btn),

        .pulse(w_btn_deb)
    );

    edge_detect U_EDGE_BTN (
        .clk  (clk),
        .rst  (rst),
        .pulse(w_btn_deb),

        .o_pulse(o_btn)
    );
endmodule
