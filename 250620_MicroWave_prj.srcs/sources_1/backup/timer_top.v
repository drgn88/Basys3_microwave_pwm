`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/20 18:15:36
// Design Name: 
// Module Name: timer_top
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


module timer_top (
    input clk,
    input rst,
    input btnU,
    input btnD,
    input btn_RS,
    input btnL,
    input btnR,

    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output [4:0] led,
    output [5:0] min_pwm,
    output [5:0] sec_pwm,
    output stop_pwm
);

    wire w_stop;
    wire [1:0] w_sel_time_cnt;
    wire [5:0] w_sec, w_min;
    wire w_tick_10ms;
    wire w_btnU, w_btnD, w_btnL, w_btnR, w_btn_RS;

    assign stop_pwm = w_stop;
    assign min_pwm = w_min;
    assign sec_pwm = w_sec;


    btn_debouncer BTNU (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU),

        .o_btn(w_btnU)
    );

    btn_debouncer BTND (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD),

        .o_btn(w_btnD)
    );
    btn_debouncer BTNL (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL),

        .o_btn(w_btnL)
    );
    btn_debouncer BTNR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),

        .o_btn(w_btnR)
    );
    btn_debouncer BTN_RS (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_RS),

        .o_btn(w_btn_RS)
    );

    timer_cu U_TIMER_CU (
        .clk(clk),
        .rst(rst),
        .sel_L(w_btnL),
        .sel_R(w_btnR),
        .btn_RS(w_btn_RS),

        .sel_time_cnt(w_sel_time_cnt),
        .stop(w_stop),
        .led(led)
    );

    stop_watch_dp U_STOP_DP (
        .clk(clk),
        .rst(rst),
        .stop(w_stop),
        .sel_time_cnt(w_sel_time_cnt),
        .btnU(w_btnU),
        .btnD(w_btnD),

        .sec(w_sec),
        .min(w_min)
    );

    fnd_ctrl U_FND_CTRL (
        .clk(clk),
        .rst(rst),
        .sec(w_sec),
        .min(w_min),

        .fnd_data(fnd_data),
        .fnd_com (fnd_com)
    );
endmodule
