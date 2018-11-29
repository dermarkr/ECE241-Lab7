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

force {colour_in} 010
force {data_in} 00001111

force {ld_x} 1
force {ld_y} 0
force {do_draw} 0
force {blank} 0
run 10 ns

force {data_in} 00000101
force {ld_x} 0
force {ld_y} 1
force {do_draw} 0
force {blank} 0
run 10 ns

force {ld_x} 0
force {ld_y} 0
force {do_draw} 1
force {blank} 0
run 170 ns

force {ld_x} 0
force {ld_y} 0
force {do_draw} 0
force {blank} 1
run 160000 ns



