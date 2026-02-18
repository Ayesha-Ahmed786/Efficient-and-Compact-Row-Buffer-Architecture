module CONTROL_UNIT #(
    parameter IMAGE_WIDTH   = 256,
    parameter RB_COUNT      = 8,
    parameter STALL_CYCLES  = 1
)(
    input  clk,
    input  rst,

    // Outputs to submodules
    output reg en_E,
    output reg en_W,
    output reg en_R,
    output reg [$clog2(RB_COUNT)-1:0] steer_sel,


    // Inputs from submodules
    input  E_last,             // end of external memory
    input  W_frame_filled      // asserted once after 2048 writes
);

localparam IMG_SIZE      = IMAGE_WIDTH * IMAGE_WIDTH; 
localparam W_TOTAL_CYC   = IMG_SIZE + STALL_CYCLES;   // <---- NEW
localparam READ_CYCLES_R = IMAGE_WIDTH + IMAGE_WIDTH*(IMAGE_WIDTH - RB_COUNT);

// Internal counters
reg [31:0] w_cnt;  
reg [18:0] r_cnt;
reg        r_started;
reg [$clog2(RB_COUNT)-1:0] steer_cnt;
reg [31:0] steer_cycle_cnt;

always @(posedge clk) begin
    if (rst) begin
        en_E      <= 0;
        en_W      <= 0;
        en_R      <= 0;
        w_cnt     <= 0;
        r_cnt     <= 0;
        r_started <= 0;
        steer_sel <= {($clog2(RB_COUNT)){1'b0}};
        steer_cnt <= {($clog2(RB_COUNT)){1'b0}};
        steer_cycle_cnt <= 0;
    end
    else begin

        //-----------------------------------------
        // ENABLE E_MEM_ADDR and W_BRAM_ADDR at cycle 0
        //-----------------------------------------
        if (w_cnt == 0) begin
            en_E <= 1;
            en_W <= 1;
        end

        //-----------------------------------------
        // DISABLE E when the entire external memory is read
        //-----------------------------------------
        if (en_E && E_last)
            en_E <= 0;

        //-----------------------------------------
        // DISABLE W AFTER WRITING ENTIRE IMAGE
        //-----------------------------------------
        if (en_W) begin
            if (w_cnt == W_TOTAL_CYC-1) begin
                en_W <= 0;          // <---- NEW STOP CONDITION
            end
            w_cnt <= w_cnt + 1;
        end

        //-----------------------------------------
        // ENABLE R when first 2048 writes completed
        //-----------------------------------------
        if (!r_started && W_frame_filled) begin
            en_R      <= 1;
            r_started <= 1;
            r_cnt     <= 0;
        end

        //-----------------------------------------
        // DISABLE R after 128 reads (512/4)
        //-----------------------------------------
        if (en_R) begin
            if (r_cnt == READ_CYCLES_R - 1)
                en_R <= 0;
            else
                r_cnt <= r_cnt + 1;
        end
        if (steer_cycle_cnt == IMAGE_WIDTH - 1) begin
                        steer_cycle_cnt <= 0;
                        // increment steer_cnt with wraparound [0 .. RB_COUNT-1]
                        if (steer_cnt == RB_COUNT - 1)
                            steer_cnt <= 0;
                        else
                            steer_cnt <= steer_cnt + 1;
                        steer_sel <= (steer_cnt == RB_COUNT - 1) ? {($clog2(RB_COUNT)){1'b0}} : steer_cnt + 1;
                    end else begin
                        steer_cycle_cnt <= steer_cycle_cnt + 1;
                        steer_sel <= steer_cnt;
                    end
                end

    end

endmodule


