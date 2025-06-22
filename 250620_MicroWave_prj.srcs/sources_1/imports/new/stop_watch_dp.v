`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/16 10:21:08
// Design Name: 
// Module Name: stop_watch
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


module stop_watch_dp (
    input clk,
    input rst,
    input stop,
    input [1:0] sel_time_cnt,
    input btnU,
    input btnD,

    output [5:0] sec,
    output [5:0] min
);
    //parameter BIT_WIDTH = 7;

    wire w_otick_100;
    wire w_otick_msec;
    wire w_otick_sec;
    wire w_otick_min;
    wire w_otick_hour;
    wire w_min_check;

    tick_gen_100hz U_TICK_GEN_100hz (
        .clk(clk & (!stop)),
        .rst(rst),

        .o_tick_100(w_otick_100)
    );

    time_cnt #(
        .TCNT(60),
        .BIT_WIDTH(6),
        .RESET_TIME(59)
    ) U_SEC_CNT (
        .clk(clk),
        .rst(rst),
        .i_tick(w_otick_100),
        .sel_tcnt(sel_time_cnt[0]),
        .btnU(btnU),
        .btnD(btnD),
        .o_time(sec),
        .o_tick(w_otick_sec),

        .min_check(w_min_check),
        .check()
    );

    time_cnt #(
        .TCNT(60),
        .BIT_WIDTH(6),
        .RESET_TIME(0)
    ) U_MIN_CNT (
        .clk(clk),
        .rst(rst),
        .i_tick(w_otick_sec),
        .sel_tcnt(sel_time_cnt[1]),
        .btnU(btnU),
        .btnD(btnD),
        .o_time(min),
        .o_tick(),
        
        .min_check(),
        .check(w_min_check)
    );

endmodule
