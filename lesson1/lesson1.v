module lesson1(
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5,
    KEY,
    CLOCK_50
);

output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [6:0] HEX4;
output [6:0] HEX5;

input [1:0] KEY;
input CLOCK_50;

wire CLOCK_1;

pll pll1(
    .refclk   (CLOCK_50),
    .rst      (1'b0),
    .outclk_0 (CLOCK_1)
);




reg [13:0] counter1;


// 6 个 BCD 数字，每位占 4 bit：

reg [23:0] counter2;

reg key_flag;

reg [1:0] key_inner;

always @(posedge CLOCK_1)
begin
    key_inner <= KEY;
end


always @(negedge key_inner[0])
begin
    key_flag <= ~key_flag;
end



always @(posedge CLOCK_1)
begin

    if (!key_inner[1] && key_flag == 1)
    begin
        counter1 <= 14'd0;
        counter2 <= 24'h000000;
    end

    else if (!key_flag)
    begin

        if (counter1 == 14'd9999)
        begin
            counter1 <= 14'd0;
				

            // 百分之一秒个位：0 ~ 9
            if (counter2[3:0] < 4'd9)
            begin
                counter2[3:0] <= counter2[3:0] + 4'd1;
            end

            else
            begin
                counter2[3:0] <= 4'd0;


                // 百分之一秒十位：0 ~ 9
                if (counter2[7:4] < 4'd9)
                begin
                    counter2[7:4] <= counter2[7:4] + 4'd1;
                end

                else
                begin
                    counter2[7:4] <= 4'd0;


                    // 秒个位：0 ~ 9
                    if (counter2[11:8] < 4'd9)
                    begin
                        counter2[11:8] <= counter2[11:8] + 4'd1;
                    end

                    else
                    begin
                        counter2[11:8] <= 4'd0;


                        // 秒十位：0 ~ 5
                        if (counter2[15:12] < 4'd5)
                        begin
                            counter2[15:12]
                                <= counter2[15:12] + 4'd1;
                        end

                        else
                        begin
                            counter2[15:12] <= 4'd0;


                            // 分钟个位：0 ~ 9
                            if (counter2[19:16] < 4'd9)
                            begin
                                counter2[19:16]
                                    <= counter2[19:16] + 4'd1;
                            end

                            else
                            begin
                                counter2[19:16] <= 4'd0;


                                // 分钟十位：0 ~ 5
                                if (counter2[23:20] < 4'd5)
                                begin
                                    counter2[23:20]
                                        <= counter2[23:20] + 4'd1;
                                end

                                else
                                begin
                                    // 59:59.99 后回到 00:00.00
                                    counter2 <= 24'h000000;
                                end

                            end
                        end
                    end
                end
            end
        end

		  
        else
        begin
            counter1 <= counter1 + 14'd1;
        end

    end

end




hex hex0(
    .HEX0     (HEX0[6:0]),
    .HEX1     (HEX1[6:0]),
    .HEX2     (HEX2[6:0]),
    .HEX3     (HEX3[6:0]),
    .HEX4     (HEX4[6:0]),
    .HEX5     (HEX5[6:0]),
    .hex_data (counter2)
);

endmodule