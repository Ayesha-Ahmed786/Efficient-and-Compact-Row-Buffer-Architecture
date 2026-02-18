////`timescale 1ns/1ps

////module tb_top;

////    // ------------------------------------------------------------
////    // Parameters
////    // ------------------------------------------------------------
////    localparam PIXEL_BITS   = 8;
////    localparam IMAGE_WIDTH  = 512;
////    localparam KERNEL_SIZE  = 5;
////    localparam RB_COUNT     = KERNEL_SIZE - 1;
////    localparam STALL_CYCLES = 1;

////    localparam IMG_SIZE     = IMAGE_WIDTH * IMAGE_WIDTH;
////    localparam MEM_DEPTH    = RB_COUNT * IMAGE_WIDTH;

////    // ------------------------------------------------------------
////    // Clock + Reset
////    // ------------------------------------------------------------
////    reg clk = 0;
////    always #5 clk = ~clk;    // 100 MHz

////    reg rst = 1;
////    initial begin
////        #50 rst = 0;
////    end

////    // ------------------------------------------------------------
////    // External Memory Model (512×512 image)
////    // ------------------------------------------------------------
////    reg [7:0] EXT_MEM [0:IMG_SIZE-1];
////    integer i;
////    initial begin
////        for (i = 0; i < IMG_SIZE; i = i + 1)
////            EXT_MEM[i] = i % 256; // Dummy pattern
////    end

////    // ------------------------------------------------------------
////    // DUT I/O
////    // ------------------------------------------------------------
////    wire [PIXEL_BITS-1:0] ext_data_in;
////    wire                  ext_data_valid;

////    wire [PIXEL_BITS*RB_COUNT-1:0] rb_read_data;  
////    wire [RB_COUNT-1:0]            rb_pixel_valid;

////    // ------------------------------------------------------------
////    // Instantiate DUT
////    // ------------------------------------------------------------
////    ROW_BUFFER_SYSTEM #(
////        .PIXEL_BITS (PIXEL_BITS),
////        .IMAGE_WIDTH(IMAGE_WIDTH),
////        .KERNEL_SIZE(KERNEL_SIZE),
////        .RB_COUNT(RB_COUNT),
////        .STALL_CYCLES(STALL_CYCLES)
////    ) DUT (
////        .clk(clk),
////        .rst(rst),
////        .ext_data_in(ext_data_in),
////        .ext_data_valid(ext_data_valid),
////        .rb_read_data(rb_read_data),
////        .rb_pixel_valid(rb_pixel_valid)
////    );

////    // ------------------------------------------------------------
////    // EXPOSE INTERNAL SIGNALS (for debugging)
////    // ------------------------------------------------------------
////    wire en_E           = DUT.ctrl.en_E;
////    wire en_W           = DUT.ctrl.en_W;
////    wire en_R           = DUT.ctrl.en_R;
////    wire E_last         = DUT.ctrl.E_last;
////    wire W_frame_filled = DUT.ctrl.W_frame_filled;

////    wire [17:0] e_addr      = DUT.e_addr_gen.addr;
////    wire [$clog2(MEM_DEPTH)-1:0] w_addr = DUT.w_addr_gen.write_addr;
////    wire [$clog2(IMAGE_WIDTH)-1:0] r_addr = DUT.r_addr_gen.read_addr;

////    assign ext_data_in     = EXT_MEM[e_addr];  
////    assign ext_data_valid  = en_E;

////    wire [PIXEL_BITS*RB_COUNT-1:0] mm_read_data = DUT.mm_inst.read_data;

////    // ------------------------------------------------------------
////    // LOGGING TO FILE
////    // ------------------------------------------------------------
////    integer logfile;

////    initial begin
////        logfile = $fopen("simulation_output.txt", "w");
////        if (!logfile) begin
////            $display("ERROR: Could not open log file!");
////            $finish;
////        end
////    end

////    always @(posedge clk) begin
////        if (!rst) begin
////            $fdisplay(logfile, "----------------------------------------------------------------");
////            $fdisplay(logfile, "T=%0t | EN(E,W,R) = %b %b %b | E_last=%b | W_frame_filled=%b",
////                      $time, en_E, en_W, en_R, E_last, W_frame_filled);
////            $fdisplay(logfile, "   WRITE: addr=%0d  data=%0d  (ext mem)", 
////                      w_addr, ext_data_in);
////            $fdisplay(logfile, "   READ : addr=%0d  data=%h  valid=%b", 
////                      r_addr, mm_read_data, rb_pixel_valid);
////            $fdisplay(logfile, "   E_ADDR=%0d  EXT_DATA=%0d", e_addr, ext_data_in);
////        end
////    end

////    // ------------------------------------------------------------
////    // STOP SIMULATION
////    // ------------------------------------------------------------
////    initial begin
////        #10_000_000;
////        $fdisplay(logfile, "SIM TIMEOUT - stopping.");
////        $fclose(logfile);
////        $finish;
////    end

////endmodule




//`timescale 1ns/1ps

//module tb_top;

//    // ------------------------------------------------------------
//    // Parameters
//    // ------------------------------------------------------------
//    localparam PIXEL_BITS   = 8;
//    localparam IMAGE_WIDTH  = 512;
//    localparam KERNEL_SIZE  = 5;
//    localparam RB_COUNT     = KERNEL_SIZE - 1;
//    localparam STALL_CYCLES = 1;

//    localparam IMG_SIZE     = IMAGE_WIDTH * IMAGE_WIDTH;
//    localparam MEM_DEPTH    = RB_COUNT * IMAGE_WIDTH;

//    // ------------------------------------------------------------
//    // Clock + Reset
//    // ------------------------------------------------------------
//    reg clk = 0;
//    always #5 clk = ~clk;    // 100 MHz

//    reg rst = 1;
//    initial begin
//        #50 rst = 0;
//    end

//    // ------------------------------------------------------------
//    // External Memory Model (512×512 image)
//    // ------------------------------------------------------------
//    reg [7:0] EXT_MEM [0:IMG_SIZE-1];
//    integer i;
//    initial begin
//        for (i = 0; i < IMG_SIZE; i = i + 1)
//            EXT_MEM[i] = i % 256; // Dummy pattern
//    end

//    // ------------------------------------------------------------
//    // DUT I/O
//    // ------------------------------------------------------------
//    wire [PIXEL_BITS-1:0] ext_data_in;
//    wire                  ext_data_valid;

//    wire [PIXEL_BITS*RB_COUNT-1:0] rb_read_data;  
//    wire [RB_COUNT-1:0]            rb_pixel_valid;

//    // ------------------------------------------------------------
//    // Instantiate DUT
//    // ------------------------------------------------------------
//    ROW_BUFFER_SYSTEM #(
//        .PIXEL_BITS (PIXEL_BITS),
//        .IMAGE_WIDTH(IMAGE_WIDTH),
//        .KERNEL_SIZE(KERNEL_SIZE),
//        .RB_COUNT(RB_COUNT),
//        .STALL_CYCLES(STALL_CYCLES)
//    ) DUT (
//        .clk(clk),
//        .rst(rst),
//        .ext_data_in(ext_data_in),
//        .ext_data_valid(ext_data_valid),
//        .rb_read_data(rb_read_data),
//        .rb_pixel_valid(rb_pixel_valid)
//    );

//    // ------------------------------------------------------------
//    // EXPOSE INTERNAL SIGNALS (for debugging)
//    // ------------------------------------------------------------
//    wire en_E           = DUT.ctrl.en_E;
//    wire en_W           = DUT.ctrl.en_W;
//    wire en_R           = DUT.ctrl.en_R;
//    wire E_last         = DUT.ctrl.E_last;
//    wire W_frame_filled = DUT.ctrl.W_frame_filled;

//    wire [17:0] e_addr      = DUT.e_addr_gen.addr;
//    wire [$clog2(MEM_DEPTH)-1:0] w_addr = DUT.w_addr_gen.write_addr;
//    wire [$clog2(IMAGE_WIDTH)-1:0] r_addr = DUT.r_addr_gen.read_addr;

//    assign ext_data_in     = EXT_MEM[e_addr];  
//    assign ext_data_valid  = en_E;

//    wire [PIXEL_BITS*RB_COUNT-1:0] mm_read_data = DUT.mm_inst.read_data;

//    // ------------------------------------------------------------
//    // LOGGING TO FILE
//    // ------------------------------------------------------------
//    integer logfile;
//    integer write_cycles = 0;
//    integer read_cycles  = 0;

//    initial begin
//        // Use a full absolute path to avoid $fopen issues
//        logfile = $fopen("sim_log.txt", "w");
//        if (logfile <= 0) begin
//            $display("ERROR: Could not open log file! Exiting simulation.");
//            $finish;
//        end
//    end

//    // Count write and read cycles and log safely
//    always @(posedge clk) begin
//        if (!rst && logfile > 0) begin
//            if (en_W) write_cycles = write_cycles + 1;
//            if (en_R) read_cycles  = read_cycles + 1;

//            $fdisplay(logfile, "----------------------------------------------------------------");
//            $fdisplay(logfile, "T=%0t | EN(E,W,R) = %b %b %b | E_last=%b | W_frame_filled=%b",
//                      $time, en_E, en_W, en_R, E_last, W_frame_filled);
//            $fdisplay(logfile, "   WRITE: addr=%0d  data=%0d  (ext mem) | write_cycles=%0d", 
//                      w_addr, ext_data_in, write_cycles);
//            $fdisplay(logfile, "   READ : addr=%0d  data=%h  valid=%b | read_cycles=%0d", 
//                      r_addr, mm_read_data, rb_pixel_valid, read_cycles);
//            $fdisplay(logfile, "   E_ADDR=%0d  EXT_DATA=%0d", e_addr, ext_data_in);
//        end
//    end

//    // ------------------------------------------------------------
//    // STOP SIMULATION
//    // ------------------------------------------------------------
//    initial begin
//        #10_000_000;
//        if (logfile > 0) begin
//            $fdisplay(logfile, "SIM TIMEOUT - stopping.");
//            $fdisplay(logfile, "TOTAL WRITE CYCLES = %0d", write_cycles);
//            $fdisplay(logfile, "TOTAL READ  CYCLES = %0d", read_cycles);
//            $fclose(logfile);
//        end
//        $finish;
//    end

//endmodule


`timescale 1ns / 1ps

module tb_top;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------
    localparam PIXEL_BITS   = 8;
    localparam IMAGE_WIDTH  = 256;
    localparam KERNEL_SIZE  = 9;
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
    initial #50 rst = 0;

    // ------------------------------------------------------------
    // External Memory Model (512×512 image)
    // ------------------------------------------------------------
    reg [7:0] EXT_MEM [0:IMG_SIZE-1];
    integer i;
    initial for (i = 0; i < IMG_SIZE; i = i + 1)
        EXT_MEM[i] = i % 256;

    // ------------------------------------------------------------
    // DUT I/O
    // ------------------------------------------------------------
    wire [PIXEL_BITS-1:0] ext_data_in;
    wire                  ext_data_valid;

    wire [PIXEL_BITS*RB_COUNT-1:0] rb_read_data;  
    wire [PIXEL_BITS*RB_COUNT-1:0] rb_steered_data;
    wire [RB_COUNT-1:0]            rb_pixel_valid;
    wire [$clog2(RB_COUNT)-1:0] steer_sel_tb;

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
        .rb_pixel_valid(rb_pixel_valid),
        .rb_steered_data(rb_steered_data)
    );

    // ------------------------------------------------------------
    // Internal signals for waveform viewing
    // ------------------------------------------------------------
    wire en_E           = DUT.ctrl.en_E;
    wire en_W           = DUT.ctrl.en_W;
    wire en_R           = DUT.ctrl.en_R;
    wire E_last         = DUT.ctrl.E_last;
    wire W_frame_filled = DUT.ctrl.W_frame_filled;

    wire [17:0] e_addr      = DUT.e_addr_gen.addr;
    wire [$clog2(MEM_DEPTH)-1:0] w_addr = DUT.w_addr_gen.write_addr;
    wire [$clog2(IMAGE_WIDTH)-1:0] r_addr = DUT.r_addr_gen.read_addr;
    assign steer_sel_tb = DUT.steer_sel;


    assign ext_data_in     = EXT_MEM[e_addr];  
    assign ext_data_valid  = en_E;

    // STEER_MODULE output inside DUT

    // ------------------------------------------------------------
    // Stop simulation
    // ------------------------------------------------------------
    initial begin
        #100_000;  // Run long enough to see some read/write cycles
        $finish;
    end

endmodule
