module ThdbDA(
    PLL_OUT_DAC0,
    PLL_OUT_DAC1,
    DAC_WRTA,
    DAC_MODE,
    DAC_DA,
    KEY,
    rst_n,
    CLOCK_100
);

output PLL_OUT_DAC0;
output PLL_OUT_DAC1;
output DAC_WRTA;
output DAC_MODE;
output [13:0] DAC_DA;

input [3:0] KEY;
input rst_n;
input CLOCK_100;

reg [13:0] DAC_DA;


// 固定周期随机幅度脉冲参数

// 16位LFSR伪随机数
reg [15:0] lfsr;

// 当前脉冲幅度
reg [13:0] pulse_amp;

// 脉冲周期计数器
reg [15:0] pulse_count;


parameter [15:0] PULSE_PERIOD = 16'd160;

parameter [15:0] PULSE_WIDTH  = 16'd32;


// 随机脉冲幅度：
// 0x3000 ~ 0x3FFF
wire [13:0] random_amp;

assign random_amp =
       14'h3000
     + {2'b00, lfsr[11:0]};



assign PLL_OUT_DAC0 = CLOCK_100;
assign PLL_OUT_DAC1 = CLOCK_100;
assign DAC_WRTA     = CLOCK_100;
assign DAC_MODE = 1'b1;

always @(posedge CLOCK_100 or negedge rst_n)
begin

    if (!rst_n)
    begin
        DAC_DA      <= 14'b0;

        lfsr        <= 16'hACE1;

  
        pulse_count <= 16'd0;

        pulse_amp   <= 14'h3CE1;
    end

    else
    begin

        lfsr <= {
            lfsr[14:0],
            lfsr[15] ^ lfsr[13]
                     ^ lfsr[12]
                     ^ lfsr[10]
        };


        if (pulse_count >= PULSE_PERIOD - 16'd1)
        begin
            pulse_count <= 16'd0;

            pulse_amp <= random_amp;
        end
        else
        begin
            pulse_count <= pulse_count + 16'd1;
        end


        if (pulse_count < PULSE_WIDTH)
            DAC_DA <= pulse_amp;
        else
            DAC_DA <= 14'b0;

    end
end              

endmodule