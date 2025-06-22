`timescale 1ns / 1ps

module tb_timer_cu;

    // DUT (Design Under Test) 와 연결될 신호 선언
    reg clk;
    reg rst;
    reg sel_L;      // 디바운싱된 신호로 가정
    reg sel_R;      // 디바운싱된 신호로 가정
    reg btn_RS;     // 디바운싱된 신호로 가정

    wire [1:0] sel_time_cnt;
    wire stop;
    wire [4:0] led;

    // 클럭 주파수 정의
    parameter CLK_PERIOD = 10; // 100MHz (10ns 주기)

    // DUT 인스턴스화
    timer_cu dut (
        .clk(clk),
        .rst(rst),
        .sel_L(sel_L),
        .sel_R(sel_R),
        .btn_RS(btn_RS),
        .sel_time_cnt(sel_time_cnt),
        .stop(stop),
        .led(led)
    );

    // 클럭 생성
    always begin
        # (CLK_PERIOD / 2) clk = ~clk;
    end

    // 초기값 설정 및 시뮬레이션 시퀀스
    initial begin
        // 초기화
        clk = 1'b0;
        rst = 1'b1; // 리셋 활성화
        sel_L = 1'b0;
        sel_R = 1'b0;
        btn_RS = 1'b0;

        # (CLK_PERIOD * 5); // 초기 리셋 유지 (안정화)

        rst = 1'b0; // 리셋 해제
        $display("------------------------------------------------------------------------------------");
        $display("Simulation Start for timer_cu");
        $display("Time | clk | rst | sel_L | sel_R | btn_RS | state | sel_time_cnt | stop | led");
        $display("------------------------------------------------------------------------------------");
        
        // 리셋 해제 후 STOP 상태 확인 (초기 상태)
        # (CLK_PERIOD * 2);
        $display("Current State: STOP");

        // --- Scenario 1: STOP -> RUN -> STOP ---
        $display("\n--- Scenario 1: STOP -> RUN -> STOP ---");
        // STOP 상태에서 btn_RS 눌러 RUN으로 전이
        btn_RS = 1'b1;
        # (CLK_PERIOD); // btn_RS 인가
        btn_RS = 1'b0; // btn_RS 해제
        # (CLK_PERIOD); // 상태 전이 확인
        $display("Current State: RUN");

        // RUN 상태에서 btn_RS 눌러 STOP으로 전이
        btn_RS = 1'b1;
        # (CLK_PERIOD); // btn_RS 인가
        btn_RS = 1'b0; // btn_RS 해제
        # (CLK_PERIOD); // 상태 전이 확인
        $display("Current State: STOP");
        
        // --- Scenario 2: STOP -> SEL_SET -> STOP ---
        $display("\n--- Scenario 2: STOP -> SEL_SET -> STOP ---");
        // STOP 상태에서 sel_L 눌러 SEL_SET으로 전이
        sel_L = 1'b1;
        # (CLK_PERIOD); // sel_L 인가
        sel_L = 1'b0; // sel_L 해제
        # (CLK_PERIOD); // 상태 전이 확인
        $display("Current State: SEL_SET");
        
        // SEL_SET 상태에서 btn_RS 눌러 STOP으로 전이
        btn_RS = 1'b1;
        # (CLK_PERIOD); // btn_RS 인가
        btn_RS = 1'b0; // btn_RS 해제
        # (CLK_PERIOD); // 상태 전이 확인
        $display("Current State: STOP");

        // --- Scenario 3: STOP -> SEL_SET -> SEL_CHANGE -> SEL_READY -> STOP ---
        $display("\n--- Scenario 3: STOP -> SEL_SET -> SEL_CHANGE -> SEL_READY -> STOP ---");
        // STOP 상태에서 sel_R 눌러 SEL_SET으로 전이
        sel_R = 1'b1;
        # (CLK_PERIOD);
        sel_R = 1'b0;
        # (CLK_PERIOD); // -> SEL_SET
        $display("Current State: SEL_SET");

        // SEL_SET 상태에서 sel_L 눌러 SEL_CHANGE로 전이
        sel_L = 1'b1;
        # (CLK_PERIOD);
        sel_L = 1'b0;
        # (CLK_PERIOD); // -> SEL_CHANGE
        $display("Current State: SEL_CHANGE");

        // SEL_CHANGE는 항상 다음 사이클에 SEL_READY로 전이
        # (CLK_PERIOD); // -> SEL_READY
        $display("Current State: SEL_READY");
        
        // SEL_READY 상태에서 btn_RS 눌러 STOP으로 전이
        btn_RS = 1'b1;
        # (CLK_PERIOD);
        btn_RS = 1'b0;
        # (CLK_PERIOD); // -> STOP
        $display("Current State: STOP");

        // --- Scenario 4: SEL_READY -> SEL_CHANGE (looping sel_time_cnt) ---
        $display("\n--- Scenario 4: SEL_READY -> SEL_CHANGE (looping sel_time_cnt) ---");
        // STOP -> SEL_SET -> SEL_CHANGE -> SEL_READY (sel_time_cnt = 2'b01)
        sel_R = 1'b1; # (CLK_PERIOD); sel_R = 1'b0; # (CLK_PERIOD); // SEL_SET
        sel_L = 1'b1; # (CLK_PERIOD); sel_L = 1'b0; # (CLK_PERIOD); // SEL_CHANGE
        # (CLK_PERIOD); // SEL_READY (sel_time_cnt = 2'b01)
        $display("Current State: SEL_READY, sel_time_cnt: %b", sel_time_cnt);
        
        // SEL_READY에서 sel_R 눌러 SEL_CHANGE -> SEL_READY (sel_time_cnt 토글)
        sel_R = 1'b1;
        # (CLK_PERIOD);
        sel_R = 1'b0;
        # (CLK_PERIOD); // -> SEL_CHANGE
        $display("Current State: SEL_CHANGE");
        # (CLK_PERIOD); // -> SEL_READY (sel_time_cnt = ~01 = 10)
        $display("Current State: SEL_READY, sel_time_cnt: %b", sel_time_cnt);

        // SEL_READY에서 sel_L 눌러 SEL_CHANGE -> SEL_READY (sel_time_cnt 토글)
        sel_L = 1'b1;
        # (CLK_PERIOD);
        sel_L = 1'b0;
        # (CLK_PERIOD); // -> SEL_CHANGE
        $display("Current State: SEL_CHANGE");
        # (CLK_PERIOD); // -> SEL_READY (sel_time_cnt = ~10 = 01)
        $display("Current State: SEL_READY, sel_time_cnt: %b", sel_time_cnt);
        
        // SEL_READY에서 btn_RS 눌러 STOP으로
        btn_RS = 1'b1;
        # (CLK_PERIOD);
        btn_RS = 1'b0;
        # (CLK_PERIOD); // -> STOP
        $display("Current State: STOP");

        // 시뮬레이션 종료
        # (CLK_PERIOD * 10);
        $display("------------------------------------");
        $display("Simulation End");
        $finish;
    end

    // 상태 및 출력 변화 감지 및 출력
    // next_state를 직접 출력하는 대신, 현재 state와 그에 따른 출력을 확인
    always @(posedge clk) begin
        // 상태 전이를 명확히 하기 위해 각 클럭 사이클의 끝에서 값을 출력합니다.
        // next_state는 조합 로직의 결과이므로 직접 @(posedge clk)에서 레지스터 state 값으로 확인
        // led 값은 state에 따라 조합적으로 바로 변하므로 함께 확인
        $display("%4dns | %b | %b | %b | %b | %b | %d | %b | %b | %b",
                 $time, clk, rst, sel_L, sel_R, btn_RS, dut.state, sel_time_cnt, stop, led);
    end

endmodule