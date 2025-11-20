
// emboss.v : Emboss core (3x3 neighborhood -> 1 pixel), combinational
`timescale 1ns/1ps
module emboss_core(
    input  wire [7:0] p00, input wire [7:0] p01, input wire [7:0] p02,
    input  wire [7:0] p10, input wire [7:0] p11, input wire [7:0] p12,
    input  wire [7:0] p20, input wire [7:0] p21, input wire [7:0] p22,
    output reg  [7:0] out_pix
);
    integer sum;
    always @* begin
        // sum = kernel • neighborhood + 128 (bias)
        // [-2 -1 0; -1 1 1; 0 1 2]
        sum = 0;
        sum = sum
            + (-2 * p00) + (-1 * p01) + ( 0 * p02)
            + (-1 * p10) + ( 1 * p11) + ( 1 * p12)
            + ( 0 * p20) + ( 1 * p21) + ( 2 * p22)
            + 128;
        if (sum < 0)        out_pix = 8'd0;
        else if (sum > 255) out_pix = 8'd255;
        else                out_pix = sum[7:0];
    end
endmodule
