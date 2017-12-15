/*  FILE: forward_controller.v
  AUTHOR: jogama@mit.edu */

/* forward_controller: 
inputs: 
 enable: if this is high, it does work. Else, it outputs zeros or X's.
 
 speed: we have N sensors, thus max speed is Y and width is W, taking
   into consideration our current gain scheme. 
 
 sensor_array: takes input from SENSOR_COUNT binary inputs. High is
   expected when a sensor detects an obstacle, low otherwise. MSB of
   sensor_array is the left-most sensor, LSB is right-most sensor, and
   sensor_array[SENSOR_COUNT/2] should be the sensor pointing directly
   to the front of the vehicle.  
 
   Currently, we are using Sharp GP2Y0D810Z0F Digital Distance Sensor
   with 10cm range.
 
 weights: UNIMPLEMENTED. It may be beneficial to have weights sensor
   wieghts as an input.
 
 outputs: 
   wheel_left and wheel_right: fed to task_manager to be relayed to
     servos
 */ 

module forward_controller #(parameter SENSOR_COUNT='d2,
			    parameter WIDTH_SPEED=6, 
			    parameter WIDTH_CMD=8)
   (input reset, clk, enable,
    input [WIDTH_SPEED-1:0]   speed, // TODO: this is not the correct width. See speed description above. 
    input [SENSOR_COUNT-1:0] sensor_array,
    output reg signed [WIDTH_CMD-1:0]  wheel_left, wheel_right);

   parameter SENSOR_MIDDLE = (SENSOR_COUNT >> 1) + SENSOR_COUNT[0];
   reg [SENSOR_MIDDLE:0]     index = 0; // we only need log2(SENSOR_MIDDLE) = width(SENSOR_COUNT) - 1
   reg [7:0] 		     accumulator_wl;
   reg [7:0] 		     accumulator_wr;   
   
   always @ (posedge clk) begin
      if(reset || !enable) begin
	 index       <= 0;
	 wheel_left  <= 0;
	 wheel_right <= 0;
	 accumulator_wl <= 0;
	 accumulator_wr <= 0;
      end
      else if (enable) begin
	 // NOT HANDELING 2-SENSOR CASE
	 if(index < SENSOR_MIDDLE) begin

	    // The weight is (index + 1)
	    accumulator_wr <= accumulator_wr 
			      + sensor_array[index] * (index + 1);
	    accumulator_wl <= accumulator_wl
			      + sensor_array[SENSOR_COUNT-index] * (index + 1);
	    index <= index + 1;
	 end
	 else if(index == SENSOR_MIDDLE) begin
	    // If there's an obstacle directly in front of the robot
	    accumulator_wr <= accumulator_wr - sensor_array[SENSOR_MIDDLE];
	    accumulator_wl <= accumulator_wl - sensor_array[SENSOR_MIDDLE];

	    wheel_left  <= speed * accumulator_wl;
	    wheel_right <= speed * accumulator_wr;
	    index <= 0;
	 end
      end // if (enable)
   end // always @ (posedge clk)
endmodule // forward_controller

/* bangbang controller: 
 
 very simple controller just to get things moving. The primary
 simplification is that it assumes only two sensor inputs, which is
 our current situation. Unlike the simplest of bangbang controllers,
 it uses memory.
 
 NOTE: It may be reasonable to stick with this controller, but smooth
 its output with a PD or PID controller.
  */

module bangbang_controller #(parameter WIDTH_SPEED=6,
			     parameter WIDTH_CMD=8)
   (input reset, clk, enable, sensor_right, sensor_left,
    input [WIDTH_SPEED-1:0] speed, 
    output signed [WIDTH_CMD-1:0] wheel_left, wheel_right);

   parameter LEFT = 'b10;
   parameter RIGHT = 'b01;
   parameter BOTH = 'b11;

   // States encode the sensor that is high
   reg [1:0] state;
   reg [1:0] next_state;
   reg signed [2:0] ctrl_l;
   reg signed [2:0] ctrl_r;   
   
   // to convert positive unsigned to positive signed, just pad with a zero
   wire signed [6:0] speed_signed = {1'b0, speed};
   assign wheel_left  = enable ? ctrl_l * speed_signed : 0;
   assign wheel_right = enable ? ctrl_r * speed_signed : 0;

   always @ (posedge clk) begin
      if(reset) begin
	 state  <= 0;
	 ctrl_l <= 0;
	 ctrl_r <= 0;
	 next_state <= 0;
      end
      else begin
	 next_state <= {~sensor_left, ~sensor_right}; // I don't know why the logic is reversed...
	 if(state != next_state) begin
	    // handle state transitions
	    if(next_state == BOTH) begin
	       if(state == LEFT) begin
		  // hard right
		  ctrl_r <= -1;
		  ctrl_l <=  1;
	       end else if(state == RIGHT) begin
		  // hard left
		  ctrl_r <=  1;
		  ctrl_l <= -1;
	       end else if(state == 0) begin
		  // In the incredibly unlikely event of this transition, hard left. 
		  ctrl_r <=  1;
		  ctrl_l <= -1;
	       end
	    end // if (next_state == BOTH)
	    // all remaining transitions are stateless; the previous case is irrelevant
	    else if(next_state == 0) begin
	       // go forward
	       ctrl_r <= 1;
	       ctrl_l <= 1;
	    end else if(next_state == RIGHT) begin
	       // turn left if right sensor is high
	       ctrl_r <= 1;
	       ctrl_l <= 0;
	    end else if(next_state == LEFT) begin
	       // turn right if left sensor is high
	       ctrl_r <= 0;
	       ctrl_l <= 1;
	    end
	    state <= next_state;
	 end // if (state != next_state)
      end // else: !if(reset)
   end // always @ (posedge clk)
endmodule // bangbang_controller

