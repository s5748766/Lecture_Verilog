# 🧩 Digilent Basys3 

<img width="600" height="376" alt="basys-3-2" src="https://github.com/user-attachments/assets/32f80ba8-0add-4b61-a1a8-08d3c30d0bd7" />

### <a href="https://digilent.com/reference/programmable-logic/basys-3/start">Digilent Basys3</a>
   * AMD Artix™ 7 FPGA Trainer Board
   * Features
      * On-chip analog-to-digital converter
   * Key Specifications
      * FPGA Part # XC7A35T-1CPG236C
      * Logic Cells 33,280 in 5200 slices
      * Block RAM 1,800 Kbits
      * DSP Slices 90
      * Internal clock 450 MHz+
   * Connectivity and Onboard I/O
      * Pmod Connectors 3
      * Switches 16
      * Buttons 5
      * User LED 16
      * 7-Seg Display 4-Digit
      * VGA 12-bit
      * USB HID Host (KB/Mouse/Mass Storage)
   * Electrical
      * Power USB 5v (Pins)
      * Logic Level 3.3v


### Basys 3 Abacus Demo


### Basys 3 VGA Pattern Generator

<img width="827" height="627" alt="vga_001" src="https://github.com/user-attachments/assets/2f804cfd-6d39-459f-a721-455779fb1d30" />
<br>
<img width="814" height="389" alt="vga_002" src="https://github.com/user-attachments/assets/ae011cfc-9a2c-4376-bc60-b3dad438e386" />
<br>

<img width="771" height="372" alt="vga_timing_001" src="https://github.com/user-attachments/assets/ce4594bb-a70c-4854-90a2-7f7a72c95836" />
<br>
<img width="758" height="147" alt="vga_timing_002" src="https://github.com/user-attachments/assets/010bc287-b433-4d71-a1fa-a7e4bfedc50f" />
<br>
<img width="717" height="707" alt="vga_timing_003" src="https://github.com/user-attachments/assets/9467e56a-32d6-41a1-b90a-1b8019415282" />
<br>
<img width="674" height="182" alt="vga_timing_004" src="https://github.com/user-attachments/assets/0715d805-37d9-424f-bb67-1f1e227d665d" />
<br>
<img width="603" height="505" alt="vga_timing_005" src="https://github.com/user-attachments/assets/6497a716-d4bf-428d-9f8f-b8bf0e88bf54" />
<br>
<img width="579" height="373" alt="vga_timing_006" src="https://github.com/user-attachments/assets/5b898d84-84fe-4417-9ec0-dadc8e2f023e" />
<br>


```verilog
VGA Pattern

module vga_colorbar_top(
    input clk,          // 100MHz 클럭
    input reset,        // 리셋 신호
    output [3:0] vga_r, // VGA 빨간색 (4비트)
    output [3:0] vga_g, // VGA 초록색 (4비트)
    output [3:0] vga_b, // VGA 파란색 (4비트)
    output vga_hsync,   // 수평 동기 신호
    output vga_vsync    // 수직 동기 신호
);

    // 내부 신호들
    wire clk_25MHz;         // 25MHz VGA 클럭
    wire [9:0] h_count;     // 수평 픽셀 카운터
    wire [9:0] v_count;     // 수직 라인 카운터
    wire video_on;          // 비디오 활성 영역 신호
    wire [11:0] rgb_out;    // RGB 출력 (각각 4비트)

    // 클럭 분주기 - 100MHz를 25MHz로 변환
    clk_divider clk_div_inst (
        .clk_in(clk),
        .reset(reset),
        .clk_out(clk_25MHz)
    );

    // VGA 타이밍 생성기
    vga_timing vga_timing_inst (
        .clk(clk_25MHz),
        .reset(reset),
        .h_count(h_count),
        .v_count(v_count),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .video_on(video_on)
    );

    // 컬러바 패턴 생성기
    colorbar_generator colorbar_gen_inst (
        .h_count(h_count),
        .v_count(v_count),
        .video_on(video_on),
        .rgb_out(rgb_out)
    );

    // RGB 출력 할당
    assign vga_r = rgb_out[11:8];
    assign vga_g = rgb_out[7:4];
    assign vga_b = rgb_out[3:0];

endmodule

// 클럭 분주기 모듈
module clk_divider(
    input clk_in,       // 100MHz 입력 클럭
    input reset,
    output reg clk_out  // 25MHz 출력 클럭
);
   
    reg [1:0] counter;
   
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            counter <= counter + 1;
            if (counter == 1) begin  // 100MHz / 4 = 25MHz
                clk_out <= ~clk_out;
                counter <= 0;
            end
        end
    end
   
endmodule

// VGA 타이밍 생성기
module vga_timing(
    input clk,              // 25MHz 클럭
    input reset,
    output reg [9:0] h_count,   // 수평 픽셀 카운터
    output reg [9:0] v_count,   // 수직 라인 카운터
    output reg hsync,           // 수평 동기 신호
    output reg vsync,           // 수직 동기 신호
    output video_on             // 비디오 활성 영역
);

    // VGA 640x480 @ 60Hz 타이밍 파라미터
    localparam H_DISPLAY = 640;     // 수평 디스플레이 영역
    localparam H_FRONT = 16;        // 수평 프론트 포치
    localparam H_SYNC = 96;         // 수평 동기 펄스
    localparam H_BACK = 48;         // 수평 백 포치
    localparam H_TOTAL = 800;       // 총 수평 픽셀
   
    localparam V_DISPLAY = 480;     // 수직 디스플레이 영역
    localparam V_FRONT = 10;        // 수직 프론트 포치
    localparam V_SYNC = 2;          // 수직 동기 펄스
    localparam V_BACK = 33;         // 수직 백 포치
    localparam V_TOTAL = 525;       // 총 수직 라인
   
    // 수평 및 수직 카운터
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end
   
    // 동기 신호 생성
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            hsync <= 1;
            vsync <= 1;
        end else begin
            // 수평 동기 (negative polarity)
            hsync <= ~((h_count >= H_DISPLAY + H_FRONT) &&
                      (h_count < H_DISPLAY + H_FRONT + H_SYNC));
           
            // 수직 동기 (negative polarity)
            vsync <= ~((v_count >= V_DISPLAY + V_FRONT) &&
                      (v_count < V_DISPLAY + V_FRONT + V_SYNC));
        end
    end
   
    // 비디오 활성 영역 신호
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
   
endmodule

// 컬러바 패턴 생성기
module colorbar_generator(
    input [9:0] h_count,    // 수평 픽셀 위치
    input [9:0] v_count,    // 수직 픽셀 위치
    input video_on,         // 비디오 활성 영역
    output reg [11:0] rgb_out   // RGB 출력 (4:4:4)
);

    // 컬러바 너비 (640/8 = 80픽셀)
    localparam BAR_WIDTH = 80;
   
    always @(*) begin
        if (!video_on) begin
            rgb_out = 12'h000;  // 비활성 영역은 검은색
        end else begin
            // 수평 위치에 따라 컬러바 결정
            case (h_count / BAR_WIDTH)
                0: rgb_out = 12'hFFF;  // 흰색
                1: rgb_out = 12'hFF0;  // 노란색
                2: rgb_out = 12'h0FF;  // 시안색
                3: rgb_out = 12'h0F0;  // 초록색
                4: rgb_out = 12'hF0F;  // 마젠타색
                5: rgb_out = 12'hF00;  // 빨간색
                6: rgb_out = 12'h00F;  // 파란색
                7: rgb_out = 12'h000;  // 검은색
                default: rgb_out = 12'h000;
            endcase
        end
    end
   
endmodule
```
