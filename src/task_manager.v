module task_manager #(parameter RECORD_TIME=15, // in seconds
		      parameter LOG_REC_TIME=4, // I don't know a better way
		      parameter WIDTH_CMD=4
		      )
   (input reset, start, clk, oneHz_enable, 
    output reg enable_forward, 
    output reg [1:0] state); // used by rewind_controller
   
   parameter IDLE    = 'b10;
   parameter FORWARD = 'b01;
   parameter REWIND  = 'b11;
   reg [LOG_REC_TIME-1:0] count;

   // oneHz_enable *should* be high for only one clk...
   always @ (posedge oneHz_enable) begin
      // But this always should guard against it being high for longer
      if(state != IDLE)
	count <= count + 1;
   end 
   
   always @ (posedge clk) begin
      if(reset) begin
	 state <= IDLE;
	 count <= 0;
	 enable_forward <= 0;
      end      
      else if(~reset) begin
	 case(state)
	   // Wait for start to go high 
	   IDLE: begin
	      if(start) state <= FORWARD;
	      enable_forward <= 0;
	   end
	   FORWARD: begin
//	      if(oneHz_enable)
//		count <= count + 1; // oneHz_enable *should* be high for only one clk...
	      enable_forward <= 1;

	      // Transition to REWIND
	      if(count == RECORD_TIME) begin
		 count <= 0;
		 state <= REWIND;
	      end
	   end
	   REWIND: begin
//	      if(oneHz_enable)
//		count <= count + 1; // see insecurity above
	      enable_forward <= 0;

	      // Transition to IDLE
	      if(count == RECORD_TIME) begin
		 count <= 0;
		 state <= IDLE;
	      end
	   end // case: REWIND
	   default:
	     state <= IDLE;
	 endcase // case (state)
      end // if (~reset)
   end // always @ (posedge clk)
endmodule // task_manager

