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

module forward_controller #(parameter SENSOR_COUNT='d2)
   (input reset, clk, enable,
    input [SENSOR_COUNT:0] speed, // TODO: this is not the correct width. See speed description above. 
    input [SENSOR_COUNT-1:0] sensor_array,
    output reg signed [7:0]  wheel_left, wheel_right);

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
 
 dead simple controller just to get things moving. The primary
 simplification is that it assumes only two sensor inputs, which is
 our current situation. 
 
 NOTE: It may be reasonable to stick with this controller, but smooth
 its output with a PD or PID controller.
  */

module bangbang_controller(input reset, clk, enable, sensor_right, sensor_left,
			   input [5:0] speed, // I just guessed this width
			   output signed [7:0] wheel_left, wheel_right);

   // This is bangbang control. It's on or it's off. 

   // turn sharp left if both sensors are high. 
   // TODO: add state to turn more in same direction when both sensors become high. 
   assign wheel_left  = enable ? sensor_left  * speed * (-(sensor_left&sensor_right)) : 7'sb0;
   assign wheel_right = enable ? sensor_right * speed : 7'sb0;
   
endmodule   
