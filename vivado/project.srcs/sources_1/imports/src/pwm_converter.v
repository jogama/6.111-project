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


/* 
 all this does is convert the wheel_cmd to a duty cycle. We might use
 the pwm for sound, so it doesn't need to know anything about wheels
 
 Default parameters are set for the SM_S4303R servo motors running at
 440Hz, or 2273µs period zero is the duty cycle at which the motor
 stops. It would be better for zero to be in µs instead of %.
 */


module pwm_converter #(parameter FLIPPED=1'b0,
		       parameter ZERO=7'd60)
   (input reset, input clk, input one_MHz_enable,
    input signed [7:0] wheel_cmd, 
    output reg 	       wheel_signal);
   
   wire [6:0] duty_cycle;

   // this feels quite dirty
   // What we really want is duty_cycle = wheel_cmd*(50/127)+60, or something along those lines,
   // because wheel_cmd is 8-bits signed over (-127, 127) and duty_cycle is 6 bits representing a
   // percent. This will have to be rethinked. But for now, we'll do this:
   // first, arithmetic divide by 4 to
   //   1. fit it into the 7-bit duty wire
   //   2. prevent overflow when adding 'd60
   
   // then add 'd60
   wire signed [5:0] wheel_cmd_fourthed = wheel_cmd <<< 4;
   
   assign duty_cycle = // FLIPPED ? we aren't implementing flipped right now
		       wheel_cmd_fourthed + ZERO;
   
   // later perhaps add parameters to pwm_wheel_cmd. These would be passed here to 
   pwm p(.reset(reset), .clk(clk), .one_MHz_enable(one_MHz_enable),
	 .duty_cycle(duty_cycle), .out(wheel_signal));
endmodule // pwm_converter
