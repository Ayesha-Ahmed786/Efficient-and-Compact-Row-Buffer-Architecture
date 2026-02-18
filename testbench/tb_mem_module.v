`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 08:39:30 PM
// Design Name: 
// Module Name: tb_mem_module
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


`timescale 1ns / 1ps

module tb_mem_module;

    // Parameters
    localparam PIXEL_BITS  = 8;
    localparam IMAGE_WIDTH = 512;
    localparam KERNEL_SIZE = 5;
    localparam RB_COUNT    = KERNEL_SIZE - 1;

    // DUT I/O
    reg clk, rst;
    reg kernel_size;
    reg we, re;
    reg [PIXEL_BITS-1:0] write_data;
    reg [$clog2((KERNEL_SIZE-1)*IMAGE_WIDTH)-1:0] write_addr;
    reg [$clog2(IMAGE_WIDTH)-1:0] read_addr;

    wire [PIXEL_BITS*RB_COUNT-1:0] read_data;

    // Instantiate DUT
    simple_bram #(
        .PIXEL_BITS(PIXEL_BITS),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .kernel_size(kernel_size),
        .we(we),
        .write_data(write_data),
        .write_addr(write_addr),
        .re(re),
        .read_addr(read_addr),
        .read_data(read_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100 MHz
    end

    // Test sequence
    integer i;
    initial begin
        $display("===== Simulation Start =====");

        rst = 1;
        kernel_size = 0;
        we = 0;
        re = 0;
        write_addr = 0;
        read_addr = 0;
        write_data = 0;

        #20 rst = 0;

        // ----------------------------------------
        // STEP 1: WRITE values 0 - 2047 in BRAM
        // ----------------------------------------
        $display("Writing 0–2047 into memory...");
        for (i = 0; i < RB_COUNT*IMAGE_WIDTH; i = i + 1) begin
            @(posedge clk);
            we = 1;
            write_addr = i;
            write_data = i % 256;   // 8-bit value
        end
        @(posedge clk);
        we = 0;

        $display("Write complete!");

        // ----------------------------------------
        // STEP 2: READ from some example addresses
        // ----------------------------------------

        #20;
        re = 1;

        // Example 1: read_addr = 0
        read_addr = 0;
        @(posedge clk);
        $display("READ @%0d => %h", read_addr, read_data);

        // Example 2: read_addr = 5
        read_addr = 5;
        @(posedge clk);
        $display("READ @%0d => %h", read_addr, read_data);

        // Example 3: read_addr = 100
        read_addr = 100;
        @(posedge clk);
        $display("READ @%0d => %h", read_addr, read_data);

        // Example 4: read_addr = 511 (last pixel of each row buffer)
        read_addr = 511;
        @(posedge clk);
        $display("READ @%0d => %h", read_addr, read_data);

        re = 0;

        #50;
        $display("===== Simulation End =====");

    end

endmodule
