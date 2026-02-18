`timescale 1ns / 1ps


//module E_MEM_ADDR #(
//    parameter IMG_SIZE = 512*512   // or any size
//)(
//    input clk, rst, enable,
//    output reg [17:0] addr,
//    output reg last
//);

//always @(posedge clk) begin
//    if (rst) begin
//        addr <= 0;
//        last <= 0;
//    end
//    else begin
//        if (enable) begin
//            if (addr == IMG_SIZE-1) begin
//                addr <= 0;
//                last <= 1;        // assert and HOLD until enable is deasserted
//            end
//            else begin
//                addr <= addr + 1;
//                // do not clear last here; keep last asserted until enable goes low
//            end
//        end
//        else begin
//            // when enable is low, clear the last flag so next run can assert it again
//            last <= 0;
//            // keep addr as-is or reset to 0 depending on desired behavior
//        end
//    end
//end

//endmodule



//module E_MEM_ADDR #(
//    parameter IMG_SIZE = 512*512,   // Total image size
//    parameter IMAGE_WIDTH = 512,    // Width of image
//    parameter RB_COUNT = 4,         // Number of row buffers
//    parameter STALL_CYCLES = 1      // Number of cycles to stall
//)(
//    input clk, rst, enable,
//    output reg [17:0] addr,
//    output reg last
//);

//// Calculate the stall point
//localparam STALL_POINT = IMAGE_WIDTH * RB_COUNT - 1;

//// Internal signals
//reg [31:0] stall_counter;
//reg stalling;

//always @(posedge clk) begin
//    if (rst) begin
//        addr <= 0;
//        last <= 0;
//        stall_counter <= 0;
//        stalling <= 0;
//    end
//    else begin
//        if (enable) begin
//            if (stalling) begin
//                // During stall period
//                if (stall_counter == STALL_CYCLES - 1) begin
//                    stalling <= 0;
//                    stall_counter <= 0;
//                    addr <= addr + 1;
//                end
//                else begin
//                    stall_counter <= stall_counter + 1;
//                end
//            end
//            else begin
//                // Normal operation
//                if (addr == STALL_POINT) begin
//                    stalling <= 1;
//                    stall_counter <= 0;
//                    // Keep address at STALL_POINT during stall
//                end
                                
                                
//                else if (addr == IMG_SIZE-1) begin
//                    addr <= 0;
//                    last <= 1;        // assert and HOLD until enable is deasserted
//                end
//                else begin
//                    addr <= addr + 1;
//                end
//            end
//        end
//        else begin
//            // when enable is low, clear the last flag so next run can assert it again
//            last <= 0;
//            stalling <= 0;
//            stall_counter <= 0;
//            // keep addr as-is or reset to 0 depending on desired behavior
//             addr <= 0;  // Uncomment if you want to reset address when disabled
//        end
//    end
//end

//endmodule



module E_MEM_ADDR #(
    parameter IMG_SIZE = 256*256,   // Total image size
    parameter IMAGE_WIDTH = 256,    // Width of image
    parameter RB_COUNT = 8,         // Number of row buffers
    parameter STALL_CYCLES = 1      // Number of cycles to stall
)(
    input clk, rst, enable,
    output reg [17:0] addr,
    output reg last
);

// Calculate the stall point
localparam STALL_POINT = IMAGE_WIDTH * RB_COUNT - 1;

// Internal signals
reg [31:0] stall_counter;
reg stalling;

always @(posedge clk) begin
    if (rst) begin
        addr <= 0;
        last <= 0;
        stall_counter <= 0;
        stalling <= 0;
    end
    else begin
        // Default clear of last (pulse)
        last <= 0;

        if (enable) begin
            if (stalling) begin
                // During stall period
                if (stall_counter == STALL_CYCLES - 1) begin
                    stalling <= 0;
                    stall_counter <= 0;
                    addr <= addr + 1;
                end
                else begin
                    stall_counter <= stall_counter + 1;
                end
            end
            else begin
                // If next increment will reach final address, assert 'last' now
                if (addr == IMG_SIZE-2) begin
                    last <= 1;         // assert one cycle early
                    addr <= addr + 1;  // move to final address next clock
                end
                else if (addr == STALL_POINT) begin
                    stalling <= 1;
                    stall_counter <= 0;
                    // keep addr at STALL_POINT during stall
                end
                else if (addr == IMG_SIZE-1) begin
                    addr <= 0;
                    // 'last' was already pulsed previous cycle; no need to hold it
                end
                else begin
                    addr <= addr + 1;
                end
            end
        end
        else begin
            // when enable is low, clear last and stalling, reset addr
            last <= 0;
            stalling <= 0;
            stall_counter <= 0;
            addr <= 0;  // reset when disabled (optional)
        end
    end
end

endmodule







