module passthrough(input reset, clk, enable, 
		   input [5:0] speed, 
		   output signed [7:0] wheel_left, wheel_right);
   
   assign wheel_left  =  reset || ~enable ? 0 : speed;
   assign wheel_right =  reset || ~enable ? 0 : speed;
endmodule // passthrough
