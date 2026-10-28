module PulseHeight(
    pulse_height,
    pulse_indicator,
    ad_data,
    rst_n,
    CLOCK_65
);

parameter PULSE_THRES = 13'h1900;

output pulse_indicator;
output [13:0] pulse_height;

input [13:0] ad_data;
input rst_n;
input CLOCK_65;

reg above_thresh;
reg indicator;
reg [13:0] tracker;
reg [13:0] pulse_height;
reg pulse_indicator;



reg [13:0] ma_d1;
reg [13:0] ma_d2;
reg [13:0] ma_d3;

reg [13:0] smooth_data /* synthesis preserve */;




// 保存前三个采样点
always @(negedge CLOCK_65 or negedge rst_n)
begin
    if (!rst_n)
    begin
        ma_d1 <= 14'b0;
        ma_d2 <= 14'b0;
        ma_d3 <= 14'b0;
    end
    else
    begin
	  smooth_data <= (
              {2'b00, ad_data}
            + {2'b00, ma_d1}
            + {2'b00, ma_d2}
            + {2'b00, ma_d3}
        ) >> 2;

        ma_d3 <= ma_d2;
        ma_d2 <= ma_d1;
        ma_d1 <= ad_data;
    end
end




always @(negedge CLOCK_65 or negedge rst_n)
begin
    if (!rst_n)
    begin
        above_thresh <= 1'b0;
        indicator <= 1'b0;
    end
    else
    begin

        if (smooth_data <= PULSE_THRES && above_thresh)
            indicator <= 1'b1;
        else
            indicator <= 1'b0;


        if (smooth_data <= PULSE_THRES)
            above_thresh <= 1'b0;
        else
            above_thresh <= 1'b1;

    end
end




always @(negedge CLOCK_65 or negedge rst_n)
begin
    if (!rst_n)
        tracker <= 14'b0;

    else
    begin
        if (above_thresh)
        begin
            if (tracker < smooth_data)
                tracker <= smooth_data;
            else
                ;
        end
        else
            tracker <= 14'b0;
    end
end


// 脉冲结束时保存最终峰值
always @(posedge indicator)
    pulse_height <= tracker;


// 输出脉冲提示信号
always @(negedge CLOCK_65)
    pulse_indicator <= indicator;


endmodule