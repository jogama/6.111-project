/*  FILE: forward_controller.v
  AUTHOR: jogama@mit.edu

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
    //speed goes here. idk what width.
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
