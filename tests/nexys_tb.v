`timescale 1ns / 100ps
////////////////////////////////////////////////////////////////////////////////
// Create Date:   17:58:02 12/04/2017
// Verilog Test Fixture created by ISE for module: nexys
// Author: Jonathan Garcia-Mallen ~ jogama@mit.edu
////////////////////////////////////////////////////////////////////////////////

module nexys_tb;

   // Inputs
   reg CLK100MHZ;
   reg [15:0] SW;
   reg 	      BTNC;
   reg 	      BTNU;
   reg 	      BTNL;
   reg 	      BTNR;
   reg 	      BTND;
   reg [7:0]  JB;

   // Outputs
   wire [3:0] VGA_R;
   wire [3:0] VGA_B;
   wire [3:0] VGA_G;
   wire [7:0] JA;
   wire       VGA_HS;
   wire       VGA_VS;
   wire       LED16_B;
   wire       LED16_G;
   wire       LED16_R;
   wire       LED17_B;
   wire       LED17_G;
   wire       LED17_R;
   wire [15:0] LED;
   wire [7:0]  SEG;
   wire [7:0]  AN;

   // Bidirs
   wire [7:0]  JD;

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
   // Set input and output wires/registers
   parameter SENSOR_COUNT = 2;
   wire wheel_signal_l, wheel_signal_r;
   reg [1:0] sensors; // MSB is leftmost sensor
   reg [5:0] speed;

   assign wheel_signal_l = JD[0];
   assign wheel_signal_r = JD[1];

   // Set registers for simulation
   integer count;
   
   // Set clock with 2ns period
   initial forever #1  CLK100MHZ = ~CLK100MHZ;
   
   initial begin
      // for gtkwave simulation
      $dumpfile("nexys_tb.vcd");
      $dumpvars(0, nexys_tb);
      
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

      $display("Testing speed"); // Speed width is 6 throughout, at the moment."
      sensors = 0; // All sensors detect nothing, so both wheels should move 
      for(count = 0; count < 64; count = count + 4) begin
	 // We should see the duty cycle for one wheel increase as the other decreases,
	 // as one wheel is flipped. 
	 speed = count;
	 #3000;
      end

      $display("Testing sensors at constant speed = 32");
      speed = 32;
      count = 0;
      for(count = 0; count < SENSOR_COUNT; count = count + 1) begin
	 sensors = count;
	 #10;
      end
      
      $stop();
      $finish();
   end
endmodule

