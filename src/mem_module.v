`timescale 1ns / 1ps

module MM #(
    parameter PIXEL_BITS = 8,
    parameter IMAGE_WIDTH = 256,
    parameter KERNEL_SIZE = 9,
    parameter RB_COUNT = KERNEL_SIZE - 1
)(
    input clk,
    input rst,
    input kernel_size,
    // Write interface
    input we,
    input [PIXEL_BITS-1:0] write_data,
    input [$clog2((KERNEL_SIZE-1)*IMAGE_WIDTH)-1:0] write_addr,
    // Read interface
    input re,
    input [$clog2(IMAGE_WIDTH)-1:0] read_addr,
    output reg [PIXEL_BITS*RB_COUNT-1:0] read_data
);

    localparam MEM_DEPTH = RB_COUNT * IMAGE_WIDTH;
    reg [PIXEL_BITS-1:0] mem [0:MEM_DEPTH-1];
    integer i;
    always @(posedge clk) begin
        if (we) begin
            mem[write_addr] <= write_data;
        end
        if (re) begin
            // Read RB_COUNT consecutive locations
            for (i = 0; i < RB_COUNT; i = i + 1) begin
                read_data[i*PIXEL_BITS +: PIXEL_BITS] <= mem[read_addr*RB_COUNT + i];
            end
        end
    end

endmodule

