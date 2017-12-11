module task_manager #(parameter RECORD_TIME=15, // in seconds
		      parameter LOG_REC_TIME=4, // I don't know a better way
		      parameter WIDTH_CMD=4
		      )
   (input reset, start, clk, oneHz_enable, 
    input [WIDTH_CMD-1:0] wheel_cmd_left, wheel_cmd_right,
    output reg enable_forward, enable_rewind);
   
   parameter IDLE    = 'b00;
   parameter FORWARD = 'b01;
   parameter REWIND  = 'b11;
   reg [1:0] 		 state;
   reg [LOG_REC_TIME-1:0] count;
   
   always @ (posedge clk) begin
      if(reset) begin
	 state <= 0;
	 count <= 0;
	 enable_forward <= 0;
	 enable_rewind  <= 0;
      end      
      else if(~reset) begin
	 case(state)
	   // Wait for start to go high 
	   IDLE: begin
	      if(start) state <= FORWARD;
	      enable_forward <= 0;
	      enable_rewind  <= 0;
	   end
	   FORWARD: begin
	      count <= count + oneHz_enable; // oneHz_enable *should* be high for only one clk...
	      enable_forward <= 1;
	      enable_rewind  <= 0;

	      // Transition to REWIND
	      if(count == RECORD_TIME) begin
		 count <= 0;
		 state <= REWIND;
	      end
	   end
	   REWIND: begin
	      count <= count + oneHz_enable; // see insecurity above
	      enable_forward <= 0;
	      enable_rewind  <= 1;

	      // Transition to IDLE
	      if(count == RECORD_TIME) begin
		 count <= 0;
		 state <= IDLE;
	      end
	   end // case: REWIND
	 endcase // case (state)
      end // if (~reset)
   end // always @ (posedge clk)
endmodule // task_manager

