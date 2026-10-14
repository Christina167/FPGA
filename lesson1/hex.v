module hex(
    HEX0, 
    HEX1, 
    HEX2, 
    HEX3, 
    HEX4, 
    HEX5, 
    hex_data
);

output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [6:0] HEX4;
output [6:0] HEX5;

input [23:0] hex_data;

function [6:0] code;
    input [3:0] digit;

    code = digit == 4'h0 ? 7'b1000000 :
           digit == 4'h1 ? 7'b1111001 :
           digit == 4'h2 ? 7'b0100100 :
           digit == 4'h3 ? 7'b0110000 :
           digit == 4'h4 ? 7'b0011001 :
           digit == 4'h5 ? 7'b0010010 :
           digit == 4'h6 ? 7'b0000010 :
           digit == 4'h7 ? 7'b1111000 :
           digit == 4'h8 ? 7'b0000000 :
           digit == 4'h9 ? 7'b0010000 :
           digit == 4'hA ? 7'b0001000 :
           digit == 4'hB ? 7'b0000011 :
           digit == 4'hC ? 7'b1000110 :
           digit == 4'hD ? 7'b0100001 :
           digit == 4'hE ? 7'b0000110 :
                           7'b0001110;
endfunction

assign HEX0 = code(hex_data[3:0]);
assign HEX1 = code(hex_data[7:4]);
assign HEX2 = code(hex_data[11:8]);
assign HEX3 = code(hex_data[15:12]);
assign HEX4 = code(hex_data[19:16]);
assign HEX5 = code(hex_data[23:20]);

endmodule