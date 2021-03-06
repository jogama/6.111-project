`timescale 1ns / 100ps

////////////////////////////////////////////////////////////////////////////////
// Create Date:   15:05:40 11/26/2017
// Verilog Test Fixture created by ISE for module: pwm_converter
// Author: Jonathan Garcia-Mallen ~ jogama@mit.edu
////////////////////////////////////////////////////////////////////////////////

module pwm_converter_tb;

   // Inputs
   reg reset;
   reg clk;
   reg one_MHz_enable;
   reg signed [7:0] wheel_cmd;
   

   // Outputs
   wire wheel_signal;
   
   // Instantiate the Unit Under Test (UUT)
   pwm_converter #(.FLIPPED(1'b1), .ZERO(7'd60), .PERIOD('d100), .ONE_PCT_PERIOD('d1)) 
   uut (.reset(reset), 
	.clk(clk), 
	.one_MHz_enable(one_MHz_enable),
	.wheel_cmd(wheel_cmd),
	.wheel_signal(wheel_signal)
	);

   initial forever #1  clk = ~clk;
   initial forever #100 one_MHz_enable = ~one_MHz_enable; // this fine for simulation
   initial begin
      // for gtkwave simulation. 
      // We pass in the module name into $dumpvars to dump everything under the module.
      $dumpfile("pwm_converter_tb.vcd");
      $dumpvars(0, pwm_converter_tb);
      
      // Initialize Inputs
      clk = 0;
      one_MHz_enable = 0;
      reset = 1;
      wheel_cmd = 0;

      // Wait 100 ns for global reset to finish
      #100;
      
      // Add stimuli
      reset = 0;
      
      // iterate eight times. 
      for(wheel_cmd = -8'd128; 
	  wheel_cmd < 8'sd96;  // 128 is out of range; use 128 - 32
	  wheel_cmd = wheel_cmd + 'sd32) begin
	 $display(wheel_cmd);
	 #3000;
      end
      $display(wheel_cmd); // final increment occurs such that loop exists before displaying 

      // we're done!
      $stop();
      $finish();
   end // initial begin
   
endmodule // pwm_tb
