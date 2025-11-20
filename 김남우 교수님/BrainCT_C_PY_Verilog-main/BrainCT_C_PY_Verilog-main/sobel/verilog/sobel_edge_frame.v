// C:\Users\Administrator\Desktop\sobel\chatgpt\01\verilog\sobel_edge_frame.v
`timescale 1ns/1ps
`default_nettype none

module sobel_edge_frame #(
    parameter W = 630,
    parameter H = 630
)(
    input  wire        clk,
    input  wire        rst_n,

    input  wire        in_valid,     // 8-bit grayscale stream
    input  wire [7:0]  in_pixel,

    output reg         out_valid,    // 8-bit edge stream
    output reg  [7:0]  out_pixel
);
    // 프레임 버퍼 (C/Python과 동일한 행우선 상→하, 좌→우)
    reg [7:0] frame [0:W*H-1];

    reg [31:0] wr_cnt;    // 0..W*H-1
    reg [31:0] rd_cnt;    // 0..W*H-1
    reg        writing;   // 입력 수집 단계
    reg        processing;// 소벨 처리 단계

    // 임시(Verilog-2001: 상단 선언)
    integer x, y;
    integer xm1, xp1, ym1, yp1;
    integer idx00, idx01, idx02;
    integer idx10, idx11, idx12;
    integer idx20, idx21, idx22;
    integer gx, gy;
    integer magsq;
    integer mag;

    // ---- 정확한 sqrt 바닥값: 결과 범위 0..255 에서 이진 탐색 ----
    // (C의 (int)sqrt(...)와 비트 단위로 일치)
    function [8:0] sqrt_floor_8;
        input [31:0] s;   // <= 2,080,800 (Sobel 한계)
        integer lo, hi, mid;
        begin
            lo = 0; hi = 255;
            while (lo <= hi) begin
                mid = (lo + hi) >> 1;
                if (mid*mid <= s)
                    lo = mid + 1;
                else
                    hi = mid - 1;
            end
            sqrt_floor_8 = hi[8:0]; // floor(sqrt(s))
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_cnt    <= 0;
            rd_cnt    <= 0;
            writing   <= 1'b1;
            processing<= 1'b0;
            out_valid <= 1'b0;
            out_pixel <= 8'd0;
        end else begin
            out_valid <= 1'b0;

            // 1) 프레임 수집
            if (writing) begin
                if (in_valid) begin
                    frame[wr_cnt] <= in_pixel;
                    if (wr_cnt == W*H-1) begin
                        writing    <= 1'b0;
                        processing <= 1'b1;
                        rd_cnt     <= 0;
                    end
                    wr_cnt <= wr_cnt + 1;
                end
            end

            // 2) 프레임 처리 (경계 클램프 + Sobel + 정확 sqrt)
            if (processing) begin
                x = rd_cnt % W;
                y = rd_cnt / W;

                // 경계 클램프(getPixel 동작과 동일)
                xm1 = (x > 0)   ? x-1 : 0;
                xp1 = (x < W-1) ? x+1 : W-1;
                ym1 = (y > 0)   ? y-1 : 0;
                yp1 = (y < H-1) ? y+1 : H-1;

                idx00 = ym1*W + xm1;  idx01 = ym1*W + x;   idx02 = ym1*W + xp1;
                idx10 = y  *W + xm1;  idx11 = y  *W + x;   idx12 = y  *W + xp1;
                idx20 = yp1*W + xm1;  idx21 = yp1*W + x;   idx22 = yp1*W + xp1;

                // Sobel (C 코드와 동일)
                gx = -frame[idx00] + frame[idx02]
                     - (frame[idx10]<<1) + (frame[idx12]<<1)
                     - frame[idx20] + frame[idx22];

                gy = -frame[idx00] - (frame[idx01]<<1) - frame[idx02]
                     + frame[idx20] + (frame[idx21]<<1) + frame[idx22];

                magsq = gx*gx + gy*gy;
                mag   = sqrt_floor_8(magsq);
                if (mag > 255) mag = 255; // 안전 클립 (이론상 불필요)

                out_pixel <= mag[7:0];
                out_valid <= 1'b1;

                if (rd_cnt == W*H-1) begin
                    processing <= 1'b0; // 1프레임 처리 완료
                end
                rd_cnt <= rd_cnt + 1;
            end
        end
    end

endmodule

`default_nettype wire
