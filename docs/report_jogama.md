,* this is the story of my git commits
  * git gave me some peace of mind. While I was fastly coding the day
    of the presentation, I was able to get to a point where
    *something* worked! I committed, and kept going. Turns out that
    the things I did just broke the system. When presentation time
    came, I rolled back to the working commit, and presented what did
    work.
  
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
* git 
  - I didn't use git's features until the very end, was at 4fde46c and
	rolled back to 0f8cb24 to present. It gave me peace of mind, for
	sure, that none of my gains would be lost.
  - It worked as a log book. Decent amount of this report came forom $ git log

# Score distribution
* Technical content - overview/motivation
  - what it was meant to do vs what it actually did
  - tools used: wavefunction generator, git/hg, iverilog+gtkwave, runtest.sh, emacs macros+ISE
* Logical, readable diagrams and timing (if appropriate)
  - original block diagram vs block diagram of what actually happened
* Enough details so the project can be replicated by a fellow student
  - erm... idk what you want from here
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
My presentation utilized the debouncer, synchroniser, forward controller, and pwm converter modules. We had a few system outputs. My robot was able to react to obstacles really close to it. 

## We used two proximity sensors
I soldered them. They were really straightforward. I tied two nexys LEDs to them for sanity checking. 

## Debouncer and Syncronizer
These were from some other lab and written by the staff. Debouncer makes sure a single button press is doesn't look like many, and the synchroniser avoides metatstability for the switches controlling speed. 


## PWM converter
Two modules: pass2pwm and pwm. pass2pwm took 
### module pwm
tried testing with oscilloscope with unclear results. Made a testbench using ISE because i was too lazy to finish tbgen.py. Had issues having multiple clocks in the testbench.
I was doing one thing [INSERT THING], but that didn't work. Turns out that this works though: 
    
    initial forever #1 clk = ~clk;
	initial forever #100 one_MHz_enable = ~one_MHz_enable;
	
yaay testbench! [INSERT PICTURE FROM TESTBENCH]

using the wavefunction generator was pretty cool and pretty crucial. like, I never would have gotten the servos working without the wavefunction generator. At first I thought all my servos were fried because no wave would work. Then I was told that you can't use o-scope probes for wavefunction generators. Turns out the probes have high resistance and would cut signal to servos. I was shown that banana plugs are the one true way to the one true wave. 

### modules pwm\_converter and pass2pwm
idk what happened here. former didn't work, made other one in desperation and it worked? [GO THROUGH CODE AND FIGURE OUT WHAT HAPPENED]. def rushed too much making pwm_converter w/o trying to understand what I was doing. 

### Forward controller
* forward controller: this was going to be sooo pretty with the ability to take arbitrary qtty of sensor inputs, but then I realized it was more important for it to work, so I switched to bangbang
* bangbang controller: did't work before it had states, because of a foolish thing that I right now forget. Then I added states and it worked. idk why sensor imputs had to be reversed. 
* wall controller: erm...
* passthrough controller: nothing was working [WHY? WHEN? WHAT WERE THE FAILURE MODES?] and this was literaly the simplest thing I could build. From this rose the pass2pwm module, which did work at certain speeds. We explain pass2pwm bellow (?)

## Things I implemented but never actually worked. 
coincidentally, everything under this category was implemented within two hours of the actual presentation. These include taskmanager, memory, and rewind controller. 

### module rewind_controller
its so pretty, but so deeply flawed. 
no not really it just has some missing lines, not completely implemented. fucking honesty yuou. mainly based it off of whatever happened in lab five, so here I'm writing you a rehash of what I did in lab five! [BEHOLD THE LINE THAT WAS MISSING]

*but wait, there's more!* I actually used math to determine hw to sample the thing. aren't yo prowd? I is lazy, so I used two clocks to get things going. Here's a picture I just generated to show you how that went. sample_clock and the main clk. 

[BEHOLD THE RESULTS FROM SIMULATION THAT PROBABLY AREN'T GOING  TO MATERIALIZE.]

### module task\_manager
screw you, taskman. idk why, but it didn't work. here's a picture of simulation: 
[SIMULATION PICTURE]
Look at it! it behaved so well in behavioural analysis! but now taskman betrayed me. like, the one\_Hz enable wasn't working for some reason. I hooked it up to the oscilloscope to measure the max voltage, expecting it to eventually become 3.3V. Yes, I know that the waveform would always stay flat. But nothing.

this is especially embarassing as I had already implemented this in lab 4. I don't know what I'd suggest here to future 6.111 students. Reusing lab4 code for timing purposes would have certainly worked, but the interface betwee other modules unecessarily complex as a result. Moreover, we should be capable of making a measely 1Hz enable. That didn't work out tho. 

simulation was interesting. Initially it didn't work, as 1hz enable was high for too long. I then switched to using two clocks, and it was all better. See? I wasn't making two clocks just going about willy nilly! all clocks were made with the divider module. 


## what tools I used and problems not related to verilog found in this porject
bruh. i used tools. 
* git for source control and maintaining logs of what I've done.
* emacs macros / ISE for making testbenches less tedious. 
* iverilog+gtkwave+runtest.sh was a cool thing I had going

Vivado is certainly much nicer than ISE. However, I 
