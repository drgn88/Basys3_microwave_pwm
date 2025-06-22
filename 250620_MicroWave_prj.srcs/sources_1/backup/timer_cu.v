`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/20 16:41:58
// Design Name: 
// Module Name: timer_cu
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


module timer_cu (
    input clk,
    input rst,
    input sel_L,
    input sel_R,
    input btn_RS,

    output reg [1:0] sel_time_cnt,
    output reg stop,
    output reg [4:0] led
);

    localparam STOP = 0;
    localparam RUN = 1;
    localparam SEL_READY = 2;
    localparam SEL_CHANGE = 3;
    localparam SEL_SET = 4;

    reg [2:0] state, next_state;
    reg [1:0] n_sel_time_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STOP;
            sel_time_cnt <= 2'b00;
        end else begin
            state <= next_state;
            sel_time_cnt <= n_sel_time_cnt;
        end
    end

    
    always @(*) begin
        next_state = state;
        n_sel_time_cnt = sel_time_cnt;
        case (state)
            STOP: begin
                n_sel_time_cnt = 2'b00;
                if (btn_RS) begin
                    next_state = RUN;
                end
                else if(sel_L || sel_R) begin
                    next_state = SEL_SET;
                end
            end 
            RUN : begin
                if(btn_RS) begin
                    next_state = STOP;
                end
            end
            SEL_SET : begin
                n_sel_time_cnt = 2'b01;
                if(sel_L || sel_R) begin
                    next_state = SEL_CHANGE;
                end
                else if(btn_RS) begin
                    next_state = STOP;
                end
            end
            SEL_CHANGE: begin
                n_sel_time_cnt = ~sel_time_cnt;
                next_state = SEL_READY;
            end
            SEL_READY: begin
                if(btn_RS) begin
                    next_state = STOP;
                end
                else if(sel_L||sel_R) begin
                    next_state = SEL_CHANGE;
                end
            end
        endcase
    end

    always @(*) begin
        case (state)
            RUN: stop = 0;
            default: stop = 1;
        endcase
    end

    always @(*) begin
        case (state)
            STOP: led = 5'b00001;
            RUN: led = 5'b00010;
            SEL_READY: led = 5'b00100;
            SEL_CHANGE: led = 5'b01000;
            SEL_SET: led = 5'b10000;
            default: led = 0;
        endcase
    end
endmodule
