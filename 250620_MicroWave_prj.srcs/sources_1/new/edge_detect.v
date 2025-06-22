`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/19 12:06:44
// Design Name: 
// Module Name: edge_detect
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


module edge_detect (
    input clk,
    input rst,
    input pulse,

    output reg o_pulse
);

    reg inv_pulse;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inv_pulse <= 0;
            o_pulse   <= 0;
        end else begin
            inv_pulse <= pulse;
            o_pulse   <= pulse & (~inv_pulse);
        end
    end

    // ERROR Case(Race Condition)
    // always @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         inv_pulse <= 0;
    //     end else begin
    //         inv_pulse <= pulse;
    //     end
    // end
    
    // assign o_pulse = pulse & (~inv_pulse);

endmodule
