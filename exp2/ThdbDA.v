
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

reg descending;

reg [13:0] DAC_DA;


parameter [13:0] A1 = 14'h3FFF;
parameter [13:0] A2 = 14'h37FF;
parameter [13:0] A3 = 14'h2FFF;

reg [13:0] HeightMax = A1;
reg [13:0] increment = 14'h131;

//0=A1，1=A2，2=A3
reg [1:0] wave_sel = 2'd0;



assign PLL_OUT_DAC0 = CLOCK_100;
assign PLL_OUT_DAC1 = CLOCK_100;
assign DAC_WRTA     = CLOCK_100;
assign DAC_MODE = 1'b1;

always @(posedge CLOCK_100 or negedge rst_n)
begin

    if (!rst_n)
    begin
        DAC_DA     <= 14'b0;
        descending <= 1'b0;

        HeightMax  <= A1;
        wave_sel   <= 2'd0;
    end

    else
    begin

        if (descending)
        begin
            DAC_DA <= DAC_DA - increment;

            if (DAC_DA < increment + increment)
            begin
                descending <= 1'b0;

                case (wave_sel)

                    2'd0:
                    begin
                        HeightMax <= A2;
                        wave_sel  <= 2'd1;
                    end

                    2'd1:
                    begin
                        HeightMax <= A3;
                        wave_sel  <= 2'd2;
                    end

                    default:
                    begin
                        HeightMax <= A1;
                        wave_sel  <= 2'd0;
                    end

                endcase
            end

            else
                ;

        end


        else
        begin
            DAC_DA <= DAC_DA + increment;

            if (DAC_DA > HeightMax - increment - increment)
                descending <= 1'b1;
            else
                ;
        end

    end
end

endmodule