/*  FILE: pwm_converter.v
  AUTHOR: jogama@mit.edu
 
SYNOPSYS: receives signed, eight-bit motor commands in the range
 [127,127], and transforms them into a pwm wave to be sent to
 SM-S4303R servo motors 
 
 */


/* 
parameters: PERIOD is 440Hz in microsececonds by default. 
  this has emperically been shown to work.
inputs: 
  duty_cycle is percents in in the range [0,100]. Updated internally every PERIOD. 
*/ 
module pwm #(parameter PERIOD_WIDTH='d12,
	     parameter PERIOD='d2273, 
	     parameter ONE_PCT_PERIOD='d23)
   (input reset, input clk, input one_MHz_enable,
    input [6:0] duty_cycle, 
    output reg  out);

   reg [PERIOD_WIDTH-1:0] count_period; // 
   reg [PERIOD_WIDTH-1:0]  duty_length; 
     // time in µs that the output is high or 1.
     // updated when count_period is reset
    
   
   always @ (posedge clk) begin
      if(reset) begin
	 count_period <= 0;
	 duty_length  <= 0;
	 out <= 0;
      end
      else begin
	 if(one_MHz_enable) begin
	    // Increment count period
	    count_period <= count_period + 1;
	    if(count_period <= duty_length)
	      out <= 1;
	    else if(count_period <= PERIOD)
	      out <= 0;
	    else if(count_period > PERIOD) begin
	       // reset counter and update duty length
	       count_period <= 0;
	       duty_length <= duty_cycle * ONE_PCT_PERIOD;
	    end
	 end // if (one_MHz_enable)
      end // else: !if(reset)
   end // always @ (posedge clk)
endmodule // pwm

		  
