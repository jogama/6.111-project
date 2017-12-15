* have a workflow section. You made many testbenches during your nexys-less days. Elaborate on gtkwave, emacs macros vs ISE for tedious testbenchmaking

* I think this would be better done in chronological order, with a tools used section at the end. 




# what was the robot meant to do?
* avoid obstacles for set time t
* stop after time t
* do the reverse after time t
* wall follow

# what can the robot do
it can react to things directly in front of it

# development style

# Score distribution
* Logical, readable diagrams and timing (if appropriate)
  - original block diagram vs block diagram of what actually happened
* Discussion on tricky circuits/challenges/measurments of interesting signals (if appropriate)
  - one interesting signal is a glitch that I ignored 
* Lessons learned, advice for the future projects


# Files to include: *.v, *.xdc, CAD as one zip


# Introduction
I was going to make a robot that could do rewind and imlement these modules 
  [INCLUDE block\_diagram.odg]
However, I only implemented these
  [INCLUDE block\_diagram_final.odg]
And only used these for the actual presentation  
  [INCLUDE block\_diagram\_presentation.odg]
First we'll talk about how I implemented what I presented. Then I'll talk about how I implemented what I didn't present and their issues. Finally I'll talk about what tools I used and problems not related to verilog found in this porject. 

# The modules and inputs outputs in use for the presentation, and how they were developed. 
My presentation utilized the debouncer, synchroniser, forward controller, and pwm converter modules. We had a few system outputs. My robot was able to react to obstacles really close to it. Wherever possible, I used modules made by the staff and reused my own code from previous labs. 

## We used two proximity sensors
They were Sharp GP2Y0D810Z0F Digital Distance Sensor with Pololu Carrier's. 

I soldered them to included pins and stuck them onto a breadboard [INSERT THE VERY LAST PICTURE YOU TOOK OF THE ROBOT]. They were really straightforward, for the most part. They went high if they detected an object within 10cm, and were low otherwise. I tied two nexys LEDs to them for sanity checking. A third was intended for wall following, but not used.

## Debouncer and Syncronizer
These were both from lab4.  and written by the staff. Debouncer makes sure a single button press is doesn't look like many, and the synchroniser avoides metatstability for the switches controlling speed. 



## PWM converter
Two modules: pass2pwm and pwm. pass2pwm took 
### module pwm and the servos used
tried testing with oscilloscope with unclear results. Made a testbench using ISE because i was too lazy to finish tbgen.py. Had issues having multiple clocks in the testbench.
I was doing one thing [INSERT THING], but that didn't work. Turns out that this works though: 
    
    initial forever #1 clk = ~clk;
	initial forever #100 one_MHz_enable = ~one_MHz_enable;
	
yaay testbench! [INSERT PICTURE FROM TESTBENCH]

using the wavefunction generator was pretty cool and pretty crucial. like, I never would have gotten the servos working without the wavefunction generator. At first I thought all my servos were fried because no wave would work. Then I was told that you can't use o-scope probes for wavefunction generators. Turns out the probes have high resistance and would cut signal to servos. I was shown that banana plugs are the one true way to the one true wave. 

The servos dealt were SM_S4303R, I ran them with a 440Hz PWM, and found their zero to be around 60% duty cycle.  They're pretty common servos, as Course 2's seem to leave them like footprints. But documentation is very sparse, and it would have been nice to spend more time finding their true zero. 

Working with pwm's and the motors was fun, but I definitely lost much time here thinking my servos were bad when I was just using the wrong probes. I also should have spent more time testing the pwm module directly with the modules / written the passthrough controllers at this point rather than when things started breaking down. I guess that's also the same way I should be taking monte-carlo localization as well, starting with simpler baysian localization. 

### modules pwm\_converter and pass2pwm
idk what happened here. former didn't work, made other one in desperation and it worked? [GO THROUGH CODE AND FIGURE OUT WHAT HAPPENED]. def rushed too much making pwm_converter w/o trying to understand what I was doing. 
* dealing with signed bits in verilog definitely screwed me over. It was hard to cleanly do math between signed and unsigned wires. I eventually did so, but hard, it was. 

pwm\_converter tried to convert between wheel commands [WHAT'S A WHEEL COMMAND?] plus motor zero, and the duty cycle for the pwm wave. I thought to perform the operation (duty\_cycle = wheel_cmd*(50/127)+60). This was overcomplicated.

pass2pwm had more success by reducing the width of speed and wcmd such that their product would never not overflow in the duty cycle. Signage was succesfully used here to clearly flip one of the motors. 

There were still issues. [SEE HERE] One of them worked in simulation. However, irl, the wheel's speed variation was either maximum or off. idk why this was so.

both modules, upon calulating the duty cycle, passed it to the pwm module. 

Moral of this story: don't make a module you don't understand, only to hope that it'll work later.

### Forward controller

* forward controller: this was going to be sooo pretty with the ability to take arbitrary qtty of sensor inputs. Look at the equation I made!: But then I realized it was more important for it to work, so I switched to bangbang
* bangbang controller: did't work before it had states, because of a foolish thing that I right now forget. Then I added states and it worked. idk why sensor imputs had to be reversed. 
* wall controller: erm...
* passthrough controller: nothing was working [WHY? WHEN? WHAT WERE THE FAILURE MODES?] and this was literaly the simplest thing I could build. From this rose the pass2pwm module, which did work at certain speeds. We explain pass2pwm bellow (?)

Moral of this story: start always with the simplest controller. 

## Things I implemented but never actually worked. 
coincidentally, everything under this category was implemented within two hours of the actual presentation. These include taskmanager, memory, and rewind controller. 

### module rewind_controller
We used the mybram module from lab5, and used lab5 as a refresher for how to use memories. Left and right wheel commands were concatenated and stored in one address. 

The maximum refresh rate for the sensors is 390 Hz. Using the lab4 clock divider, we made a 390Hz sampling clock. On its positive edge, we went to a different address in memory. It's that simple. 

To reverse the wheel commands, simply multiply by negative one. This is another one of the situations where signed wheel commands simplfied code. 

It relied on state from the task manger. This made it easier internally to know when to set the address to zero, when to record, and when to play back. We did not test this module because we were stuck testing the task manager. A nice way to test it would be to generate a dataset of monotonically increasing wheel commands. This module should then produce monotonically decreasing wheel commands. 

### module task\_manager
This is a simple 3-state state machine. It sent its state to the rewind controller and sent enables to other controllers. 

[SIMULATION PICTURE]
Look at it! it behaved so well in behavioural analysis! but now taskman betrayed me. like, the one\_Hz enable wasn't working for some reason. I hooked it up to the oscilloscope to measure the max voltage, expecting it to eventually become 3.3V. Yes, I know that the waveform would always stay flat. But nothing.

this is especially embarassing as I had already implemented this in lab 4. I don't know what I'd suggest here to future 6.111 students. Reusing lab4 code for timing purposes would have certainly worked, but the interface betwee other modules unecessarily complex as a result. Moreover, we should be capable of making a measely 1Hz enable. That didn't work out tho. 
n
simulation was interesting. Initially it didn't work, as 1hz enable was high for too long. I then switched to using two clocks, and it was all better. See? I wasn't making two clocks just going about willy nilly! all clocks were made with the divider module. 

To continue debuggint it, I'd take the antitheft_fsm module from lab4 and start stripping it down. I was at a loss for how to deal with this one. 

## what tools I used and problems not related to verilog found in this porject
bruh. i used tools. 
* emacs macros / ISE for making testbenches less tedious. 
* iverilog+gtkwave+runtest.sh was a cool thing I had going

  * git gave me some peace of mind. While I was fastly coding the day
    of the presentation, I was able to get to a point where
    *something* worked! I committed, and kept going. Turns out that
    the things I did just broke the system. When presentation time
    came, I rolled back to the working commit, and presented what did
    work.
  - I didn't use git's features until the very end, was at 4fde46c and
	rolled back to 0f8cb24 to present. It gave me peace of mind, for
	sure, that none of my gains would be lost.
  - It worked as a log book. Decent amount of this report came forom $ git log

Once I had written a testbench I wanted to run it as quickly as possible whenever I modified the corresponding module. For other labs, I would use ISE. For this one, I would use GTKWave. This is an open source visualization tool that can be used with verilog dumpfiles. It exists for windows, linux, and mac, [I THINK?]. It's a bit quirky, but it works pretty well, and outside of lab. 

Still, Ie found it quite slow to run the sequence of commands necessary to run a simulation, so I wrote the script runtest.sh, located under the tests directory. It's pretty nice. All I had to do was run 

    $ ./runtest.sh foo_tb.v
	
And I'd get my visualization. 

As for making the testbenches, I initially would open ISE and have it autogenerate them for me. I eventually tired of this, and used emacs macros to speed up writing the testbenches by hand. While vivado is certainly nice, I already use emacs for everything as it is and typed all my *.v there. 


