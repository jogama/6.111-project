# from reading lecture 12 slides:
¿ so all regfiles are arrays
  reg [31:0] array[15:0] ?
  ?

* lec12 had example of dualport LUT RAMs. 
  ¿ why not have a single port twice as wide to do this? 
    when would you use dualport RAM? 
  	
* trying to estimate how much memory I'll use: 
  * 16 bits for both wheels sent each clock cycle
  * assume max recording time of 15 seconds
  * 25mhz clock 
  * 6,000,000,000 ~ 6 billion bits. That's six gigabytes, unacceptable. 
  
  * how fast are our sensors? They typically sample @ 390Hz. Let this
    be our sample rate, on the basis that our robot will only change
    its wheel commands as fast as it reacts to its input.
