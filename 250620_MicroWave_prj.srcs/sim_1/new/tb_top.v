`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/20 19:46:32
// Design Name: 
// Module Name: tb_top
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


module tb_top;

    // --- DUT (Device Under Test) 입력 신호 선언 ---
    reg clk;
    reg rst;
    reg sel_L;
    reg sel_R;
    reg btn_RS;

    // --- DUT 출력 신호 선언 ---
    wire [1:0] sel_time_cnt;
    wire stop;
    wire [4:0] led;

    // --- 클록 주기 정의 ---
    parameter CLK_PERIOD = 10; // 10ns for 100MHz (1/100MHz = 10ns)

    // --- DUT 인스턴스화 ---
    timer_cu u_timer_cu (
        .clk(clk),
        .rst(rst),
        .sel_L(sel_L),
        .sel_R(sel_R),
        .btn_RS(btn_RS),
        .sel_time_cnt(sel_time_cnt),
        .stop(stop),
        .led(led)
    );

    // --- 클록 생성 ---
    always begin
        # (CLK_PERIOD / 2) clk = ~clk;
    end

    // --- 초기화 및 테스트 시나리오 ---
    initial begin
        // 초기값 설정
        clk = 1'b0;
        rst = 1'b1;     // 리셋 활성화
        sel_L = 1'b0;
        sel_R = 1'b0;
        btn_RS = 1'b0;

        // 리셋 해제
        # (CLK_PERIOD * 2) rst = 1'b0; // 2 클록 주기 동안 리셋 유지

        $display("----------------------------------------");
        $display("         Timer CU Test Scenario         ");
        $display("----------------------------------------");
        $display("Time | State | n_sel_time_cnt | LED    | Stop");
        $display("-----|-------|----------------|--------|------");

        // 1. 초기 STOP 상태 확인
        # (CLK_PERIOD * 2) ; // 안정화 시간
        $display("%4d | STOP  | %h            | %b   | %b", $time, sel_time_cnt, led, stop);
        // 예상: LED 00001 (STOP), stop 1

        // 2. STOP -> RUN (btn_RS 누름)
        # (CLK_PERIOD * 5) btn_RS = 1'b1; // btn_RS 누름
        # (CLK_PERIOD * 1) btn_RS = 1'b0; // btn_RS 뗌 (엣지 트리거)
        # (CLK_PERIOD * 2) ;
        $display("%4d | RUN   | %h            | %b   | %b", $time, sel_time_cnt, led, stop);
        // 예상: LED 00010 (RUN), stop 0

        // 3. RUN -> STOP (btn_RS 다시 누름)
        # (CLK_PERIOD * 10) btn_RS = 1'b1;
        # (CLK_PERIOD * 1) btn_RS = 1'b0;
        # (CLK_PERIOD * 2) ;
        $display("%4d | STOP  | %h            | %b   | %b", $time, sel_time_cnt, led, stop);
        // 예상: LED 00001 (STOP), stop 1

        // 4. STOP -> SEL_SET (sel_L 누름)
        # (CLK_PERIOD * 5) sel_L = 1'b1; // sel_L 누름
        # (CLK_PERIOD * 1) sel_L = 1'b0; // sel_L 뗌
        # (CLK_PERIOD * 2) ;
        $display("%4d | SEL_SET| %h            | %b   | %b", $time, sel_time_cnt, led, stop);
        // 예상: LED 10000 (SEL_SET), sel_time_cnt 01, stop 1

        // 5. SEL_SET -> SEL_CHANGE -> SEL_READY (sel_R 누름)
        // 이 부분에서 "동시에 켜지는" 문제가 해결되는지 확인합니다.
        # (CLK_PERIOD * 5) sel_R = 1'b1; // sel_R 누름 (SEL_CHANGE로 전이)
        # (CLK_PERIOD * 1) sel_R = 1'b0; // sel_R 뗌
        # (CLK_PERIOD * 2) ; // SEL_CHANGE 상태를 거쳐 SEL_READY 상태에 진입
        $display("%4d | SEL_READY| %h            | %b   | %b", $time, sel_time_cnt, led, stop);
        // 예상: LED 00100 (SEL_READY), sel_time_cnt가 토글된 값, stop 1

        // (옵션) 추가적인 상태 전이 테스트: SEL_READY -> SEL_CHANGE -> SEL_READY
        # (CLK_PERIOD * 10) sel_L = 1'b1; // sel_L 다시 누름
        # (CLK_PERIOD * 1) sel_L = 1'b0;
        # (CLK_PERIOD * 2) ;
        $display("%4d | SEL_READY| %h            | %b   | %b", $time, sel_time_cnt, led, stop);
        // 예상: LED 00100 (SEL_READY), sel_time_cnt가 다시 토글된 값, stop 1

        // 6. SEL_READY -> STOP (btn_RS 누름)
        # (CLK_PERIOD * 10) btn_RS = 1'b1;
        # (CLK_PERIOD * 1) btn_RS = 1'b0;
        # (CLK_PERIOD * 2) ;
        $display("%4d | STOP  | %h            | %b   | %b", $time, sel_time_cnt, led, stop);
        // 예상: LED 00001 (STOP), stop 1

        // 시뮬레이션 종료
        # (CLK_PERIOD * 5) $finish;
    end

endmodule