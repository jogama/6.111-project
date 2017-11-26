`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Create Date:   15:05:40 11/26/2017
// Verilog Test Fixture created by ISE for module: pwm
////////////////////////////////////////////////////////////////////////////////

module pwm_tb;

	// Inputs
	reg reset;
	reg clk;
	reg one_MHz_enable;
	reg [6:0] duty_cycle;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	pwm uut (
		.reset(reset), 
		.clk(clk), 
		.one_MHz_enable(one_MHz_enable), 
		.duty_cycle(duty_cycle), 
		.out(out)
	);

	initial begin
		// Initialize Inputs
		reset = 0;
		clk = 0;
		one_MHz_enable = 0;
		duty_cycle = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

