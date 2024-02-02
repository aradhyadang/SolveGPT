# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog sqrt.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver sqrt

#log all signals and add some signals to waveform window
log -r {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#first test case
#set input values using the force command, signal names need to be in {} brackets
#resetn
force radical 8'd255
run 10ns

force radical 8'd200
run 10ns

#compute 
run 100 ns
