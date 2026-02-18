`timescale 1ns/1ps

module STEER_MODULE #(
    parameter PIXEL_BITS = 8,          // bits per pixel
    parameter KERNEL_SIZE = 9         // KxK kernel
)(
    input  wire clk,
    input  wire rst,
    input  wire [PIXEL_BITS*(KERNEL_SIZE-1)-1:0] packed_pixels_in,  // RB_COUNT pixels
    input  wire [$clog2(KERNEL_SIZE-1)-1:0] sel,                     // rotation index
    output reg  [PIXEL_BITS*(KERNEL_SIZE-1)-1:0] out                 // packed output
);

    localparam RB_COUNT = KERNEL_SIZE - 1;

    integer i;
    reg [PIXEL_BITS-1:0] pixels [0:RB_COUNT-1];         // unpacked input pixels
    reg [PIXEL_BITS-1:0] pixels_rotated [0:RB_COUNT-1]; // rotated pixels

    // Unpack the input pixels
    always @(*) begin
        for (i = 0; i < RB_COUNT; i = i + 1) begin
            pixels[i] = packed_pixels_in[(i+1)*PIXEL_BITS-1 -: PIXEL_BITS];
        end
    end

    // Rotate pixels based on sel
    always @(*) begin
        for (i = 0; i < RB_COUNT; i = i + 1) begin
            if (i + sel < RB_COUNT)
                pixels_rotated[i] = pixels[i + sel];
            else
                pixels_rotated[i] = pixels[i + sel - RB_COUNT];
        end
    end

    // Pack rotated pixels into output on clock
    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 0;
        else begin
            for (i = 0; i < RB_COUNT; i = i + 1)
                out[(i+1)*PIXEL_BITS-1 -: PIXEL_BITS] <= pixels_rotated[i];
        end
    end

endmodule
