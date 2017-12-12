`timescale 1ns / 100ps

////////////////////////////////////////////////////////////////////////////////
// Create Date:   15:05:40 11/26/2017
// Verilog Test Fixture created by ISE for module: pwm
// Author: Jonathan Garcia-Mallen ~ jogama@mit.edu
////////////////////////////////////////////////////////////////////////////////

module task_manager_tb;

   // Inputs
   reg reset;
   reg start;
   reg clk;
   reg oneHz_enable;

   // Outputs
   wire enable_forward;
   wire [1:0] state;


   task_manager 
     uut (
	  .reset(reset),
	  .start(start),
	  .clk(clk), 
	  .oneHz_enable(oneHz_enable), 
	  .enable_forward(enable_forward),
	  .state(state)
	  );

   initial forever #1  clk = ~clk;
   initial forever #100 oneHz_enable = ~oneHz_enable; // this fine for simulation
   initial begin
      // for gtkwave simulation
      $dumpfile("task_manager_tb.vcd");
      $dumpvars(0, task_manager_tb);
      
      // Initialize Inputs
      clk = 0;
      oneHz_enable = 0;
      start = 0;
      reset = 1;

      // Wait 100 ns for global reset to finish
      #100;
      
      // Add stimulus here
      reset = 0;
      start = 1;
      #2;
      start = 0;
      
      #3500;
      
      // we're done!
      $stop();
      $finish();
   end // initial begin
   
endmodule // pwm_tb
