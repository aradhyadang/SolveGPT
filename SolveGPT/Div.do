# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog DivCkt.v

#load simulation using mux as the top level simulation module
vsim -L lpm_ver DivCkt

#log all signals and add some signals to waveform window
log -r {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#first test case
#set input values using the force command, signal names need to be in {} brackets
#resetn
force denom 8'd3
force numer 8'd16
run 10ns

force denom 8'd2
force numer 8'd21
run 10ns

#compute 
run 100 ns
