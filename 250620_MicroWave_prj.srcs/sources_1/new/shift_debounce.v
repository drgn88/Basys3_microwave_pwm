`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/19 12:00:46
// Design Name: 
// Module Name: shift_debounce
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


module shift_debounce(
    input clk,
    input rst,
    input btn,

    output pulse
    );

    reg [13:0] par_out;
    

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            par_out <= 0;
        end
        else begin
            //par_out[0] <= btn;
            par_out[0] <= btn;
            par_out[13:1] <= par_out[12:0];
        end
    end

// 교수님 방식
    // reg [7:0] par_out_next;
    // always @(posedge clk or posedge rst) begin
    //     if(rst) begin
    //         par_out <= 0;
    //     end
    //     else begin
    //         par_out <= par_out_next;
    //     end
    // end

    // always @(*) begin
    //     par_out_next = {btn, par_out[7:1]};
    // end

    assign pulse = &par_out;

endmodule
