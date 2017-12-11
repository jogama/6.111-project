module passthrough(input reset, clk, enable, 
		   input [5:0] speed, 
		   output signed [7:0] wheel_left, wheel_right);
   
   assign wheel_left  =  reset || ~enable ? 0 : speed;
   assign wheel_right =  reset || ~enable ? 0 : speed;
endmodule // passthrough

module pass2pwm(input reset, clk, enable, one_MHz_enable,
		input [4:0] speed,
		output wheel_sig_left, wheel_sig_right);

   // the zero for these servos is 60% duty
   wire [6:0] duty_left  = reset || ~enable ? 0 : 'd60 + speed;
   wire [6:0] duty_right = reset || ~enable ? 0 : 'd60 - speed;
   
   pwm pleft(.reset(reset), .clk(clk), .one_MHz_enable(one_MHz_enable),
     .duty_cycle(duty_left), .out(wheel_sig_left));

   pwm pright(.reset(reset), .clk(clk), .one_MHz_enable(one_MHz_enable),
	     .duty_cycle(duty_right), .out(wheel_sig_right));

endmodule // pass2pwm
