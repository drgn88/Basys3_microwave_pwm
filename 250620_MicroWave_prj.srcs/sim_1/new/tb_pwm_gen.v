`timescale 1ns / 1ps

module tb_pwm_gen;

    // DUT (Design Under Test) 와 연결될 신호 선언
    reg clk;          // 시스템 클록 (100MHz 가정)
    reg clk_10mhz;    // 10MHz 클록 (PWM 생성용)
    reg rst;
    reg [5:0] min;
    reg [5:0] sec;
    reg stop;
    reg btnU;         // 듀티 증가 버튼 (디바운싱된 신호로 가정)
    reg btnD;         // 듀티 감소 버튼 (디바운싱된 신호로 가정)

    wire pwm_out;
    wire [3:0] duty_num;

    // 클럭 주파수 정의
    parameter CLK_PERIOD = 10;     // 100MHz (10ns 주기)
    parameter CLK_10MHZ_PERIOD = 100; // 10MHz (100ns 주기)

    // DUT 인스턴스화
    pwm_gen dut (
        .clk(clk),
        .clk_10mhz(clk_10mhz),
        .rst(rst),
        .min(min),
        .sec(sec),
        .stop(stop),
        .btnU(btnU),
        .btnD(btnD),
        .pwm_out(pwm_out),
        .duty_num(duty_num)
    );

    // 100MHz 클럭 생성
    always begin
        # (CLK_PERIOD / 2) clk = ~clk;
    end

    // 10MHz 클럭 생성
    always begin
        # (CLK_10MHZ_PERIOD / 2) clk_10mhz = ~clk_10mhz;
    end

    // 초기값 설정 및 시뮬레이션 시퀀스
    initial begin
        // 초기화
        clk = 1'b0;
        clk_10mhz = 1'b0;
        rst = 1'b1; // 리셋 활성화
        min = 6'd0;
        sec = 6'd0;
        stop = 1'b0;
        btnU = 1'b0;
        btnD = 1'b0;

        # (CLK_PERIOD * 5); // 초기 리셋 유지

        rst = 1'b0; // 리셋 해제
        $display("------------------------------------------------------------------------------------");
        $display("Simulation Start");
        $display("Time | clk | clk_10mhz | rst | min | sec | stop | btnU | btnD | pwm_out | duty_num");
        $display("------------------------------------------------------------------------------------");

        // --- 검증 시나리오 1: lock 신호 검증 ---
        // min, sec이 모두 0일 때 (초기 상태)
        $display("\n--- Scenario 1.1: min=0, sec=0, stop=0 (PWM should be OFF) ---");
        # (CLK_PERIOD * 10);
        min = 6'd0;
        sec = 6'd0;
        stop = 1'b0; // stop이 0이지만 min/sec가 0이므로 lock=1, pwm_out=0
        # (CLK_10MHZ_PERIOD * 5); // 충분히 대기하여 pwm_out 확인
        
        // min/sec 값이 0이 아닐 때 (PWM ON)
        $display("\n--- Scenario 1.2: min=1, sec=0, stop=0 (PWM should be ON) ---");
        # (CLK_PERIOD * 10);
        min = 6'd1;
        sec = 6'd0;
        stop = 1'b0; // min이 0이 아니므로 lock=0, pwm_out=r_pwm_out
        # (CLK_10MHZ_PERIOD * 5); // 충분히 대기하여 pwm_out 확인 (PWM 파형 확인)

        // stop 신호가 들어올 때 (PWM OFF)
        $display("\n--- Scenario 1.3: min=1, sec=0, stop=1 (PWM should be OFF) ---");
        # (CLK_PERIOD * 10);
        min = 6'd1;
        sec = 6'd0;
        stop = 1'b1; // stop이 1이므로 lock=1, pwm_out=0
        # (CLK_10MHZ_PERIOD * 5); // 충분히 대기하여 pwm_out 확인

        // 다시 정상 동작 (PWM ON)
        $display("\n--- Scenario 1.4: min=1, sec=1, stop=0 (PWM should be ON) ---");
        # (CLK_PERIOD * 10);
        min = 6'd1;
        sec = 6'd1;
        stop = 1'b0;
        # (CLK_10MHZ_PERIOD * 5);

        // --- 검증 시나리오 2: 듀티 값 변화 검증 ---
        $display("\n--- Scenario 2: Duty Cycle Adjustment ---");
        // 초기 듀티는 50% (duty_num=5) 예상

        // 듀티 증가 (btnU)
        $display("\n--- Increasing Duty ---");
        repeat (3) begin // 3번 증가 (5 -> 6 -> 7 -> 8)
            btnU = 1'b1;
            # (CLK_PERIOD * 2); // 버튼 누름 유지 (디바운스된 신호이므로 1클럭만 High해도 됨)
            btnU = 1'b0;
            # (CLK_PERIOD * 50); // 다음 버튼 입력까지 충분히 대기 (duty_num 반영 확인)
        end
        # (CLK_10MHZ_PERIOD * 5); // PWM 파형 변화 확인

        // 듀티 감소 (btnD)
        $display("\n--- Decreasing Duty ---");
        repeat (4) begin // 4번 감소 (8 -> 7 -> 6 -> 5 -> 4)
            btnD = 1'b1;
            # (CLK_PERIOD * 2);
            btnD = 1'b0;
            # (CLK_PERIOD * 50);
        end
        # (CLK_10MHZ_PERIOD * 5); // PWM 파형 변화 확인

        // 듀티 최대값 테스트 (9)
        $display("\n--- Max Duty Test (to 9) ---");
        repeat (6) begin // 현재 4에서 9까지 (4 -> 5 -> ... -> 9)
            btnU = 1'b1;
            # (CLK_PERIOD * 2);
            btnU = 1'b0;
            # (CLK_PERIOD * 50);
        end
        # (CLK_10MHZ_PERIOD * 5); // duty_num이 9가 되고 PWM이 거의 항상 High인지 확인

        // 듀티 최소값 테스트 (0)
        $display("\n--- Min Duty Test (to 0) ---");
        repeat (10) begin // 현재 9에서 0까지 (9 -> 8 -> ... -> 0)
            btnD = 1'b1;
            # (CLK_PERIOD * 2);
            btnD = 1'b0;
            # (CLK_PERIOD * 50);
        end
        # (CLK_10MHZ_PERIOD * 5); // duty_num이 0이 되고 PWM이 항상 Low인지 확인

        // 시뮬레이션 종료
        # (CLK_PERIOD * 100);
        $display("------------------------------------");
        $display("Simulation End");
        $finish;
    end

    // 모든 클럭 상승 엣지마다 주요 신호 값 출력 (디버깅용)
    always @(posedge clk) begin
        $display("%4dns | %b | %b | %b | %6d | %6d | %b | %b | %b | %b | %d",
                 $time, clk, clk_10mhz, rst, min, sec, stop, btnU, btnD, pwm_out, duty_num);
    end

endmodule