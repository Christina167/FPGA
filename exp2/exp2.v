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
 
    output         PLL_OUT_DAC0; 
    output         PLL_OUT_DAC1; 
    output         DAC_WRTA; 
    output         DAC_MODE; 
    output [13:0]   DAC_DA; 
    output   PLL_OUT_ADC0; 
    output         ADC_OEA; 
 input   ADC_OTRA; 
    input [13:0]    ADC_DA; 
 input [3:0]   KEY; 
 input    CLOCK_50; 
 wire    CLOCK_65; 
 wire    CLOCK_100;  
    wire [13:0]   ad_data; 
    wire          pulse_indicator; 
    wire [13:0]   pulse_height; 
 wire          rst_n = KEY[0]; 
  
 pll pll0( 
   .refclk    (CLOCK_50), 
   .rst     (~rst_n), 
   .outclk_0    (CLOCK_65), 
   .outclk_1    (CLOCK_100) 
  ); 
 
 ThdbDA ThdbDA0( 
   .PLL_OUT_DAC0   (PLL_OUT_DAC0),  
   .PLL_OUT_DAC1   (PLL_OUT_DAC1),  
   .DAC_WRTA    (DAC_WRTA),  
   .DAC_MODE    (DAC_MODE), 
   .DAC_DA    (DAC_DA[13:0]),  
   .KEY     (KEY[3:0]), 
   .rst_n     (rst_n),  
   .CLOCK_100    (CLOCK_100) 
  );   
 
 ThdbAD ThdbAD0( 
   .PLL_OUT_ADC0   (PLL_OUT_ADC0),  
   .ADC_OEA    (ADC_OEA),  
   .ad_data     (ad_data[13:0]), 
   .ADC_OTRA    (ADC_OTRA),  
   .ADC_DA    (ADC_DA[13:0]), 
   .CLOCK_65    (CLOCK_65)    
  ); 
     
 PulseHeight PulseHeight0( 
   .pulse_height    (pulse_height[13:0]), 
   .pulse_indicator    (pulse_indicator), 
   .ad_data     (ad_data[13:0]), 
   .rst_n     (rst_n), 
   .CLOCK_65    (CLOCK_65) 
  );  
endmodule