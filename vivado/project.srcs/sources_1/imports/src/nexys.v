`timescale 1ns / 1ps

// modified from labkit_lab4.v

module nexys(
	     input 	   CLK100MHZ,
	     input [15:0]  SW, 
	     input 	   BTNC, BTNU, BTNL, BTNR, BTND,
	     input [7:0]   JB,
	     inout [7:0]   JD, // sensors come in, pwm goes out
	     output [3:0]  VGA_R, 
	     output [3:0]  VGA_B, 
	     output [3:0]  VGA_G,
	     output [7:0]  JA, // debugging output
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
   wire reset, oneHz_enable, oneMHz_enable, wheel_signal_left, wheel_signal_right;
   wire [1:0] sensor_input;
   wire [5:0] speed;
   
   // ASSIGN NEXYS INPUTS AND OUTPUTS and debounce them
   assign JD[1:0] = {wheel_signal_left, wheel_signal_right};
   assign JD[3:2] = 2'bZ;
   assign sensor_input = JD[3:2]; // we only have two sensors at the moment. 
   assign speed = SW[15:10];
  
   // HANDLE INPUTS. TODO: synchronize switches
   wire [7:0] wcmd_fwd_r, wcmd_fwd_l; // wheel commands from forward controller, right and left
   wire sensor_left, sensor_right; // We only have two sensors at the moment
   debounce sld(.reset(reset), .clock(clock_25mhz), 
		.noisy(sensor_input[0]), .clean(sensor_left));
   debounce srd(.reset(reset), .clock(clock_25mhz), 
		.noisy(sensor_input[1]), .clean(sensor_right));
   synchronize sr(.clk(clock_25mhz), .in(SW[15]), .out(reset));


   bangbang_controller fc(.reset(reset), .clk(clock_25mhz), .enable(SW[1]),//TODO: task manager
	       .sensor_right(sensor_right), .sensor_left(sensor_left), .speed(speed),
	       .wheel_left(wcmd_fwd_l), .wheel_right(wcmd_fwd_r));
   
   pwm_converter converter_l(.reset(reset), .clk(clock_25mhz),
		   .one_MHz_enable(oneMHz_enable), .wheel_cmd(wcmd_fwd_l),
		   .wheel_signal(wheel_signal_left));
   
   pwm_converter converter_r(.reset(reset), .clk(clock_25mhz),
		   .one_MHz_enable(oneMHz_enable), .wheel_cmd(wcmd_fwd_r),
		   .wheel_signal(wheel_signal_right));   

   // Have the 1MHz enable go high one clock cycle per microsecond
   divider #(.DIVISION_PERIOD('d25)) once_per_microsecond
     // This uses a 25-bit reg when it only needs a 5-bit reg. 
     (.clk(clock_25mhz), .clk_divided(oneMHz_enable));

   // handle outputs
   assign data = {24'hc0ffee, 2'b0, speed};   // display coffeee 
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
