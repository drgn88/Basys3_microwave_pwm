`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/20 20:42:52
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input rst,
    input btnU,
    input btnD,
    input btn_RS,
    input btnL,
    input btnR,
    input [1:0] sw,

    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output [4:0] led,
    output [3:0] duty_led,
    output pwm_out,
    output reg [1:0] in1_in2
    );

    wire w_clk_10mhz;
    wire [5:0] w_min_pwm;
    wire [5:0] w_sec_pwm;
    wire w_btnU_pwm, w_btnD_pwm;
    wire w_stop;
    
    always @(*) begin
        case (sw)
            2'b01 : in1_in2 = 2'b01;
            2'b10 : in1_in2 = 2'b10; 
            default: in1_in2 = 2'b00;
        endcase
    end

    clk_div_10mhz U_CLK_DIV_10MHZ(
    .clk(clk),
    .rst(rst),

    .oclk(w_clk_10mhz)
    );

    timer_top U_TIMER(
    .clk(clk),
    .rst(rst),
    .btnU(btnU),
    .btnD(btnD),
    .btn_RS(btn_RS),
    .btnL(btnL),
    .btnR(btnR),

    .fnd_data(fnd_data),
    .fnd_com(fnd_com),
    .led(led),
    .min_pwm(w_min_pwm),
    .sec_pwm(w_sec_pwm),
    .stop_pwm(w_stop),
    .btnU_pwm(w_btnU_pwm),
    .btnD_pwm(w_btnD_pwm)
);

    pwm_gen U_PWM(
    .clk(clk),
    .clk_10mhz(w_clk_10mhz),
    .rst(rst),
    .min(w_min_pwm),
    .sec(w_sec_pwm),
    .stop(w_stop),
    .btnU(w_btnU_pwm),
    .btnD(w_btnD_pwm),

    .pwm_out(pwm_out),
    .duty_num(duty_led)
    );
endmodule
