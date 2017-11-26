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
   pwm uut (
	    .reset(reset), 
	    .clk(clk), 
	    .one_MHz_enable(one_MHz_enable), 
	    .duty_cycle(duty_cycle), 
	    .out(out)
	    );

   reg one_MHz_clk;
   initial forever #10  clk = ~clk;
   initial forever #100 one_MHz_clk = ~one_MHz_clk; // this fine for simulation
   initial begin
      // for gtkwave simulation
      $dumpfile("pwm_tb.vcd");
      $dumpvars(0,duty_cycle, one_MHz_clk, clk, out);
      
      // Initialize Inputs
      clk = 0;
      one_MHz_clk = 0;
      reset = 0;
      duty_cycle = 0;

      // Wait 100 ns for global reset to finish
      #100;
      
      // Add stimulus here
      
      // test with 100% duty cycle
      duty_cycle = 7'd100;
      #1000;
      
      // test with 50% duty cycle
      duty_cycle = 7'd50;
      #1000;
      
      
      // test with 25% duty cycle
      duty_cycle = 7'd25;
      #1000;
            
      // test with 10% duty cycle
      duty_cycle = 7'd10;
      #1000;
            
      // test with 60% duty cycle
      duty_cycle = 7'd60;
      #1000;      
      
      // test with 80% duty cycle
      duty_cycle = 7'd80;
      #1000;

      // we're done!
      $stop();
      $finish();
   end // initial begin
   
endmodule // pwm_tb
