# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog main.v

#load simulation using mux as the top level simulation module
vsim main

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns

force {KEY[0]} 0
run 10ns

force {KEY[0]} 1
run 10ns


force {SW[7]} 1
force {SW[8]} 1
force {SW[9]} 1


run 1000ns