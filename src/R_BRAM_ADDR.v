`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2025 01:23:08 PM
// Design Name: 
// Module Name: R_BRAM_ADDR
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


module R_BRAM_ADDR #(
    parameter RB_COUNT    = 8,       // Number of row buffers
    parameter IMAGE_WIDTH = 256,     // Width of input image
    parameter MEM_DEPTH   = IMAGE_WIDTH, // Number of read addresses (R0-R511)
    parameter PIXEL_PER_READ = RB_COUNT     // 4 pixels read at a time
)(
    input clk,
    input rst,
    input enable,
    
    output reg [$clog2(MEM_DEPTH)-1:0] read_addr,
    output reg [PIXEL_PER_READ-1:0] pixel_group_valid // optional: indicates valid read
);

reg [$clog2(IMAGE_WIDTH)-1:0] r_local;  
reg [$clog2(RB_COUNT)-1:0]    rb_cnt;  


always @(posedge clk) begin
    if (rst) begin
        r_local           <= 1;
        rb_cnt            <= 0;
        read_addr         <= 0;
        pixel_group_valid <= 0;
    end
    else if (enable) begin
        // Generate read address
        read_addr <= r_local;

        // Optional valid signal for read pixels
        pixel_group_valid <= {PIXEL_PER_READ{1'b1}};

        // Increment local column
        if (r_local == IMAGE_WIDTH-1) begin
            r_local <= 0;
        end
        else begin
            r_local <= r_local + 1;
        end
    end
    else begin
        pixel_group_valid <= 0;
    end
end

endmodule