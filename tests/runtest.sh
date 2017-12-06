# remove file extension
NAME=$(echo "$1" | cut -f 1 -d '.') # thanks, stackoverflow
VVP="$NAME.vvp"
VCD="$NAME.vcd"

# assuming we're in directory project/tests
iverilog "$1" \
    ~/6.111/project/vivado/project.srcs/sources_1/imports/src/* \
    -o "VVP/$sim"

xterm -e "vvp sim/$VVP" &
sleep 2
xterm -e "gtkwave $VCD" &

# It would be nice to
#    (a) run vvp in backround 
#    (b) shutdown vvp when gtkwave shuts down
#    (c) exit upon compilation errors
