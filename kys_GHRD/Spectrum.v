module Spectrum(    
channel_address_write,  
channel_count_write_en,  
channel_count_write, 
channel_count_read, 
pulse_height,  
pulse_indicator,  
cmd_start,  
cmd_pause,  
   cmd_clear,    
   rst_n,  
   CLOCK_65   
  ); 
    parameter   STATE_PAUSE = 5'b00001; 
    parameter   STATE_IDLE  = 5'b00010; 
    parameter   STATE_READ = 5'b00100; 
    parameter   STATE_WRITE = 5'b01000; 
    parameter   STATE_CLEAR = 5'b10000; 
    output [9:0]   channel_address_write; 
    output        channel_count_write_en; 
    output [31:0]   channel_count_write;  
 input [31:0]    channel_count_read;   
    input [13:0]    pulse_height;   
    input          pulse_indicator; 
    input          cmd_start; 
    input          cmd_pause;  
    input          cmd_clear;  
    input          rst_n; 
    input          CLOCK_65; 
    reg [4:0]   state /*synthesis noprune*/; 
    reg [9:0]       clear_count;  
    reg [9:0]       channel_address_write; 
    reg             channel_count_write_en; 
    reg [31:0]      channel_count_write; 
 
    always @(posedge CLOCK_65 or negedge rst_n  
    or posedge cmd_start or posedge cmd_pause or posedge cmd_clear)  
  begin   
   if (!rst_n) 
    state <= STATE_PAUSE; 
   else if (cmd_start) 
    state <= STATE_IDLE; 
   else if (cmd_pause) 
    state <= STATE_PAUSE; 
   else if (cmd_clear) 
    state <= STATE_CLEAR;       
   else 
    case (state) 
     STATE_PAUSE: 
      clear_count <= 10'b0; 
     STATE_IDLE: 
      if (pulse_indicator) 
       state <= STATE_READ; 
      else 
       clear_count <= 10'b0; 
     STATE_READ: 
      state <= STATE_WRITE; 
     STATE_WRITE: 
      state <= STATE_IDLE; 
     STATE_CLEAR: 
      if (clear_count < 10'h3FF) 
       clear_count <= clear_count + 1'b1; 
      else  
       begin 
        clear_count <= 10'b0; 
        state <= STATE_PAUSE; 
       end 
     default: 
      state <= STATE_PAUSE; 
    endcase 
  end 
 
    always @(state)  
  begin 
   case (state) 
    STATE_PAUSE: 
     channel_count_write_en = 1'b0; 
    STATE_IDLE:  
     begin 
      channel_address_write  = pulse_height[13:4]; 
      channel_count_write  = 32'b0; 
      channel_count_write_en = 1'b0; 
     end 
    STATE_READ: 
     ; 
    STATE_WRITE:  
     begin 
      channel_count_write  = channel_count_read + 1'b1; 
      channel_count_write_en = 1'b1; 
     end 
    STATE_CLEAR:  
     begin 
      channel_address_write  = clear_count; 
      channel_count_write  = 32'b0; 
      channel_count_write_en = 1'b1; 
     end 
    default:  
     begin 
      channel_count_write  = 32'b0; 
      channel_count_write_en = 1'b0; 
     end 
   endcase 
  end 
 
endmodule