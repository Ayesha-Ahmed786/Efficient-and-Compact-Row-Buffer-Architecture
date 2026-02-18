`timescale 1ns / 1ps
module ROW_BUFFER_SYSTEM #(
    parameter PIXEL_BITS   = 8,
    parameter IMAGE_WIDTH  = 256,
    parameter KERNEL_SIZE  = 9,
    parameter RB_COUNT     = KERNEL_SIZE - 1,
    parameter STALL_CYCLES = 1
)(
    input  wire clk,
    input  wire rst,

    // External memory read port (source of pixels to write into row buffers)
    input  wire [PIXEL_BITS-1:0] ext_data_in,
    input  wire                  ext_data_valid,

    // Outputs from the row-buffer reading (to the pattern generator / SM)
    output wire [PIXEL_BITS*RB_COUNT-1:0] rb_read_data,
    output wire [RB_COUNT-1:0]             rb_pixel_valid,
    output wire [PIXEL_BITS*RB_COUNT-1:0] rb_steered_data

    // add other I/O as needed
);

    // Derived widths
    localparam MEM_DEPTH       = RB_COUNT * IMAGE_WIDTH;
    localparam W_ADDR_WIDTH    = $clog2(MEM_DEPTH);
    localparam R_ADDR_WIDTH    = $clog2(IMAGE_WIDTH);

    // Control unit signals
    wire en_E, en_W, en_R;
    wire E_last;
    wire W_frame_filled;
    wire [$clog2(RB_COUNT)-1:0] steer_sel;

    // E_MEM_ADDR wires
    wire [17:0] e_addr;
    // W_BRAM_ADDR wires
    wire [W_ADDR_WIDTH-1:0] w_write_addr;
    // R_BRAM_ADDR wires
    wire [R_ADDR_WIDTH-1:0] r_read_addr;
    wire [RB_COUNT-1:0]     r_pixel_valid;

    // MM signals
    wire [PIXEL_BITS-1:0] mm_write_data;
    wire [PIXEL_BITS*RB_COUNT-1:0] mm_read_data;
    wire [PIXEL_BITS*RB_COUNT-1:0] steered_data;
    wire mm_we;
    wire mm_re;

    // -------------------------------------------------------------------------
    // Instantiate CONTROL_UNIT
    // -------------------------------------------------------------------------
    CONTROL_UNIT #(
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .RB_COUNT(RB_COUNT),
        .STALL_CYCLES(STALL_CYCLES)
    ) ctrl (
        .clk(clk),
        .rst(rst),

        .en_E(en_E),
        .en_W(en_W),
        .en_R(en_R),

        // inputs from submodules
        .E_last(E_last),
        .W_frame_filled(W_frame_filled),
        .steer_sel(steer_sel)

    );

    // -------------------------------------------------------------------------
    // Instantiate E_MEM_ADDR: external memory address generator (source)
    // -------------------------------------------------------------------------
    // It produces e_addr and last (E_last). The actual external memory read logic
    // that supplies ext_data_in must be driven using e_addr/en_E (not shown here).
    E_MEM_ADDR #(
        .IMG_SIZE(IMAGE_WIDTH*IMAGE_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .RB_COUNT(RB_COUNT),
        .STALL_CYCLES(STALL_CYCLES)
    ) e_addr_gen (
        .clk(clk),
        .rst(rst),
        .enable(en_E),
        .addr(e_addr),
        .last(E_last)
    );

    // -------------------------------------------------------------------------
    // Instantiate W_BRAM_ADDR: write address generator (writes into MM)
    // -------------------------------------------------------------------------
    W_BRAM_ADDR #(
        .RB_COUNT(RB_COUNT),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .MEM_DEPTH(MEM_DEPTH),
        .STALL_CYCLES(STALL_CYCLES)
    ) w_addr_gen (
        .clk(clk),
        .rst(rst),
        .enable(en_W),
        .write_addr(w_write_addr),
        .frame_filled(W_frame_filled)
    );

    // -------------------------------------------------------------------------
    // Instantiate R_BRAM_ADDR: read address generator (reads from MM)
    // -------------------------------------------------------------------------
    R_BRAM_ADDR #(
        .RB_COUNT(RB_COUNT),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .MEM_DEPTH(IMAGE_WIDTH),          // read depth is IMAGE_WIDTH (R0..R511)
        .PIXEL_PER_READ(RB_COUNT)
    ) r_addr_gen (
        .clk(clk),
        .rst(rst),
        .enable(en_R),
        .read_addr(r_read_addr),
        .pixel_group_valid(r_pixel_valid)
    );
    
    

    // -------------------------------------------------------------------------
    // Connect external data to MM write data
    // (Assumes ext_data_in is valid when ext_data_valid==1 and en_E is high)
    // You may need to pipeline/align ext_data_valid with writes in your design.
    // -------------------------------------------------------------------------
    assign mm_write_data = ext_data_in;

    // Use control enables directly as mm_we/mm_re
    // Optionally register these signals if you need the "see-disable-one-cycle-earlier" property
    assign mm_we = en_W;   // write enable to MM (driven by W_BRAM_ADDR enable)
    assign mm_re = en_R;   // read enable to MM (driven by R_BRAM_ADDR enable)

    // -------------------------------------------------------------------------
    // Instantiate MM (memory model)
    // -------------------------------------------------------------------------
    MM #(
        .PIXEL_BITS(PIXEL_BITS),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE),
        .RB_COUNT(RB_COUNT)
    ) mm_inst (
        .clk(clk),
        .rst(rst),
        // write side
        .we(mm_we),
        .write_data(mm_write_data),
        .write_addr(w_write_addr[$clog2(MEM_DEPTH)-1:0]),
        // read side
        .re(mm_re),
        .read_addr(r_read_addr),
        .read_data(mm_read_data)
    );
        
    STEER_MODULE #(
        .PIXEL_BITS(PIXEL_BITS),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) steer_inst (
        .clk(clk),
        .rst(rst),
        .packed_pixels_in(mm_read_data),
        .sel(steer_sel),
        .out(steered_data)
    );


    // Expose outputs
    assign rb_read_data  = mm_read_data;

    assign rb_pixel_valid = r_pixel_valid;
    assign rb_steered_data = steered_data;
endmodule




