# Obstacle avoiding mobile vehicle with rewind

###Jonathan Garcia-Mallen (jogama@mit.edu)

The goal is to have a robot go forward and avoid any obstacles in the way. After a certain period of time has passed, the robot will stop. Then a button can be pressed to initiate rewind. When the robot rewinds, it returns to its start pose via the same path it used to reach its end pose. Any turns it makes on the forward trip are done in reverse for the return trip. While rewinding, it performs no obstacle avoidance. To avoid obstacles, three to five [ultrasonic sensors](https://www.adafruit.com/product/3317), or three to five [IR emitters](https://www.adafruit.com/product/387) paired with [IR receivers](https://www.adafruit.com/product/157) can used as rangefinders. The robot itself can be supplied by the student.   
