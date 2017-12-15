module pass2pwm_tb;

   // Inputs
   reg reset;
   reg clk;
   reg enable;
   reg one_MHz_enable;
   reg [3:0] speed;
   reg signed [3:0] wheel_cmd_left;
   reg signed [3:0] wheel_cmd_right;

   // Outputs
   wire wheel_sig_left, wheel_sig_right;

   pass2pwm uut(.reset(reset),
		.clk(clk),
		.enable(enable),
		.one_MHz_enable(one_MHz_enable),
		.speed(speed),
		.wheel_cmd_left(wheel_cmd_left),
		.wheel_cmd_right(wheel_cmd_right),
		.wheel_sig_left(wheel_sig_left),
		.wheel_sig_right(wheel_sig_right)
		);

   // Variables for simulation
   integer wheel_cmd;
   
   initial forever #1  clk = ~clk;
   initial forever #100 one_MHz_enable = ~one_MHz_enable; // this fine for simulation

   initial begin
      // for gtkwave simulation. 
      // We pass in the module name into $dumpvars to dump everything under the module.
      $dumpfile("pass2pwm_tb.vcd");
      $dumpvars(0, pass2pwm_tb);
      
      // Initialize Inputs
      clk = 0;
      one_MHz_enable = 0;
      reset = 1;
      enable = 0;
      speed = 2; // we'll test everything at this speed
      wheel_cmd_left = 0;
      wheel_cmd_right = 0;

      wheel_cmd = 0;
      
      // Wait 100 ns for global reset to finish
      #100;
      // Add stimuli
      reset = 0;
      enable = 1;
      
      for(wheel_cmd = -8;
	  wheel_cmd < 7;
	  wheel_cmd = wheel_cmd + 1) begin
	 // the robot goes backwards, then forwards. 
	 wheel_cmd_left  = wheel_cmd;
	 wheel_cmd_right = wheel_cmd;
	 $display(wheel_cmd);
	 #3000;
      end
      $display(wheel_cmd); // final increment occurs such that loop exists before displaying 

      // we're done!
      $stop();
      $finish();
   end // initial begin
   
endmodule // pass2pwm_tb
