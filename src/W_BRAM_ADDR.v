//`timescale 1ns / 1ps


//module W_BRAM_ADDR #(
//    parameter RB_COUNT    = 4,
//    parameter IMAGE_WIDTH = 512,
//    parameter MEM_DEPTH   = RB_COUNT * IMAGE_WIDTH,
//    parameter STALL_CYCLES = 1
//)(
//    input clk,
//    input rst,
//    input enable,

//    output reg [$clog2(MEM_DEPTH)-1:0] write_addr,
//    output reg frame_filled
//);

//reg [$clog2(IMAGE_WIDTH)-1:0] w_local;  
//reg [$clog2(RB_COUNT)-1:0]    rb_cnt;    
//reg [1:0] round;     

//// Stall registers
//reg stall_active;
//reg [$clog2(STALL_CYCLES)-1:0] stall_cnt;

//// Flag to ensure stall happens only once
//reg stall_done;

//always @(posedge clk) begin
//    if (rst) begin
//        w_local      <= 1;
//        rb_cnt       <= 0;
//        write_addr   <= 0;
//        frame_filled <= 0;
//        round        <= 0;
//        stall_active <= 0;
//        stall_cnt    <= 0;
//        stall_done   <= 0;
//    end 
//    else if (stall_active) begin
//        // -------------------------
//        // STALL PERIOD
//        // -------------------------
//        if (stall_cnt == STALL_CYCLES-1) begin
//            stall_active <= 0;    // stall ends
//            stall_cnt    <= 0;
//            frame_filled <= 0;
//        end
//        else begin
//            stall_cnt <= stall_cnt + 1;
//        end
//    end
//    else if (enable && !frame_filled) begin

//        write_addr <= rb_cnt + w_local * RB_COUNT;

//        if (w_local == IMAGE_WIDTH-1) begin
//            w_local <= 0;

//            if (rb_cnt == RB_COUNT-1) begin
//                rb_cnt <= 0;
//                round <= round + 1;

//                // -------------------------
//                // Single stall after first 2048 cycles
//                // -------------------------
//                if (round == 1 && !stall_done) begin
//                    frame_filled <= 1;
//                    stall_active <= 1;
//                    stall_done   <= 1;  // mark stall as done
//                end
//            end 
//            else begin
//                rb_cnt <= rb_cnt + 1;
//            end
//        end 
//        else begin
//            w_local <= w_local + 1;
//        end
//    end
//end

//endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module W_BRAM_ADDR #(
    parameter RB_COUNT    = 8,
    parameter IMAGE_WIDTH = 256,
    parameter MEM_DEPTH   = RB_COUNT * IMAGE_WIDTH,
    parameter STALL_CYCLES = 1
)(
    input clk,
    input rst,
    input enable,

    output reg [$clog2(MEM_DEPTH)-1:0] write_addr,
    output reg frame_filled
);

reg [$clog2(IMAGE_WIDTH)-1:0] w_local;  
reg [$clog2(RB_COUNT)-1:0]    rb_cnt;    

// Stall signals
reg stall_active;
reg [$clog2(STALL_CYCLES)-1:0] stall_cnt;

// Flag to ensure stall happens only once
reg stall_done;

always @(posedge clk) begin
    if (rst) begin
        w_local      <= 1;
        rb_cnt       <= 0;
        write_addr   <= 0;
        frame_filled <= 0;
        stall_active <= 0;
        stall_cnt    <= 0;
        stall_done   <= 0;
    end
    else if (stall_active) begin
        // -------------------------
        // STALL PERIOD
        // -------------------------
        if (stall_cnt == STALL_CYCLES-1) begin
            stall_active <= 0;    // Stall ends
            stall_cnt    <= 0;
            frame_filled <= 0;    // Clear frame_filled after stall
            // w_local and rb_cnt remain at last value
        end
        else begin
            stall_cnt <= stall_cnt + 1;
        end
    end
    else if (enable) begin
        // -------------------------
        // Compute current write address
        // -------------------------
        write_addr <= rb_cnt + w_local * RB_COUNT;

        // -------------------------
        // Increment local counters
        // -------------------------
        if (w_local == IMAGE_WIDTH-1) begin
            w_local <= 0;

            if (rb_cnt == RB_COUNT-1) begin
                rb_cnt <= 0;

                // -------------------------
                // Assert frame_filled & stall after first 2048 writes
                // -------------------------
                if (!stall_done) begin
                    frame_filled <= 1;
                    stall_active <= 1;
                    stall_done   <= 1;
                end
            end
            else begin
                rb_cnt <= rb_cnt + 1;
            end
        end
        else begin
            w_local <= w_local + 1;
        end
    end
end

endmodule
