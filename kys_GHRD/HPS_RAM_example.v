
module HPS_RAM_example(
    clk,
    channel_address_write,
    channel_count_write_en,
    channel_count_write,
    channel_count_read
);

input clk;
output reg [5:0] channel_address_write;
output reg channel_count_write_en;
output reg [31:0] channel_count_write;
input [31:0] channel_count_read;

parameter num = 50_000_000;
parameter state_write = 1'b1;
parameter state_read = 1'b0;

reg [31:0] cnt = 0;
reg [1:0] state;
reg [5:0] address = 0;

always @(posedge clk) begin
    if (cnt < num) begin
        cnt <= cnt + 1;
        state <= state_read;
    end
    else begin
        cnt <= 0;
        state <= state_write;
        address <= address + 1;
    end
end

always @(state) begin
    case (state)
        state_read: begin
            channel_count_write_en = 1'b0;
            channel_address_write = address;
            channel_count_write = 0;
        end
        state_write: begin
            channel_count_write_en = 1'b1;
            channel_address_write = address;
            channel_count_write = channel_count_read + 1;
        end
    endcase
end

endmodule
