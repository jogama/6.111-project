`timescale 1ns / 100ps
////////////////////////////////////////////////////////////////////////////////
// testbench for module: wall_follow
// Author: Jonathan Garcia-Mallen ~ jogama@mit.edu
////////////////////////////////////////////////////////////////////////////////

module wall_tb;
   
   // Inputs
   reg reset;
   reg clk;
   reg enable;
   reg sensor_right;
   reg sensor_left;
   reg sensor_wall;
   reg [5:0] speed;

   // Outputs
   wire signed [7:0] wheel_left;
   wire signed [7:0] wheel_right;

   // Instantiate the Unit Under Test
   wall_follow 
     uut (
	  .reset(reset), 
	  .clk(clk), 
	  .enable(enable), 
	  .sensor_right(sensor_right), 
	  .sensor_wall(sensor_wall),
	  .sensor_left(sensor_left),
	  .speed(speed), 
	  .wheel_left(wheel_left), 
	  .wheel_right(wheel_right));

   // Variables for testing
   integer 	     count_speed;
   integer 	     count_sense;
   
   initial forever #1  clk = ~clk;
   initial begin
      // for gtkwave simulation. 
      // We pass in the module name into $dumpvars to dump everything under the module.
      $dumpfile("wall_tb.vcd");
      $dumpvars(0, wall_tb);

      // Initialize Inputs
      clk = 0;
      reset = 1;
      enable = 1;
      sensor_right = 1;
      sensor_left = 1;
      sensor_wall = 1;
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
      for(count_speed = 0; count_speed < 56; count_speed = count_speed + 8) begin
	 speed = count_speed;
	 sensor_wall = 0;  #20;
	 sensor_wall = 1;  #20;
      end

      $stop();
      $finish();
   end // initial begin
endmodule // wall_tb


