`timescale 1ns / 1ps

// modified from labkit_lab4.v

module nexys(
	     input 	   CLK100MHZ,
	     input [15:0]  SW, 
	     input 	   BTNC, BTNU, BTNL, BTNR, BTND,
	     output [3:0]  VGA_R, 
	     output [3:0]  VGA_B, 
	     output [3:0]  VGA_G,
	     output [7:0]  JA,
	     output [7:0]  JD,   
	     output 	   VGA_HS, 
	     output 	   VGA_VS, 
	     output 	   LED16_B, LED16_G, LED16_R,
	     output 	   LED17_B, LED17_G, LED17_R,
	     output [15:0] LED,
	     output [7:0]  SEG, // segments A-G (0-6), DP (7)
	     output [7:0 ] AN    // Display 0-7
	     );
   

   // create 25mhz system clock
   wire 		    clock_25mhz;
   clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

   //  instantiate 7-segment display;  
   wire [31:0] 		    data;
   wire [6:0] 		    segments;
   display_8hex display(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));    
   assign SEG[6:0] = segments;
   assign SEG[7] = 1'b1;

   // INSTANTIATE WIRES and REGISTERS
   wire reset, oneHz_enable, oneMHz_enable, wheel_port, wheel_stbd; 

   // ASSIGN NEXYS INPUTS AND OUTPUTS
   assign JA[0] = wheel_port;
   assign JD[0] = wheel_stbd;
   
   // INSTANTIATE MODULES
   pwm test(.reset(reset), .clk(clock_25mhz), .one_MHz_enable(oneMHz_enable),
	    .duty_cycle(SW[6:0]), .out(wheel_port));
   
   // synchronize inputs from switches to avoid metastability. 
   synchronize   sr(.clk(clock_25mhz), .in(SW[15]), .out(reset));

   // Have the 1MHz enable go high one clock cycle per microsecond
   divider #(.DIVISION_PERIOD('d25)) once_per_microsecond
     // This uses a 25-bit reg when it only needs a 5-bit reg. 
     (.clk(clock_25mhz), .clk_divided(oneMHz_enable));

   // handle outputs
   assign data = {32'hc0ffeeee};   // display coffeee 
endmodule // nexys

module clock_quarter_divider(input clk100_mhz, output reg clock_25mhz = 0);
   reg counter = 0;

   // VERY BAD VERILOG
   // VERY BAD VERILOG
   // VERY BAD VERILOG
   // But it's a quick and dirty way to create a 25Mhz clock
   // Please use the IP Clock Wizard under FPGA Features/Clocking
   //
   // For 1 Hz pulse, it's okay to use a counter to create the pulse as in
   // assign onehz = (counter == 100_000_000); 
   // be sure to have the right number of bits.

   always @(posedge clk100_mhz) begin
      counter <= counter + 1;
      if (counter == 0) begin
         clock_25mhz <= ~clock_25mhz;
      end
   end
endmodule
