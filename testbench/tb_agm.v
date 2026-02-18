//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 11/26/2025 02:40:56 PM
//// Design Name: 
//// Module Name: tb_agm
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//`timescale 1ns/1ps

//module tb_agm;

//// --------------------------------------------------
//// Parameters
//// --------------------------------------------------
//localparam IMAGE_WIDTH = 512;
//localparam RB_COUNT    = 4;
//localparam STALL_CYCLES = 1;
//localparam IMG_SIZE    = IMAGE_WIDTH * IMAGE_WIDTH;

//// --------------------------------------------------
//// Clock + Reset
//// --------------------------------------------------
//reg clk = 0;
//always #5 clk = ~clk;   // 100 MHz

//reg rst;

//// --------------------------------------------------
//// Control <-> Modules enable signals
//// --------------------------------------------------
//wire en_E, en_W, en_R;

//// --------------------------------------------------
//// Outputs from submodules
//// --------------------------------------------------
//wire [17:0] e_addr;
//wire        e_last;

//wire [$clog2(RB_COUNT*IMAGE_WIDTH)-1:0] w_addr;
//wire                                    w_frame_filled;

//wire [$clog2(IMAGE_WIDTH)-1:0] r_addr;
//wire [RB_COUNT-1:0]            r_valid;


//// --------------------------------------------------
//// Instantiate CONTROL UNIT
//// --------------------------------------------------
//CONTROL_UNIT #(
//    .IMAGE_WIDTH(IMAGE_WIDTH),
//    .RB_COUNT(RB_COUNT),
//    .STALL_CYCLES(STALL_CYCLES)
//) dut_control (
//    .clk(clk),
//    .rst(rst),
//    .en_E(en_E),
//    .en_W(en_W),
//    .en_R(en_R),

//    .E_last(e_last),
//    .W_frame_filled(w_frame_filled)
//);

//// --------------------------------------------------
//// Instantiate E_MEM_ADDR
//// --------------------------------------------------
//E_MEM_ADDR #(
//    .IMG_SIZE(IMG_SIZE)
//) dut_E (
//    .clk(clk),
//    .rst(rst),
//    .enable(en_E),
//    .addr(e_addr),
//    .last(e_last)
//);

//// --------------------------------------------------
//// Instantiate W_BRAM_ADDR
//// --------------------------------------------------
//W_BRAM_ADDR #(
//    .RB_COUNT(RB_COUNT),
//    .IMAGE_WIDTH(IMAGE_WIDTH),
//    .STALL_CYCLES(STALL_CYCLES)
//) dut_W (
//    .clk(clk),
//    .rst(rst),
//    .enable(en_W),
//    .write_addr(w_addr),
//    .frame_filled(w_frame_filled)
//);

//// --------------------------------------------------
//// Instantiate R_BRAM_ADDR
//// --------------------------------------------------
//R_BRAM_ADDR #(
//    .RB_COUNT(RB_COUNT),
//    .IMAGE_WIDTH(IMAGE_WIDTH)
//) dut_R (
//    .clk(clk),
//    .rst(rst),
//    .enable(en_R),
//    .read_addr(r_addr),
//    .pixel_group_valid(r_valid)
//);


//// --------------------------------------------------
//// Simulation sequence
//// --------------------------------------------------
//initial begin

//    $display("----- START SIMULATION -----");
//    #200;
//    rst = 1;
//    repeat (5) @(posedge clk);

//    rst = 0;

//    // run enough cycles for full image + reading
//    repeat (300000) @(posedge clk);

//    $display("----- END SIMULATION -----");
//    $stop;
//end


//// --------------------------------------------------
//// Optional: Print key events to the console
//// --------------------------------------------------
//always @(posedge clk) begin

//    if (en_E)
//        $display("E: addr=%d  last=%b", e_addr, e_last);

//    if (en_W)
//        $display("W: addr=%d  frame_filled=%b", w_addr, w_frame_filled);

//    if (en_R)
//        $display("R: addr=%d  valid=%b", r_addr, r_valid);

//end

//endmodule




`timescale 1ns/1ps

module tb_agm;

// --------------------------------------------------
// Parameters
// --------------------------------------------------
localparam IMAGE_WIDTH  = 512;
localparam RB_COUNT     = 4;
localparam STALL_CYCLES = 1;
localparam IMG_SIZE     = IMAGE_WIDTH * IMAGE_WIDTH;

// --------------------------------------------------
// Clock + Reset
// --------------------------------------------------
reg clk = 0;
always #5 clk = ~clk;   // 100 MHz clock

reg rst;

// --------------------------------------------------
// Control <-> Modules enable signals
// --------------------------------------------------
wire en_E, en_W, en_R;

// --------------------------------------------------
// Outputs from submodules
// --------------------------------------------------
wire [17:0] e_addr;
wire        e_last;

wire [$clog2(RB_COUNT*IMAGE_WIDTH)-1:0] w_addr;
wire                                    w_frame_filled;

wire [$clog2(IMAGE_WIDTH)-1:0] r_addr;
wire [RB_COUNT-1:0]            r_valid;

// --------------------------------------------------
// Logging + Counters
// --------------------------------------------------
integer fp;
integer cycles_E = 0;
integer cycles_W = 0;
integer cycles_R = 0;

// --------------------------------------------------
// Instantiate CONTROL UNIT
// --------------------------------------------------
CONTROL_UNIT #(
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .RB_COUNT(RB_COUNT),
    .STALL_CYCLES(STALL_CYCLES)
) dut_control (
    .clk(clk),
    .rst(rst),
    .en_E(en_E),
    .en_W(en_W),
    .en_R(en_R),

    .E_last(e_last),
    .W_frame_filled(w_frame_filled)
);

// --------------------------------------------------
// Instantiate E_MEM_ADDR
// --------------------------------------------------
E_MEM_ADDR #(
    .IMG_SIZE(IMG_SIZE)
) dut_E (
    .clk(clk),
    .rst(rst),
    .enable(en_E),
    .addr(e_addr),
    .last(e_last)
);

// --------------------------------------------------
// Instantiate W_BRAM_ADDR
// --------------------------------------------------
W_BRAM_ADDR #(
    .RB_COUNT(RB_COUNT),
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .STALL_CYCLES(STALL_CYCLES)
) dut_W (
    .clk(clk),
    .rst(rst),
    .enable(en_W),
    .write_addr(w_addr),
    .frame_filled(w_frame_filled)
);

// --------------------------------------------------
// Instantiate R_BRAM_ADDR
// --------------------------------------------------
R_BRAM_ADDR #(
    .RB_COUNT(RB_COUNT),
    .IMAGE_WIDTH(IMAGE_WIDTH)
) dut_R (
    .clk(clk),
    .rst(rst),
    .enable(en_R),
    .read_addr(r_addr),
    .pixel_group_valid(r_valid)
);

// --------------------------------------------------
// Open log file at time 0
// --------------------------------------------------
initial begin
    fp = $fopen("agm_log.txt", "w");

    if (fp == 0) begin
        $display("ERROR: Could not open agm_log.txt for writing.");
        $stop;
    end

    $display("Log file opened: agm_log.txt");
end

// --------------------------------------------------
// Simulation sequence
// --------------------------------------------------
initial begin

    $display("----- START SIMULATION -----");
    $fdisplay(fp, "----- START SIMULATION -----");

    #200;
    rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;

    // run enough cycles for full image + reading
    repeat (300000) @(posedge clk);

    // Final report
    $display("----- END SIMULATION -----");
    $fdisplay(fp, "\n----- END SIMULATION -----");

    $fdisplay(fp, "E_MEM_ADDR active cycles = %0d", cycles_E);
    $fdisplay(fp, "W_BRAM_ADDR active cycles = %0d", cycles_W);
    $fdisplay(fp, "R_BRAM_ADDR active cycles = %0d", cycles_R);

    $display("Cycle Summary:");
    $display("  E_MEM_ADDR = %0d cycles", cycles_E);
    $display("  W_BRAM_ADDR = %0d cycles", cycles_W);
    $display("  R_BRAM_ADDR = %0d cycles", cycles_R);

    $fclose(fp);
    $display("Log file closed.");

    $stop;
end

// --------------------------------------------------
// Count active cycles
// --------------------------------------------------
always @(posedge clk) begin
    if (!rst) begin
        if (en_E) cycles_E <= cycles_E + 1;
        if (en_W) cycles_W <= cycles_W + 1;
        if (en_R) cycles_R <= cycles_R + 1;
    end
end

// --------------------------------------------------
// Write module activity to log file
// --------------------------------------------------
always @(posedge clk) begin
    if (en_E)
        $fdisplay(fp, "E: time=%0t  addr=%0d  last=%b", $time, e_addr, e_last);

    if (en_W)
        $fdisplay(fp, "W: time=%0t  addr=%0d  frame_filled=%b", $time, w_addr, w_frame_filled);

    if (en_R)
        $fdisplay(fp, "R: time=%0t  addr=%0d  valid=%b", $time, r_addr, r_valid);
end

endmodule
