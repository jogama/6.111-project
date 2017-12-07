`timescale 1ns / 100ps

////////////////////////////////////////////////////////////////////////////////
// Create Date:   15:05:40 11/26/2017
// Verilog Test Fixture created by ISE for module: pwm
// Author: Jonathan Garcia-Mallen ~ jogama@mit.edu
////////////////////////////////////////////////////////////////////////////////

module pwm_tb;

   // Inputs
   reg reset;
   reg clk;
   reg one_MHz_enable;
   reg [6:0] duty_cycle;

   // Outputs
   wire      out;

   // Instantiate the Unit Under Test (UUT)
   pwm #(.PERIOD('d100), .ONE_PCT_PERIOD('d1)) 
   uut (
	    .reset(reset), 
	    .clk(clk), 
	    .one_MHz_enable(one_MHz_enable), 
	    .duty_cycle(duty_cycle), 
	    .out(out)
	    );

   initial forever #1  clk = ~clk;
   initial forever #100 one_MHz_enable = ~one_MHz_enable; // this fine for simulation
   initial begin
      // for gtkwave simulation
      $dumpfile("pwm_tb.vcd");
      $dumpvars(0,duty_cycle, one_MHz_enable, clk, out);
      
      // Initialize Inputs
      clk = 0;
      one_MHz_enable = 0;
      reset = 1;
      duty_cycle = 0;

      // Wait 100 ns for global reset to finish
      #100;
      
      // Add stimulus here
      reset = 0;

      for(duty_cycle = 0; duty_cycle <= 'd100; duty_cycle = duty_cycle + 'd15) begin
	 $display("test with %d per cent duty cycle", duty_cycle);
	 #3000;
      end

      // we're done!
      $stop();
      $finish();
   end // initial begin
   
endmodule // pwm_tb
