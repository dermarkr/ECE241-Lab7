# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog main.v

#load simulation using mux as the top level simulation module
vsim datapath

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {clk} 0 0ns, 1 {5ns} -r 10ns

force {resetn} 0
run 10ns

force {resetn} 1
run 10ns

force {colour_in} 100
force {start} 1
run 10 ns

force {start} 0 
force {draw} 1

run 160 ns

force {draw} 1 
force {WAIT} 1

run 10 ns

force {WAIT} 0
force {erase} 1

run 160 ns

force {erase} 0
force {predraw} 1

run 20 ns
