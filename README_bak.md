# MicroWave w PWM (Using Basys3)

## Who Made?

|                                                                                                                               최현우                                                                                                                                |
| :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| [<img src="https://i.namu.wiki/i/cLupG68GKbCFDZZkKDQMcSibBwYWjPsM-V5g6lKyn1ZZEfacmj7frqiah3mc2XxnYRzl6k_MEE8vG-ryo_5BDj5iPseh54x0U891uQNfIEXz74kWUsErKgxWXD1dAT1xWjWmhRhsOVFiR-Lc7bdSxQ.webp" width=150 height=150> </br> @Hyenwoo_Choi](https://github.com/drgn88) |

## Develop Environment

### SW Tool
|                        Vivado                         |                        Vscode                         |
| :---------------------------------------------------: | :---------------------------------------------------: |
| <img src="./img/vivado_img.png" width=150 height=150> | <img src="./img/vscode_img.png" width=150 height=150> |


### HW
|                                                                  Basys3                                                                  |
| :--------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://www.amd.com/content/dam/amd/en/images/products/boards/2410750-artix-7-xc7a35t-board-product.jpg" width=300 height=300> |

## Development Period

### Project 기간

- **전체 개발 기간**: 250620 ~ 250622
- **HW 기획**: 250620
- **HW 개발**: 250621~250622
- **발표자료 준비**: 250622

# 개요

## 기능

- 타이머로 전자레인지 시간 조정
- 버튼으로 타이머 및 PWM(전자레인지 속도) 조절
- 버튼
  - btnC: Run/Stop
  - btnU: 타이머 UP/ PWM UP
  - btnD: 타이머 Down/ PWM Down
  - btnL: 선택 시간 이동(좌)
  - btnR: 선택 시간 이동(우)
- Switch[1:0]
  - 01: 정방향 모터 회전
  - 10: 역방향 모터 회전
  - 그외: 모터 멈춤
- Switch[15]
  - Reset

