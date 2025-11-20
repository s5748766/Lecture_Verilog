
// emboss_tb.v : File I/O testbench that uses emboss_core (ModelSim 10.1d 호환 + 강건한 MEM 파서)
`timescale 1ns/1ps

module emboss_tb;
  parameter integer IMG_W = 630;
  parameter integer IMG_H = 630;
  parameter integer NPIX  = IMG_W * IMG_H;

`ifndef MEM_FILE
  `define MEM_FILE "../brainct_001_gray-c.mem"
`endif

  // Memories
  reg [7:0] gray [0:NPIX-1];
  reg [7:0] emb  [0:NPIX-1];

  // Loop vars
  integer x, y, idx;
  integer fh, row_stride, pixel_bytes, padding, off;

  // Core wiring
  wire [7:0] out_pix;
  reg  [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;

  emboss_core u_core(
    .p00(p00), .p01(p01), .p02(p02),
    .p10(p10), .p11(p11), .p12(p12),
    .p20(p20), .p21(p21), .p22(p22),
    .out_pix(out_pix)
  );

  // Little-endian write helpers
  task write_u16(input integer f, input integer v);
    begin
      $fwrite(f, "%c", v & 8'hFF);
      $fwrite(f, "%c", (v >> 8) & 8'hFF);
    end
  endtask
  task write_u32(input integer f, input integer v);
    begin
      $fwrite(f, "%c", v & 8'hFF);
      $fwrite(f, "%c", (v >> 8) & 8'hFF);
      $fwrite(f, "%c", (v >> 16) & 8'hFF);
      $fwrite(f, "%c", (v >> 24) & 8'hFF);
    end
  endtask

  // --- BMP Writer (global emb[] 사용) ---
  task write_bmp_24(input integer f, input integer w, input integer h);
    integer bfSize, bfOffBits, pixel_bytes, row_stride, padding;
    integer y2, x, off, idx;
    begin
      row_stride  = ((w * 3 + 3) / 4) * 4;
      pixel_bytes = row_stride * h;
      padding     = row_stride - (w * 3);

      // 'BM'
      $fwrite(f, "%c", 8'h42);
      $fwrite(f, "%c", 8'h4D);
      bfOffBits   = 14 + 40;
      bfSize      = bfOffBits + pixel_bytes;
      write_u32(f, bfSize);
      write_u16(f, 0);
      write_u16(f, 0);
      write_u32(f, bfOffBits);

      // BITMAPINFOHEADER
      write_u32(f, 40);
      write_u32(f, w);
      write_u32(f, h);
      write_u16(f, 1);
      write_u16(f, 24);
      write_u32(f, 0);
      write_u32(f, pixel_bytes);
      write_u32(f, 2835);
      write_u32(f, 2835);
      write_u32(f, 0);
      write_u32(f, 0);

      // Pixel data (bottom-up)
      for (y2 = h-1; y2 >= 0; y2 = y2 - 1) begin
        for (x = 0; x < w; x = x + 1) begin
          idx = y2 * w + x;
          $fwrite(f, "%c", emb[idx]);
          $fwrite(f, "%c", emb[idx]);
          $fwrite(f, "%c", emb[idx]);
        end
        for (off = 0; off < padding; off = off + 1) $fwrite(f, "%c", 8'h00);
      end
    end
  endtask

  // --- Robust MEM reader: handles "0xNN" or "NN" tokens ---
  task read_mem_hex(input [1023:0] fname);
    integer f, v, r, i;
    reg [8*16-1:0] tok; // up to 16 chars token buffer
    begin
      for (i = 0; i < NPIX; i = i + 1) gray[i] = 8'd0;
      f = $fopen(fname, "r");
      if (f == 0) begin
        $display("ERROR: cannot open %0s", fname);
        $finish;
      end
      i = 0;
      // Try two formats: "0x%h" or "%h". Skip garbage tokens if any.
      while ((i < NPIX) && (!$feof(f))) begin
        r = $fscanf(f, "0x%h", v);
        if (r != 1) r = $fscanf(f, "%h", v);
        if (r == 1) begin
          gray[i] = v[7:0];
          i = i + 1;
        end else begin
          // consume one string and continue
          r = $fscanf(f, "%s", tok);
          if (r != 1) begin
            // nothing to consume; break to avoid infinite loop
            disable read_mem_hex;
          end
        end
      end
      $fclose(f);
      if (i != NPIX) $display("WARN: read %0d pixels, expected %0d", i, NPIX);
      else           $display("Read %0d pixels from %0s", i, fname);
    end
  endtask

  // --- Simulation main ---
  initial begin
    $display("Reading MEM (robust parser): %s", `MEM_FILE);
    read_mem_hex(`MEM_FILE);

    // Borders = 128 (expected mid-gray frame even if interior is zero)
    for (x = 0; x < IMG_W; x = x + 1) begin
      emb[x]                       = 8'd128;
      emb[(IMG_H-1)*IMG_W + x]     = 8'd128;
    end
    for (y = 0; y < IMG_H; y = y + 1) begin
      emb[y*IMG_W + 0]             = 8'd128;
      emb[y*IMG_W + (IMG_W-1)]     = 8'd128;
    end

    // Core call
    for (y = 1; y < IMG_H-1; y = y + 1) begin
      for (x = 1; x < IMG_W-1; x = x + 1) begin
        p00 = gray[(y-1)*IMG_W + (x-1)];
        p01 = gray[(y-1)*IMG_W + (x  )];
        p02 = gray[(y-1)*IMG_W + (x+1)];
        p10 = gray[(y  )*IMG_W + (x-1)];
        p11 = gray[(y  )*IMG_W + (x  )];
        p12 = gray[(y  )*IMG_W + (x+1)];
        p20 = gray[(y+1)*IMG_W + (x-1)];
        p21 = gray[(y+1)*IMG_W + (x  )];
        p22 = gray[(y+1)*IMG_W + (x+1)];

        #1; // allow combinational settle on older simulators
        emb[y*IMG_W + x] = out_pix;
      end
    end

    // Write BMP
    fh = $fopen("../brainct_001_emboss-verilog.bmp", "wb");
    if (fh == 0) begin
      $display("ERROR: cannot open output BMP");
      $finish;
    end
    write_bmp_24(fh, IMG_W, IMG_H);
    $fclose(fh);
    $display("DONE: wrote brainct_001_emboss-verilog.bmp");
    $finish;
  end
endmodule
