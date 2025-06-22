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
    input clk,          // 시스템 클록 (버튼 입력 및 DUTY_VALUE 조절용)
    input clk_10mhz,    // 10MHz 클록 (PWM 생성용)
    input rst,
    input [5:0] min,
    input [5:0] sec,
    input stop,
    input btnU,         // 듀티 증가 버튼 (디바운싱된 신호여야 함!)
    input btnD,         // 듀티 감소 버튼 (디바운싱된 신호여야 함!)

    output pwm_out,
    output [3:0] duty_num
);

    localparam MAX_TIME = 10; // PWM 주기 (0부터 9까지 총 10클록)

    // 내부 신호 및 레지스터 선언
    wire lock;
    
    // clk 도메인에서 버튼에 의해 조절될 듀티 값
    reg [3:0] DUTY_VALUE_clk_domain; 
    
    // clk_10mhz 도메인으로 동기화될 듀티 값 (2단 플립플롭)
    reg [3:0] DUTY_VALUE_sync_q1;
    reg [3:0] DUTY_VALUE_sync_q2;
    
    // PWM 생성 로직에서 사용할 최종 동기화된 듀티 값
    wire [3:0] DUTY_VALUE_for_pwm; 

    reg [($clog2(MAX_TIME)- 1): 0] cnt; // PWM 카운터 (MAX_TIME=10이므로 4비트)
    reg r_pwm_out; // 내부 PWM 출력 신호

    // 외부로 출력될 듀티 값은 clk 도메인의 최신 값을 보여줍니다.
    assign duty_num = DUTY_VALUE_clk_domain;

    // lock 신호 정의: min/sec가 0이 아니고 stop이 0일 때 (타이머 동작 중일 때) lock이 0이 됨
    // lock이 0이어야 PWM이 활성화됩니다.
    assign lock = ((min != 6'b000000) || (sec != 6'b000000)) && (!stop) ? 0 : 1;

    // 최종 PWM 출력: lock이 0일 때만 내부 PWM 신호 r_pwm_out을 출력
    assign pwm_out = ((!lock) & r_pwm_out);

    // 듀티 값 (DUTY_VALUE_clk_domain) 조절 로직 (System Clock clk 동기화)
    // 이 블록은 clk에 동기화되어 버튼 입력에 따라 DUTY_VALUE를 0~9 범위 내에서 증가/감소시킵니다.
    // btnU/btnD는 디바운싱된 신호여야 합니다.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            DUTY_VALUE_clk_domain <= 4'd5; // 리셋 시 초기 듀티를 5 (50%)로 설정
        end else if (btnU) begin
            // 듀티 증가 (최대값 MAX_TIME-1 = 9까지)
            if (DUTY_VALUE_clk_domain < (MAX_TIME - 1)) begin
                DUTY_VALUE_clk_domain <= DUTY_VALUE_clk_domain + 1;
            end
            // else: DUTY_VALUE가 이미 최대값이면 그대로 유지
        end else if (btnD) begin
            // 듀티 감소 (최소값 0까지)
            if (DUTY_VALUE_clk_domain > 4'd0) begin
                DUTY_VALUE_clk_domain <= DUTY_VALUE_clk_domain - 1;
            end
            // else: DUTY_VALUE가 이미 최소값이면 그대로 유지
        end
    end

    // 클록 도메인 교차 동기화 로직 (clk -> clk_10mhz)
    // clk 도메인의 DUTY_VALUE_clk_domain을 clk_10mhz 도메인으로 안전하게 전달하기 위한 2단 플립플롭 동기화기입니다.
    // 이는 메타스테이블 문제를 방지합니다.
    always @(posedge clk_10mhz or posedge rst) begin
        if (rst) begin
            DUTY_VALUE_sync_q1 <= 4'd5; // 리셋 값은 DUTY_VALUE_clk_domain과 일치시키는 것이 좋음
            DUTY_VALUE_sync_q2 <= 4'd5;
        end else begin
            // 첫 번째 단 (clk_10mhz에 비동기적으로 들어온 신호를 동기화 시도)
            DUTY_VALUE_sync_q1 <= DUTY_VALUE_clk_domain; // 이 지점에서 잠재적 메타스테이블 발생 가능

            // 두 번째 단 (메타스테이블이 발생하더라도 여기서 안정화될 확률이 높음)
            DUTY_VALUE_sync_q2 <= DUTY_VALUE_sync_q1;
        end
    end

    // PWM 로직은 이 동기화된 값을 사용합니다.
    assign DUTY_VALUE_for_pwm = DUTY_VALUE_sync_q2;
    
    // PWM 생성 로직 (10MHz Clock clk_10mhz 동기화)
    // 이 블록은 clk_10mhz에 동기화되어 카운터(cnt)와 PWM 출력(r_pwm_out)을 제어합니다.
    // 이제 DUTY_VALUE_for_pwm (동기화된 값)을 사용하여 듀티 사이클을 결정합니다.
    always @(posedge clk_10mhz or posedge rst) begin
        if (rst) begin
            r_pwm_out <= 1'b0; // 리셋 시 PWM 출력 0
            cnt       <= 0;    // 카운터 리셋
        end
        // 현재 DUTY_VALUE_for_pwm에 따라 PWM HIGH/LOW 구간 결정
        else if (cnt < DUTY_VALUE_for_pwm) begin // cnt가 동기화된 듀티 값보다 작으면 HIGH
            r_pwm_out <= 1'b1;
            cnt       <= cnt + 1;
        end
        else begin // cnt가 동기화된 듀티 값 이상이면 LOW
            r_pwm_out <= 1'b0;
            if (cnt == (MAX_TIME - 1)) begin // 카운터가 주기의 끝에 도달하면 리셋
                cnt <= 0;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

endmodule


// module pwm_gen(
//     input clk,
//     input clk_10mhz,   // 10MHz 클록 (PWM 및 듀티 조절 로직용)
//     input rst,
//     input [5:0] min,
//     input [5:0] sec,
//     input stop,
//     input btnU,        // 듀티 증가 버튼 (디바운싱된 신호여야 함!)
//     input btnD,        // 듀티 감소 버튼 (디바운싱된 신호여야 함!)

//     output pwm_out,
//     output [3:0] duty_num
// );

//     // localparam DUTY = 8; // 이 파라미터는 이제 DUTY_VALUE 레지스터가 대신합니다.
//     localparam MAX_TIME = 10; // PWM 주기 (0부터 9까지 총 10클록)
    
//     wire lock;
//     reg [3:0] DUTY_VALUE; // 버튼으로 조절될 듀티 값 (0~9 범위)
//     reg [($clog2(MAX_TIME)- 1): 0] cnt; // PWM 카운터 (MAX_TIME=10이므로 4비트)
//     reg r_pwm_out; // 내부 PWM 출력 신호

//     assign duty_num = DUTY_VALUE;

//     // lock 신호 정의: min/sec가 0이 아니고 stop이 0일 때 (타이머 동작 중일 때) lock이 0이 됨
//     // lock이 0이어야 PWM이 활성화됩니다.
//     assign lock = ((min != 6'b000000) || (sec != 6'b000000)) && (!stop) ? 0 : 1;

//     // 최종 PWM 출력: lock이 0일 때만 내부 PWM 신호 r_pwm_out을 출력
//     assign pwm_out = ((!lock) & r_pwm_out);

//     // --- 듀티 값 (DUTY_VALUE) 조절 로직 ---
//     // 버튼 입력에 따라 DUTY_VALUE를 0~9 범위 내에서 증가/감소 시킴
//     // clk_10mhz에 동기화되며, btnU/btnD는 디바운싱된 신호여야 합니다!
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             DUTY_VALUE <= 4'd5; // 리셋 시 초기 듀티를 5 (50%)로 설정
//         end else if (btnU) begin
//             // 듀티 증가 (최대값 MAX_TIME-1 = 9까지)
//             if (DUTY_VALUE < (MAX_TIME - 1)) begin
//                 DUTY_VALUE <= DUTY_VALUE + 1;
//             end
//             // else: DUTY_VALUE가 이미 최대값이면 그대로 유지
//         end else if (btnD) begin
//             // 듀티 감소 (최소값 0까지)
//             if (DUTY_VALUE > 4'd0) begin
//                 DUTY_VALUE <= DUTY_VALUE - 1;
//             end
//             // else: DUTY_VALUE가 이미 최소값이면 그대로 유지
//         end
//     end

//     // --- PWM 생성 로직 ---
//     // cnt와 r_pwm_out을 제어하여 PWM 신호를 생성
//     always @(posedge clk_10mhz or posedge rst) begin
//         if (rst) begin
//             r_pwm_out <= 1'b0; // 리셋 시 PWM 출력 0
//             cnt       <= 0;    // 카운터 리셋
//         end
//         // 현재 DUTY_VALUE에 따라 PWM HIGH/LOW 구간 결정
//         else if (cnt < DUTY_VALUE) begin // cnt가 DUTY_VALUE보다 작으면 HIGH
//             r_pwm_out <= 1'b1;
//             cnt       <= cnt + 1;
//         end
//         else begin // cnt가 DUTY_VALUE 이상이면 LOW
//             r_pwm_out <= 1'b0;
//             if (cnt == (MAX_TIME - 1)) begin // 카운터가 주기의 끝에 도달하면 리셋
//                 cnt <= 0;
//             end
//             else begin
//                 cnt <= cnt + 1;
//             end
//         end
//     end

// endmodule

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