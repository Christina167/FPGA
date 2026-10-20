// Experiment 3: minimum RAM port-B readout module.
// This is the two-line address-scan example in section 3.5,
// with only a module interface added.
module SpectrumTest(
    input  wire        CLOCK_50,
    input  wire        rst_n,
    input  wire [31:0] channel_count,
    output reg  [9:0]  channel_address /* synthesis preserve */,
    output wire [31:0] count
);
    always @(posedge CLOCK_50 or negedge rst_n) begin
        if (!rst_n)
            channel_address <= 10'd0;
        else
            channel_address <= channel_address + 1'b1;
    end

    assign count = channel_count;
endmodule
