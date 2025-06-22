`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/22 15:58:46
// Design Name: 
// Module Name: tb_button_debounce
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


module tb_button_debounce;

    // DUT (Design Under Test) 와 연결될 신호 선언
    reg clk;
    reg tick_10ms;
    reg reset;
    reg btn;
    wire btn_debounced;

    // 클럭 주파수 정의
    parameter CLK_PERIOD = 10; // 100MHz (10ns 주기)
    parameter TICK_10MS_PERIOD = 10_000_000; // 100MHz 클럭 기준으로 10ms (100,000,000ns)
                                             // 10ms / 10ns = 1,000,000 클럭 사이클

    // DUT 인스턴스화
    btn_debouncer_10ms dut (
        .clk(clk),
        .tick_10ms(tick_10ms),
        .reset(reset),
        .btn(btn),
        .btn_debounced(btn_debounced)
    );

    // 클럭 생성
    always begin
        # (CLK_PERIOD / 2) clk = ~clk;
    end

    // 초기값 설정 및 시뮬레이션 시퀀스
    initial begin
        // 초기화
        clk = 1'b0;
        tick_10ms = 1'b0;
        reset = 1'b1; // 리셋 활성화
        btn = 1'b0;   // 버튼 초기 상태

        # (CLK_PERIOD * 2); // 초기 리셋 유지

        reset = 1'b0; // 리셋 해제
        $display("------------------------------------");
        $display("Simulation Start");
        $display("Time | clk | tick_10ms | reset | btn | btn_debounced");
        $display("------------------------------------");

        // 시뮬레이션 시퀀스 1: 버튼을 짧게 눌렀다 떼는 경우 (디바운스 시간 내)
        // btn_debounced는 변하지 않아야 함
        # (CLK_PERIOD * 10);
        btn = 1'b1; // 버튼 누름
        $display("%4dns | %b | %b | %b | %b | %b", $time, clk, tick_10ms, reset, btn, btn_debounced);
        # (CLK_PERIOD * 50); // 0.5us 유지 (10ms 미만)
        btn = 1'b0; // 버튼 뗌
        $display("%4dns | %b | %b | %b | %b | %b", $time, clk, tick_10ms, reset, btn, btn_debounced);
        # (CLK_PERIOD * 1000); // 다음 시나리오 대기

        // 시뮬레이션 시퀀스 2: 버튼을 누르고 10ms 이상 유지
        // btn_debounced가 10ms 이후에 1로 변해야 함
        btn = 1'b1; // 버튼 누름
        $display("%4dns | %b | %b | %b | %b | %b", $time, clk, tick_10ms, reset, btn, btn_debounced);
        
        # (TICK_10MS_PERIOD + CLK_PERIOD * 10); // 10ms + 여유 시간 대기 (틱 신호 발생 후)
        $display("%4dns | %b | %b | %b | %b | %b", $time, clk, tick_10ms, reset, btn, btn_debounced); // 10ms 지난 후 상태 확인
        
        // 버튼 떼고 10ms 이상 유지
        btn = 1'b0; // 버튼 뗌
        $display("%4dns | %b | %b | %b | %b | %b", $time, clk, tick_10ms, reset, btn, btn_debounced);
        # (TICK_10MS_PERIOD + CLK_PERIOD * 10); // 10ms + 여유 시간 대기 (틱 신호 발생 후)
        $display("%4dns | %b | %b | %b | %b | %b", $time, clk, tick_10ms, reset, btn, btn_debounced); // 10ms 지난 후 상태 확인

        // 시뮬레이션 종료
        # (CLK_PERIOD * 100);
        $display("------------------------------------");
        $display("Simulation End");
        $finish;
    end

    // 10ms 틱 신호 생성
    initial begin
        # (TICK_10MS_PERIOD); // 첫 번째 틱이 발생하기까지 대기
        forever begin
            tick_10ms = 1'b1;
            # (CLK_PERIOD); // 1틱 동안만 틱 신호 유지
            tick_10ms = 1'b0;
            # (TICK_10MS_PERIOD - CLK_PERIOD); // 다음 틱까지 대기
        end
    end

    // 시뮬레이션 중 변화하는 값 출력 (옵션: 필요에 따라 주석 처리 또는 제거)
    always @(posedge clk) begin
        $display("%4dns | %b | %b | %b | %b | %b", $time, clk, tick_10ms, reset, btn, btn_debounced);
    end

endmodule
