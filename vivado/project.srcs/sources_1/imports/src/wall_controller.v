module wall_follow #(parameter TURN_DIFF=16, WALL_ON_RIGHT=1)
   (input reset, clk, enable, sensor_left, sensor_right, sensor_wall,
    input [5:0] 	speed, 
    output signed [7:0] wheel_left, wheel_right);

   assign wheel_left  = enable ? wl : 0;
   assign wheel_right = enable ? wr : 0;
   reg signed [7:0] wl, wr;

   // TODO: implement corners
   always @ (posedge clk) begin
      if(~reset) begin
	 if(sensor_wall) begin
	    wr <= WALL_ON_RIGHT ? speed - TURN_DIFF : speed + TURN_DIFF;
	    wl <= WALL_ON_RIGHT ? speed + TURN_DIFF : speed - TURN_DIFF;
	 end else if(~sensor_wall) begin
	    wr <= WALL_ON_RIGHT ? speed + TURN_DIFF : speed - TURN_DIFF;
	    wl <= WALL_ON_RIGHT ? speed - TURN_DIFF : speed + TURN_DIFF;
	 end
      end if(reset) begin
	 wr <= 0;
	 wl <= 0;
      end
   end
endmodule // wall_follow
