# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog main.v
vlog ram32x4.v

#load simulation using mux as the top level simulation module
vsim main -L altera_mf_ver  

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {SW[9]} 1
force {SW[8:4]} 00011
force {SW[3:0]} 1010
force {KEY[0]} 0
run 10ns

force {KEY[0]} 1
force {SW[9]} 1
force {SW[8:4]} 00011
force {SW[3:0]} 1010
run 10ns 

force {KEY[0]} 0
run 10ns

force {KEY[0]} 1
force {SW[9]} 0
force {SW[8:4]} 00111
force {SW[3:0]} 1000
run 10ns

force {KEY[0]} 0
run 10ns

force {KEY[0]} 1
force {SW[9]} 0
force {SW[8:4]} 00011
force {SW[3:0]} 0011
run 10ns

force {KEY[0]} 0
run 10ns

force {KEY[0]} 1
force {SW[9]} 1
force {SW[8:4]} 00111
force {SW[3:0]} 1000
run 10ns

force {KEY[0]} 0
run 10ns

force {KEY[0]} 1
force {SW[9]} 0
force {SW[8:4]} 00011
force {SW[3:0]} 0010
run 10ns