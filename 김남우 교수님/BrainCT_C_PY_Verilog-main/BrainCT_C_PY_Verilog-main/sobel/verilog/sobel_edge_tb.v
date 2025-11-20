// C:\Users\Administrator\Desktop\sobel\chatgpt\01\verilog\sobel_edge_tb.v
`timescale 1ns/1ps
`default_nettype none

module sobel_edge_tb;

    localparam W    = 630;
    localparam H    = 630;
    localparam NPIX = W*H;

    reg clk = 0;
    always #5 clk = ~clk;  // 100 MHz
    reg rst_n = 0;

    reg         in_valid = 0;
    reg  [7:0]  in_pixel = 0;
    wire        out_valid;
    wire [7:0]  out_pixel;

    // DUT: 프레임버퍼 + 정확 sqrt
    sobel_edge_frame #(.W(W), .H(H)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_pixel(in_pixel),
        .out_valid(out_valid),
        .out_pixel(out_pixel)
    );

    // 메모리
    reg [7:0] src [0:NPIX-1];
    reg [7:0] edg [0:NPIX-1];

    integer i, wr_idx;

    // 파일 핸들
    integer fd_gray_bmp;
    integer fd_edge_bmp;
    integer fd_image_mem;
    integer fd_edge_mem;

    // BMP 공통 필드
    integer row_pad;
    integer row, col;
    integer palette_size, bfOffBits, biSizeImage, bfSize;

    // 8bpp BMP 쓰기 - src
    task write_bmp8_from_src; input integer fd; begin
        row_pad      = (4 - (W % 4)) % 4;
        palette_size = 256*4;
        bfOffBits    = 14 + 40 + palette_size;
        biSizeImage  = (W + row_pad) * H;
        bfSize       = bfOffBits + biSizeImage;

        // FILE HEADER
        $fwrite(fd, "%c%c", 8'h42, 8'h4D);
        $fwrite(fd, "%c%c%c%c", bfSize[7:0], bfSize[15:8], bfSize[23:16], bfSize[31:24]);
        $fwrite(fd, "%c%c%c%c", 8'h00,8'h00,8'h00,8'h00);
        $fwrite(fd, "%c%c%c%c", bfOffBits[7:0], bfOffBits[15:8], bfOffBits[23:16], bfOffBits[31:24]);

        // INFO HEADER
        $fwrite(fd, "%c%c%c%c", 40,0,0,0);
        $fwrite(fd, "%c%c%c%c", W[7:0], W[15:8], W[23:16], W[31:24]);
        $fwrite(fd, "%c%c%c%c", H[7:0], H[15:8], H[23:16], H[31:24]);
        $fwrite(fd, "%c%c", 1, 0);
        $fwrite(fd, "%c%c", 8, 0);
        $fwrite(fd, "%c%c%c%c", 0,0,0,0);
        $fwrite(fd, "%c%c%c%c", biSizeImage[7:0], biSizeImage[15:8], biSizeImage[23:16], biSizeImage[31:24]);
        $fwrite(fd, "%c%c%c%c", 8'h13,8'h0B,8'h00,8'h00); // 2835
        $fwrite(fd, "%c%c%c%c", 8'h13,8'h0B,8'h00,8'h00);
        $fwrite(fd, "%c%c%c%c", 8'h00,8'h01,8'h00,8'h00); // clrUsed=256
        $fwrite(fd, "%c%c%c%c", 8'h00,8'h01,8'h00,8'h00); // clrImportant=256

        // 팔레트
        for (col=0; col<256; col=col+1)
            $fwrite(fd, "%c%c%c%c", col[7:0], col[7:0], col[7:0], 8'h00);

        // 픽셀(bottom-up)
        for (row=H-1; row>=0; row=row-1) begin
            for (col=0; col<W; col=col+1)
                $fwrite(fd, "%c", src[row*W + col]);
            for (col=0; col<row_pad; col=col+1)
                $fwrite(fd, "%c", 8'h00);
        end
    end endtask

    // 8bpp BMP 쓰기 - edg
    task write_bmp8_from_edg; input integer fd; begin
        row_pad      = (4 - (W % 4)) % 4;
        palette_size = 256*4;
        bfOffBits    = 14 + 40 + palette_size;
        biSizeImage  = (W + row_pad) * H;
        bfSize       = bfOffBits + biSizeImage;

        // FILE HEADER
        $fwrite(fd, "%c%c", 8'h42, 8'h4D);
        $fwrite(fd, "%c%c%c%c", bfSize[7:0], bfSize[15:8], bfSize[23:16], bfSize[31:24]);
        $fwrite(fd, "%c%c%c%c", 8'h00,8'h00,8'h00,8'h00);
        $fwrite(fd, "%c%c%c%c", bfOffBits[7:0], bfOffBits[15:8], bfOffBits[23:16], bfOffBits[31:24]);

        // INFO HEADER
        $fwrite(fd, "%c%c%c%c", 40,0,0,0);
        $fwrite(fd, "%c%c%c%c", W[7:0], W[15:8], W[23:16], W[31:24]);
        $fwrite(fd, "%c%c%c%c", H[7:0], H[15:8], H[23:16], H[31:24]);
        $fwrite(fd, "%c%c", 1, 0);
        $fwrite(fd, "%c%c", 8, 0);
        $fwrite(fd, "%c%c%c%c", 0,0,0,0);
        $fwrite(fd, "%c%c%c%c", biSizeImage[7:0], biSizeImage[15:8], biSizeImage[23:16], biSizeImage[31:24]);
        $fwrite(fd, "%c%c%c%c", 8'h13,8'h0B,8'h00,8'h00); // 2835
        $fwrite(fd, "%c%c%c%c", 8'h13,8'h0B,8'h00,8'h00);
        $fwrite(fd, "%c%c%c%c", 8'h00,8'h01,8'h00,8'h00);
        $fwrite(fd, "%c%c%c%c", 8'h00,8'h01,8'h00,8'h00);

        // 팔레트
        for (col=0; col<256; col=col+1)
            $fwrite(fd, "%c%c%c%c", col[7:0], col[7:0], col[7:0], 8'h00);

        // 픽셀(bottom-up)
        for (row=H-1; row>=0; row=row-1) begin
            for (col=0; col<W; col=col+1)
                $fwrite(fd, "%c", edg[row*W + col]);
            for (col=0; col<row_pad; col=col+1)
                $fwrite(fd, "%c", 8'h00);
        end
    end endtask

    initial begin
        wr_idx   = 0;
        in_valid = 0;
        in_pixel = 0;

        // 리셋
        rst_n = 0; repeat(10) @(posedge clk);
        rst_n = 1; repeat(2)  @(posedge clk);

        // 입력 MEM 로드 (상위 폴더)
        $readmemh("..\\output_image-c.mem", src);

        // 입력 스트리밍
        for (i=0; i<NPIX; i=i+1) begin
            @(posedge clk);
            in_valid <= 1'b1;
            in_pixel <= src[i];
        end
        @(posedge clk);
        in_valid <= 1'b0;

        // DUT 처리 결과 수집
        wr_idx = 0;
        while (wr_idx < NPIX) begin
            @(posedge clk);
            if (out_valid) begin
                edg[wr_idx] <= out_pixel;
                wr_idx <= wr_idx + 1;
            end
        end

        // ── 결과 저장: 상위 폴더( ..\ ) ────────────────────────────────
        fd_gray_bmp = $fopen("..\\output_grayscale-vlog.bmp", "wb");
        if (fd_gray_bmp != 0) begin write_bmp8_from_src(fd_gray_bmp); $fclose(fd_gray_bmp); end

        fd_edge_bmp = $fopen("..\\output_edge-vlog.bmp", "wb");
        if (fd_edge_bmp != 0) begin write_bmp8_from_edg(fd_edge_bmp); $fclose(fd_edge_bmp); end

        // C와 동일 5바이트/라인 "XX\r\r\n"
        fd_image_mem = $fopen("..\\output_image-vlog.mem", "wb");
        if (fd_image_mem != 0) begin
            for (i=0; i<NPIX; i=i+1) begin
                $fwrite(fd_image_mem, "%02X", src[i]);
                $fwrite(fd_image_mem, "%c%c", 8'd13, 8'd10);
            end
            $fclose(fd_image_mem);
        end

        fd_edge_mem = $fopen("..\\output_edge-vlog.mem", "wb");
        if (fd_edge_mem != 0) begin
            for (i=0; i<NPIX; i=i+1) begin
                $fwrite(fd_edge_mem, "%02X", edg[i]);
                $fwrite(fd_edge_mem, "%c%c", 8'd13, 8'd10);
            end
            $fclose(fd_edge_mem);
        end

        $display("✅ DONE: files written to ..\\");
        $finish;
    end

endmodule

`default_nettype wire
