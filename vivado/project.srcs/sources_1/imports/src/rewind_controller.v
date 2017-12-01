module rewind_controller(input reset, clk_main, clk_sample, enable,
			 input signed [7:0]   wheel_cmd, // wheel command from memory
			 output [LOGSIZE-1:0] mem_addr,
			 output signed [7:0]  wheel_left, wheel_right);
   

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
