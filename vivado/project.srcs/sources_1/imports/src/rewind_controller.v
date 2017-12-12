/* 
 The width is 16, and each entry in the memory is {wheel_command_left,
 wh_cmd_r}, where the wheel commands are eight bits each.
 
 The maximum refresh rate for our sensors is 390Hz. This will be the
 motor command sample rate.
 
 We assume a maximum recording time of 15 seconds, so we want 
   log(390 * 15) = 13 rows, roundabout. 
 */

module rewind_controller #(parameter LOGSIZE=13,
			   parameter WIDTH_CMD=4,
			   parameter SAMPLE_RATE=390 // in Hz
			   )
   (input reset, clk, 
    input [1:0] state, 
    input signed [WIDTH_CMD-1:0] wcmd_in_l, wcmd_in_r, // wheel command from memory
    output reg signed [WIDTH_CMD-1:0]  wheel_left, wheel_right);
   
   // STATES 
   parameter IDLE    = 'b10;
   parameter FORWARD = 'b01;
   parameter REWIND  = 'b11;

   // CLOCKING FOR DOWNSAMPLING
   wire clk_sample; // If this doesn't work, use a counter
   divider #(.DIVISION_PERIOD(SAMPLE_RATE))
	     divided_sampling_clk(.clk(clk), .clk_divided(clk_sample));

   // SET UP MEMORY
   parameter WIDTH_MEM = WIDTH_CMD * 2;
   reg [LOGSIZE-1:0] address = 0;
   reg mem_is_full;
   wire [WIDTH_MEM-1:0] mem_in, mem_out;
   mybram #(.LOGSIZE(LOGSIZE), .WIDTH(WIDTH_MEM))
   samples(.addr(address), .clk(clk), .we(state == FORWARD),
	   .din(mem_in), .dout(mem_out));
   assign mem_in  = {wcmd_in_l, wcmd_in_r};
   
   // If we're moving forward, record the wheel commands
   always @ (posedge clk_sample) begin
      if(state == FORWARD && ~mem_is_full) 
	 address <= address + 1;
   end

   always @ (posedge clk) begin
      if(reset) begin
	 address <= 0;
	 wheel_left  <= 0;
	 wheel_right <= 0;
	 // check later how/whether to reset the memory
      end
      else if(~reset) begin
	 if(state == IDLE) begin
	    address <= 0;
	    mem_is_full <= 0;
	 end
	 else if(state == REWIND) begin
	    // reverse the motor commands
	    wheel_left  <= -1 * mem_out[WIDTH_MEM-1:WIDTH_CMD];
	    wheel_right <= -1 * mem_out[WIDTH_CMD-1:0];
	 end

	 // Memory is full once address reaches its maximum
	 if(&address) mem_is_full <= 1;
      end // if (~reset)
   end // always @ (posedge clk)
endmodule

/* 
  Module written by staff for lab5
   Verilog equivalent to a BRAM, tools will infer the right thing!
   number of locations = 1<<LOGSIZE, width in bits = WIDTH.
   default is a 16K x 1 memory.
*/
module mybram #(parameter LOGSIZE=14, WIDTH=1)
              (input wire [LOGSIZE-1:0] addr,
               input wire clk,
               input wire [WIDTH-1:0] din,
               output reg [WIDTH-1:0] dout,
               input wire we);
   // let the tools infer the right number of BRAMs
   (* ram_style = "block" *)
   reg [WIDTH-1:0] mem[(1<<LOGSIZE)-1:0];
   always @(posedge clk) begin
     if (we) mem[addr] <= din;
     dout <= mem[addr];
   end
endmodule // mybram
