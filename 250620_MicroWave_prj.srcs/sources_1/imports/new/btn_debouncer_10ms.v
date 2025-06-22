`timescale 1ns / 1ps

module btn_debouncer_10ms (
    input clk,          // 100MHz 시스템 클럭
    input tick_10ms,    // 10ms마다 발생하는 틱 신호
    input reset,        // 비동기 리셋
    input btn,          // 디바운싱할 버튼 입력
    output reg btn_debounced // 디바운싱된 버튼 출력 (100MHz 클럭 동기, 1틱)
);

parameter DEBOUNCE_TIME_MS = 10; // 디바운스 시간 (ms) - 참고용

reg btn_reg;                // 버튼 입력의 동기화 레지스터
reg btn_previous;           // 이전 버튼 값 저장
reg debounce_active;        // 디바운스 동작 중임을 나타내는 플래그
reg delayed_btn_state;      // 10ms 지연 후의 버튼 상태 저장

// 버튼 입력 동기화 (클럭 도메인 교차 문제 방지)
always @(posedge clk or posedge reset) begin
    if (reset) begin
        btn_reg <= 1'b0;
    end else begin
        btn_reg <= btn;
    end
end

// 메인 디바운스 로직
always @(posedge clk or posedge reset) begin
    if (reset) begin
        btn_debounced <= 1'b0;      // 펄스 출력은 초기 0
        btn_previous <= 1'b0;
        debounce_active <= 1'b0;
        delayed_btn_state <= 1'b0;  // 지연된 버튼 상태도 초기 0
    end else begin
        // 1. 버튼 상승 엣지 감지
        if (btn_reg == 1'b1 && btn_previous == 1'b0) begin
            debounce_active <= 1'b1; // 디바운스 시작
        end
        
        // 2. 10ms 틱을 이용한 디바운싱 타이머 및 상태 캡처
        // debounce_active가 활성화된 상태에서 tick_10ms가 오면
        // 그 순간의 btn_reg 값을 delayed_btn_state에 저장
        if (debounce_active && tick_10ms) begin
            delayed_btn_state <= btn_reg; // 10ms 지난 후의 버튼 값 저장
            debounce_active <= 1'b0;      // 디바운스 완료
			btn_debounced <= 1'b1;
        end
		else begin
			btn_debounced <= 1'b0;
		end
        
        
        // 4. 이전 버튼 값 업데이트
        btn_previous <= btn_reg;
    end
end

endmodule