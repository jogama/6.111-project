// FILE: divider.v
// AUTH: Jonathan Garcia-Mallen ~ jogama@mit.edu

// The divider converts the 25MHz master clock into an one_hz_enable
// signal that's asserted for just 1 cycle out of every 25,000,000
// cycles (i.e., once per second).

module divider #(parameter DIVISION_PERIOD='d25_000_000) // 25MHz is the master clock frequency
                (input clk,
                 output reg clk_divided);

   // Assumes master clock is no faster than 25Mhz and we don't want to divide more than a second.
   // log2(25*10^6) = 24.6 bits needed to count that high.
   reg [24:0] count = 0; 
   always @ (posedge clk) begin
     if (count < DIVISION_PERIOD) begin
	count <= count + 1;
	clk_divided <= 0;
     end
     else begin
	count <= 0;
	clk_divided <= 1;
     end
   end	
endmodule
