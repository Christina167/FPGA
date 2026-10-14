module ThdbAD( 
   PLL_OUT_ADC0,  
   ADC_OEA,  
   ad_data, 
   ADC_OTRA,  
   ADC_DA, 
   CLOCK_65 
  ); 
 
    output    PLL_OUT_ADC0; 
    output    ADC_OEA; 
    output [13:0]   ad_data; 
    input          ADC_OTRA;  
    input          CLOCK_65; 
    input [13:0]  ADC_DA; 
    reg [13:0]     ad_data; 
 
    assign  PLL_OUT_ADC0  =  CLOCK_65; 
    assign  ADC_OEA   =  1'b0; 
 
    always @(negedge CLOCK_65) 
  begin 
   ad_data <= ADC_DA; 
  end 
endmodule