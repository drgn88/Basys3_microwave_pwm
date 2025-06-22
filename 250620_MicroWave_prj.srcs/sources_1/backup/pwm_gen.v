`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/20 20:27:33
// Design Name: 
// Module Name: pwm_gen
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


module pwm_gen(
    input clk_10mhz,
    input rst,
    input [5:0] min,
    input [5:0] sec,
    input stop,
    input btnU,
    input btnD,

    output pwm_out
    );

    localparam DUTY = 8;
    localparam MAX_TIME = 10;

    wire lock;
    reg [($clog2(MAX_TIME)- 1): 0] cnt;
    reg r_pwm_out;

    assign lock = ((min || sec) && (!stop)) ? 0 : 1;

    assign pwm_out = ((!lock) & r_pwm_out);

    always @(posedge clk_10mhz or posedge rst) begin
        if(rst) begin
            r_pwm_out <= 0;
            cnt <= 0;
        end
        else if(cnt < (DUTY)) begin
            r_pwm_out <= 1;
            cnt <= cnt + 1;
        end
        else if(cnt == (MAX_TIME - 1)) begin
            cnt <= 0;
        end
        else begin
            r_pwm_out <= 0;
            cnt <= cnt + 1;
        end
    end
endmodule

// module pwm_gen(
//     input clk_10mhz,
//     input rst,
//     input [5:0] min,
//     input [5:0] sec,
//     input stop,

//     output pwm_out
//     );

//     localparam DUTY = 8;
//     localparam MAX_TIME = 10;

//     wire lock;
//     reg [($clog2(MAX_TIME)- 1): 0] cnt;
//     reg r_pwm_out;

//     assign lock = ((min || sec) && (!stop)) ? 0 : 1;

//     assign pwm_out = ((!lock) & r_pwm_out);

//     always @(posedge clk_10mhz or posedge rst) begin
//         if(rst) begin
//             r_pwm_out <= 0;
//             cnt <= 0;
//         end
//         else if(cnt < (DUTY)) begin
//             r_pwm_out <= 1;
//             cnt <= cnt + 1;
//         end
//         else if(cnt == (MAX_TIME - 1)) begin
//             cnt <= 0;
//         end
//         else begin
//             r_pwm_out <= 0;
//             cnt <= cnt + 1;
//         end
//     end
// endmodule