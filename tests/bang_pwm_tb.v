`timescale 1ns / 100ps
////////////////////////////////////////////////////////////////////////////////
// testbench for modules: bangbang_controller, pwm_converter
// Author: Jonathan Garcia-Mallen ~ jogama@mit.edu
//
// Here we test test the intergration between modules bangbang_controller,
//   pwm_controller, and pwm. 
////////////////////////////////////////////////////////////////////////////////

module bang_pwm_tb;
   
   // Inputs for bangbang_controller
   reg reset;
   reg clk;
   reg enable;
   reg sensor_right;
   reg sensor_left;
   reg [5:0] speed;

   // Inputs for pwm_converter
   reg one_MHz_enable;
   
   // Outputs for bangbang wired as
   // Inputs for pwm_converter
   wire signed [7:0] wheel_cmd_left;
   wire signed [7:0] wheel_cmd_right;

   // Outputs for pwm_converter
   wire wheel_signal_left;
   wire wheel_signal_right;
   
   // Instantiate the Unit Under Tests
   bangbang_controller 
     uut_bang (
	  .reset(reset), 
	  .clk(clk), 
	  .enable(enable), 
	  .sensor_right(sensor_right), 
	  .sensor_left(sensor_left), 
	  .speed(speed), 
	  .wheel_left(wheel_cmd_left), 
	  .wheel_right(wheel_cmd_right));

   pwm_converter #(.FLIPPED(1'b1), .ZERO(7'd60), .PERIOD('d100), .ONE_PCT_PERIOD('d1)) 
   uut_pwm_left (
	.reset(reset), 
	.clk(clk), 
	.one_MHz_enable(one_MHz_enable),
	.wheel_cmd(wheel_cmd_left),
	.wheel_signal(wheel_signal_left));

   pwm_converter #(.FLIPPED(0'b1), .ZERO(7'd60), .PERIOD('d100), .ONE_PCT_PERIOD('d1))  
   uut_pwm_right (
	       .reset(reset), 
	       .clk(clk), 
	       .one_MHz_enable(one_MHz_enable),
	       .wheel_cmd(wheel_cmd_right),
	       .wheel_signal(wheel_signal_right));
   
   // Variables for testing
   integer count_speed;
   integer count_sense;
   
   initial forever #1  clk = ~clk;
   initial forever #100 one_MHz_enable = ~one_MHz_enable; // this fine for simulation   
   initial begin
      // for gtkwave simulation. 
      // We pass in the module name into $dumpvars to dump everything under the module.
      $dumpfile("bang_pwm_tb.vcd");
      $dumpvars(0, bang_pwm_tb);

      // Initialize Inputs
      clk = 0;
      reset = 1;
      enable = 1;
      sensor_right = 1;
      sensor_left = 1;
      speed = 6'b111111;
      one_MHz_enable = 0;
      
      // Wait 100 ns for global reset to finish
      #100;
      
      $display("testing reset");
      reset = 1;
      #100;
      
      $display("testing enable");
      reset = 0;
      enable = 0;
      #100;
      enable = 1;
      #100;

      // iterate through four different speeds and each sensor combinations
      for(count_speed = 0; count_speed < 56; count_speed = count_speed + 8) begin
	 $display("testing sensors at speed = %d", speed);	 
	 speed = count_speed;

	 // First four states
      	 for(count_sense = 0; count_sense <= 'b11; count_sense = count_sense + 1) begin
	    {sensor_left, sensor_right} = count_sense[1:0];
	    #3000;
	 end

	 // Then a fifth that the loop doesn't get to
	 {sensor_left, sensor_right} = 2'b01;
	 #3000;
	 {sensor_left, sensor_right} = 2'b11;
	 #3000;

	 // There's a sixth state, but that's the same as one of the above states
      end

      $stop();
      $finish();
   end // initial begin
endmodule // bangbang_tb
