## Jonathan Garcia-Mallen's Project Checkoff Checklist
### Commitment
Robot goes forward for a time determined in seconds by the switches on the Nexys 4. It avoids obstacles in the way using its IR senors and a proporional controller. Once the time period is done, it stops. The forward motion having been recorded in memory, the vehicle then travels in reverse.  


*Modules:*  
* Task manager: Switches between forward/rewind controllers, stores data in memory  
* Forward controller: Obstacle detection and avoidance
* Rewind Controller: Pulls data from memory to drive robot backwards  
* PWM Converter: maps command from controllers to a PWM wave for the servos  

### Goal  
Robot can perform all of the above, as well as follow the solid walls in the lab. 
* Task manager: Switch between the three modes using buttons on the Nexys 4. Switching to wall_follow mode may involve turning the sensor array to face the side of the wall, using a third motor.  
* Wall follow controller. Another proportional controller to maintain a distance from the wall.  
### Strech  
1. Use sound to switch between modes: e.g. 440Hz = forward, 
2. Add camera and follow lines
3. PID control
