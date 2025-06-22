`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/16 10:24:01
// Design Name: 
// Module Name: time_cnt
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


module time_cnt #(
    parameter TCNT = 60,
    parameter BIT_WIDTH = 6,
    parameter RESET_TIME = 59
) (
    input clk,
    input rst,
    input i_tick,
    input sel_tcnt,
    input btnU,
    input btnD,
    input min_check,

    output reg [BIT_WIDTH - 1:0] o_time,
    output o_tick,
    output check
);

    reg [($clog2(TCNT) - 1):0] tcnt, tcnt_next;
    reg rotick, rotick_next;


    //State register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rotick <= 0;
            tcnt   <= RESET_TIME;
            //오류코드: (rst아닐때 문제 --> 정의안됨)
            //o_time <= 0;

        end else begin
            tcnt   <= tcnt_next;
            rotick <= rotick_next;
        end
    end

    //Next state logic
    // always @(*) begin
    //     if (i_tick && (tcnt != 0)) begin
    //         tcnt_next   = tcnt - 1;
    //         rotick_next = 0;
    //     end else if (i_tick && (tcnt == 0)) begin
    //         tcnt_next   = RESET_TIME;  
    //         rotick_next = 1;
    //     end else begin
    //         tcnt_next   = tcnt;
    //         rotick_next = 0;
    //     end
    // end

    // always @(*) begin
    //     if(sel_tcnt && btnU) begin
    //         if(tcnt == (TCNT - 1)) begin
    //             tcnt_next = tcnt;
    //         end
    //         else begin
    //             tcnt_next = tcnt + 1;
    //         end
    //     end
    //     else if(sel_tcnt && btnD) begin
    //         if(tcnt == 0) begin
    //             tcnt_next = tcnt;
    //         end
    //         else begin
    //             tcnt_next = tcnt - 1;
    //         end
    //     end
    //     else begin
    //         tcnt_next = tcnt;
    //     end
    // end

    always @(*) begin
        // 기본값 설정 (어떤 조건도 만족하지 않을 경우 유지)
        tcnt_next   = tcnt;
        rotick_next = 1'b0;  // 기본적으로 rotick은 0으로 설정

        // 1. 버튼 조작 로직 (우선순위 높게 설정)
        if (sel_tcnt) begin
            if (btnU) begin
                if (tcnt == (TCNT - 1)) begin
                    tcnt_next = tcnt;  // 최대값에서는 증가하지 않음
                end else begin
                    tcnt_next = tcnt + 1;
                end
            end else if (btnD) begin
                if (tcnt == 0) begin
                    tcnt_next = tcnt;  // 최소값에서는 감소하지 않음
                end else begin
                    tcnt_next = tcnt - 1;
                end
            end
        end  // 2. 타이머 틱 로직 (버튼 조작이 없을 때만 작동)
             // 버튼 조작이 활성화되지 않았을 때만 틱 로직을 적용
        else if (i_tick) begin
            if (tcnt != 0) begin
                tcnt_next = tcnt - 1;
                // rotick_next는 0으로 유지
            end else if (!tcnt) begin  // tcnt == 0
                if (!min_check) begin
                    tcnt_next   = 0;
                    rotick_next = 1'b1;  // 틱 리셋 시 rotick 발생
                end else begin
                    tcnt_next   = RESET_TIME;
                    rotick_next = 1'b1;  // 틱 리셋 시 rotick 발생
                end
            end
        end
        // else (i_tick도 아니고 sel_tcnt도 아닐 때)
        // tcnt_next는 tcnt로 유지되고 rotick_next는 0으로 유지 (초기 설정된 기본값)
    end

    //Output logic(내방식)
    // always @(posedge clk) begin
    //     if(tcnt == (TCNT - 1)) begin
    //         o_tick <= 1; 
    //     end
    //     else begin
    //         o_tick <= 0;
    //     end
    // end

    always @(*) begin
        if (tcnt == 0) begin
            o_time = 0;
        end else begin
            o_time = tcnt;
        end
    end

    assign o_tick = rotick;

    assign check  = (!o_time) ? 0 : 1;
endmodule
