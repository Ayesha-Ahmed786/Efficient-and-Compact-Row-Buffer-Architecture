`timescale 1ns / 1ps

module tb_top_steer;
    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------
    localparam PIXEL_BITS   = 8;
    localparam IMAGE_WIDTH  = 512;
    localparam KERNEL_SIZE  = 5;
    localparam RB_COUNT     = KERNEL_SIZE - 1;
    localparam STALL_CYCLES = 1;

    localparam IMG_SIZE     = IMAGE_WIDTH * IMAGE_WIDTH;
    localparam MEM_DEPTH    = RB_COUNT * IMAGE_WIDTH;

    // ------------------------------------------------------------
    // Clock + Reset
    // ------------------------------------------------------------
    reg clk = 0;
    always #5 clk = ~clk;    // 100 MHz

    reg rst = 1;
    initial begin
        #50 rst = 0;
    end

    // ------------------------------------------------------------
    // External Memory Model (512×512 image)
    // ------------------------------------------------------------
    reg [7:0] EXT_MEM [0:IMG_SIZE-1];
    integer i;
    initial begin
        for (i = 0; i < IMG_SIZE; i = i + 1)
            EXT_MEM[i] = i % 256; // Dummy pattern
    end

    // ------------------------------------------------------------
    // DUT I/O
    // ------------------------------------------------------------
    wire [PIXEL_BITS-1:0] ext_data_in;
    wire                  ext_data_valid;

    wire [PIXEL_BITS*RB_COUNT-1:0] rb_read_data;  
    wire [RB_COUNT-1:0]            rb_pixel_valid;

    // ------------------------------------------------------------
    // Instantiate DUT
    // ------------------------------------------------------------
    ROW_BUFFER_SYSTEM #(
        .PIXEL_BITS (PIXEL_BITS),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE),
        .RB_COUNT(RB_COUNT),
        .STALL_CYCLES(STALL_CYCLES)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .ext_data_in(ext_data_in),
        .ext_data_valid(ext_data_valid),
        .rb_read_data(rb_read_data),
        .rb_pixel_valid(rb_pixel_valid)
    );

    // ------------------------------------------------------------
    // Internal signals for waveform viewing
    // ------------------------------------------------------------
    wire en_E           = DUT.ctrl.en_E;
    wire en_W           = DUT.ctrl.en_W;
    wire en_R           = DUT.ctrl.en_R;
    wire E_last         = DUT.ctrl.E_last;
    wire W_frame_filled = DUT.ctrl.W_frame_filled;
    wire [$clog2(RB_COUNT)-1:0] steer_sel = DUT.ctrl.steer_sel;

    wire [17:0] e_addr      = DUT.e_addr_gen.addr;
    wire [$clog2(MEM_DEPTH)-1:0] w_addr = DUT.w_addr_gen.write_addr;
    wire [$clog2(IMAGE_WIDTH)-1:0] r_addr = DUT.r_addr_gen.read_addr;

    // Connect external memory to DUT
    assign ext_data_in     = EXT_MEM[e_addr];  
    assign ext_data_valid  = en_E;

    // STEER_MODULE output inside DUT
    wire [PIXEL_BITS*RB_COUNT-1:0] rb_steered_data = DUT.steer_inst.out;

    // ------------------------------------------------------------
    // Stop simulation after some time
    // ------------------------------------------------------------
    initial begin
        #10_000_000;
        $finish;
    end

endmodule

