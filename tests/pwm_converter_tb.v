`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:00:39 12/06/2017
// Design Name:   nexys
// Module Name:   /afs/athena.mit.edu/user/j/o/jogama/6.111/project/ise/tb_nexys/pwm_converter_tb.v
// Project Name:  tb_nexys
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: nexys
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module pwm_converter_tb;

	// Inputs
	reg CLK100MHZ;
	reg [15:0] SW;
	reg BTNC;
	reg BTNU;
	reg BTNL;
	reg BTNR;
	reg BTND;
	reg [7:0] JB;

	// Outputs
	wire [3:0] VGA_R;
	wire [3:0] VGA_B;
	wire [3:0] VGA_G;
	wire [7:0] JA;
	wire VGA_HS;
	wire VGA_VS;
	wire LED16_B;
	wire LED16_G;
	wire LED16_R;
	wire LED17_B;
	wire LED17_G;
	wire LED17_R;
	wire [15:0] LED;
	wire [7:0] SEG;
	wire [7:0] AN;

	// Bidirs
	wire [7:0] JD;

	// Instantiate the Unit Under Test (UUT)
	nexys uut (
		.CLK100MHZ(CLK100MHZ), 
		.SW(SW), 
		.BTNC(BTNC), 
		.BTNU(BTNU), 
		.BTNL(BTNL), 
		.BTNR(BTNR), 
		.BTND(BTND), 
		.JB(JB), 
		.JD(JD), 
		.VGA_R(VGA_R), 
		.VGA_B(VGA_B), 
		.VGA_G(VGA_G), 
		.JA(JA), 
		.VGA_HS(VGA_HS), 
		.VGA_VS(VGA_VS), 
		.LED16_B(LED16_B), 
		.LED16_G(LED16_G), 
		.LED16_R(LED16_R), 
		.LED17_B(LED17_B), 
		.LED17_G(LED17_G), 
		.LED17_R(LED17_R), 
		.LED(LED), 
		.SEG(SEG), 
		.AN(AN)
	);

	initial begin
		// Initialize Inputs
		CLK100MHZ = 0;
		SW = 0;
		BTNC = 0;
		BTNU = 0;
		BTNL = 0;
		BTNR = 0;
		BTND = 0;
		JB = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

