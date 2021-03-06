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
   
   parameter WIDTH_SPEED  = 4;
   parameter WIDTH_WH_CMD = 4; // note that WHeel CoMmanD wires are signed. 
    
   // create 25mhz system clock
   wire clock_25mhz;
   clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

   //  instantiate 7-segment display;  
   wire [31:0] 		    data;
   wire [6:0] 		    segments;
   display_8hex display(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));    
   assign SEG[6:0] = segments;
   assign SEG[7] = 1'b1;

   // INSTANTIATE WIRES and REGISTERS
   wire reset, oneHz_enable, oneMHz_enable, enable_fwd, enable_rwd, 
	wheel_signal_left, wheel_signal_right;
   wire [1:0] sensor_input;
   wire [WIDTH_SPEED-1:0] speed; // duty cycle ∈ [0,127], and 0 rotation is at 60%. speed=31 is thus max.
   wire [3:0] enables;
   wire [1:0]  task_man_state;
   
    
   // ASSIGN NEXYS INPUTS AND OUTPUTS and debounce them
   assign JD[1:0] = {wheel_signal_left, wheel_signal_right};
   assign JD[3:2] = 2'bZ;
   assign sensor_input = JD[3:2]; // we only have two sensors at the moment. 
   assign speed = SW[WIDTH_SPEED-1:0];
   assign enables = SW[14:11];  // from MSB to LSB: bangbang, wall, passthrough, pass2pwm
  
   // HANDLE INPUTS. TODO: synchronize switches
   // wheel commands from controllers, right and left
   wire signed [WIDTH_WH_CMD-1:0] wcmd_fwd_r, wcmd_fwd_l, 
	wcmd_wf_r, wcmd_wf_l, wcmd_pt_r, wcmd_pt_l, wcmd_rwd_l, wcmd_rwd_r;
   wire sensor_left, sensor_right, sensor_wall, start; // We only have two sensors at the moment
   debounce srd(.reset(reset), .clock(clock_25mhz), 
		.noisy(sensor_input[0]||BTNR), .clean(sensor_right));
   debounce sld(.reset(reset), .clock(clock_25mhz), 
		.noisy(sensor_input[1]||BTNL), .clean(sensor_left));
   debounce swd(.reset(reset), .clock(clock_25mhz), 
		.noisy(BTNU), .clean(sensor_wall));
   debounce bstart(.reset(reset), .clock(clock_25mhz), 
		   .noisy(BTNC), .clean(start));
   
   synchronize sr(.clk(clock_25mhz), .in(SW[15]), .out(reset));


   // CONTROLLLERS
   rewind_controller rc(.reset(reset), .clk(clock_25mhz), 
			.state(task_man_state),
			.wcmd_in_l(wcmd_sum_l), .wcmd_in_r(wcmd_sum_r),
			.wheel_left(wcmd_rwd_l), .wheel_right(wcmd_rwd_r));
   
   bangbang_controller #(.WIDTH_SPEED(WIDTH_SPEED), .WIDTH_CMD(WIDTH_WH_CMD))
   fc(.reset(reset), .clk(clock_25mhz), .enable(enable_fwd),
      .sensor_right(sensor_right), .sensor_left(sensor_left), .speed(speed),
      .wheel_left(wcmd_fwd_l), .wheel_right(wcmd_fwd_r));

   // PWM and TASK MANAGER 
   wire [WIDTH_WH_CMD-1:0] wcmd_sum_l = wcmd_wf_l + wcmd_fwd_l + wcmd_pt_l + wcmd_rwd_l;
   wire [WIDTH_WH_CMD-1:0] wcmd_sum_r = wcmd_wf_r + wcmd_fwd_r + wcmd_pt_r + wcmd_rwd_r;
   pass2pwm p2p(.reset(reset), .clk(clock_25mhz), .enable(enables[0]), 
		.one_MHz_enable(oneMHz_enable), .speed(speed),
		.wheel_cmd_left(wcmd_sum_l), .wheel_cmd_right(wcmd_sum_r),
		.wheel_sig_left(wheel_signal_left), 
		.wheel_sig_right(wheel_signal_right));

   task_manager tman(.reset(reset), .start(start), .oneHz_enable(oneHz_enable),
		     .enable_forward(enable_fwd), .state(task_man_state));
   
   // DIVIDERS
   // Have the 1MHz enable go high one clock cycle per microsecond
   divider #(.DIVISION_PERIOD('d25)) once_per_microsecond
     // This uses a 25-bit reg when it only needs a 5-bit reg. 
     (.clk(clock_25mhz), .clk_divided(oneMHz_enable));

   divider #(.DIVISION_PERIOD('d25_000_000)) once_per_second
     (.clk(clock_25mhz), .clk_divided(oneHz_enable));

   // handle outputs to LEDs
   assign data = //{wcmd_sum_l, wcmd_sum_r, // display the sum of the wheel commands
//     wcmd_fwd_l, wcmd_fwd_r,  // wheel commands for obstacle for bangbang controller
  //   wcmd_wf_l,  wcmd_wf_r, 6'b0, task_man_state, 3'h0, speed};   // wcmd for wall following + speed
   {32'h0, 2'b0, task_man_state};
   
   assign LED16_G = sensor_left;
   assign LED17_G = sensor_right;
   assign LED[15] = {16{sensor_wall}};
   assign LED[1:0] = task_man_state; // having issues outputing to the segment display
   assign JA[0] = oneHz_enable;
   assign JA[1] = oneMHz_enable;
   
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
