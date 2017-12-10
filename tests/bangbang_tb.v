`timescale 1ns / 100ps
////////////////////////////////////////////////////////////////////////////////
// testbench for module: bangbang_controller
// Author: Jonathan Garcia-Mallen ~ jogama@mit.edu
////////////////////////////////////////////////////////////////////////////////

module bangbang_tb;
   
   // Inputs
   reg reset;
   reg clk;
   reg enable;
   reg sensor_right;
   reg sensor_left;
   reg [5:0] speed;

   // Outputs
   reg signed [7:0] wheel_left;
   reg signed [7:0] wheel_right;

   // INstantiate the Unit Under Test
   bangbang_controller 
     uut (
	  .reset(reset), 
	  .clk(clk), 
	  .enable(enable), 
	  .sensor_right(sensor_right), 
	  .sensor_left(sensor_left), 
	  .speed(speed), 
	  .wheel_left(wheel_left), 
	  .wheel_right(wheel_right));

   initial forever #1  clk = ~clk;
   initial begin
      // for gtkwave simulation. 
      // We pass in the module name into $dumpvars to dump everything under the module.
      $dumpfile("bangbang_tb.vcd");
      $dumpvars(0, bangbang_tb);

      // Initialize Inputs
      clk = 0;
      reset = 1;
      enable = 1;
      sensor_right = 1;
      sensor_left = 1;
      speed = 6'b111111;

      // Wait 100 ns for global reset to finish
      #100;
      
      $display("testing reset");
      reset = 1;
      #10;
      
      $display("testing enable");
      reset = 0;
      enable = 0;
      #10;
      enable = 1;
      #10;

      // iterate through four different speeds and each sensor combinations
      reg [1:0] sensors;
      for(speed = 0; speed < 64; speed = speed + 8) begin
	 for(sensors = 0; sensors < 'b11; sensors = sensors + 1) begin
	    $display("testing sensors at speed = %d", speed);
	    {sensor_left, sensor_right} = sensors;
	    #10;
	 end
      end

      $stop();
      $finish();
   end // initial begin
endmodule // bangbang_tb

