
module exp2(
    PLL_OUT_DAC0,
    PLL_OUT_DAC1,
    DAC_WRTA,
    DAC_MODE,
    DAC_DA,
    PLL_OUT_ADC0,
    ADC_OEA,
    ADC_OTRA,
    ADC_DA,
    KEY,
    CLOCK_50
);
    output PLL_OUT_DAC0;
    output PLL_OUT_DAC1;
    output DAC_WRTA;
    output DAC_MODE;
    output [13:0] DAC_DA;
    output PLL_OUT_ADC0;
    output ADC_OEA;
    input ADC_OTRA;
    input [13:0] ADC_DA;
    input [3:0] KEY;
    input CLOCK_50;

    wire CLOCK_65;
    wire CLOCK_100;
    wire [13:0] ad_data;
    wire pulse_indicator;
    wire [13:0] pulse_height;
    wire rst_n = KEY[0];


    pll pll0(
        .refclk   (CLOCK_50),
        .rst      (~rst_n),
        .outclk_0 (CLOCK_65),
        .outclk_1 (CLOCK_100)
    );

    ThdbDA ThdbDA0(
        .PLL_OUT_DAC0 (PLL_OUT_DAC0),
        .PLL_OUT_DAC1 (PLL_OUT_DAC1),
        .DAC_WRTA     (DAC_WRTA),
        .DAC_MODE     (DAC_MODE),
        .DAC_DA       (DAC_DA[13:0]),
        .KEY          (KEY[3:0]),
        .rst_n        (rst_n),
        .CLOCK_100    (CLOCK_100)
    );

    ThdbAD ThdbAD0(
        .PLL_OUT_ADC0 (PLL_OUT_ADC0),
        .ADC_OEA      (ADC_OEA),
        .ad_data      (ad_data[13:0]),
        .ADC_OTRA     (ADC_OTRA),
        .ADC_DA       (ADC_DA[13:0]),
        .CLOCK_65     (CLOCK_65)
    );

    PulseHeight PulseHeight0(
        .pulse_height    (pulse_height[13:0]),
        .pulse_indicator (pulse_indicator),
        .ad_data        (ad_data[13:0]),
        .rst_n          (rst_n),
        .CLOCK_65       (CLOCK_65)
    );


    reg [3:1] key_meta, key_sync, key_last;
    always @(posedge CLOCK_65 or negedge rst_n) begin
        if (!rst_n) begin
            key_meta <= 3'b111;
            key_sync <= 3'b111;
            key_last <= 3'b111;
        end
        else begin
            key_meta <= KEY[3:1];
            key_sync <= key_meta;
            key_last <= key_sync;
        end
    end

    wire cmd_start = key_last[1] && !key_sync[1];
    wire cmd_pause = key_last[2] && !key_sync[2];
    wire cmd_clear = key_last[3] && !key_sync[3];

    wire [9:0] channel_address_write /* synthesis keep */;
    wire       channel_count_write_en /* synthesis keep */;
    wire [31:0] channel_count_write /* synthesis keep */;
    wire [31:0] channel_count_read /* synthesis keep */;

    Spectrum Spectrum0(
        .channel_address_write  (channel_address_write),
        .channel_count_write_en (channel_count_write_en),
        .channel_count_write    (channel_count_write),
        .channel_count_read     (channel_count_read),
        .pulse_height          (pulse_height),
        .pulse_indicator       (pulse_indicator),
        .cmd_start             (cmd_start),
        .cmd_pause             (cmd_pause),
        .cmd_clear             (cmd_clear),
        .rst_n                 (rst_n),
        .CLOCK_65              (CLOCK_65)
    );


    wire [9:0] channel_address_b /* synthesis keep */;
    wire [31:0] channel_count_b /* synthesis keep */;
    wire [31:0] spectrum_count /* synthesis keep */;

    SpectrumTest SpectrumTest0(
        .CLOCK_50       (CLOCK_50),
        .rst_n          (rst_n),
        .channel_count  (channel_count_b),
        .channel_address(channel_address_b),
        .count          (spectrum_count)
    );


	 

    RAM RAM0(
        .clock_a   (CLOCK_65),
        .address_a (channel_address_write),
        .data_a    (channel_count_write),
        .wren_a    (channel_count_write_en),
        .q_a       (channel_count_read),
	 
	 
        .clock_b   (CLOCK_50),
        .address_b (channel_address_b),
        .data_b    (32'd0),
        .wren_b    (1'b0),
        .q_b       (channel_count_b)
    );
endmodule
