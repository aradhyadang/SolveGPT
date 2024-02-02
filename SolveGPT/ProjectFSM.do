
# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog ProjectFSM.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver -L lpm_ver ProjectFSM 

#log all signals and add some signals to waveform window
log -r {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}
add wave -position insertpoint sim:/ProjectFSM/C1/*
add wave -position insertpoint sim:/ProjectFSM/D1/*
add wave -position insertpoint sim:/ProjectFSM/C2/*
add wave -position insertpoint sim:/ProjectFSM/D2/*

#first test case
#set input values using the force command, signal names need to be in {} brackets
force Clock 0 0ns, 1 {5ns} -r 10ns
#resetn
force resetn 0
force Go 0
force Choice 1
force DataIn 0
run 10ns

# load A = 2
force resetn 1
force Go 1
force Choice 1
force DataIn 9'd2
run 10ns

force resetn 1
force Go 0
force Choice 1
force DataIn 9'd4
run 10ns

# load B = 10
force resetn 1
force Go 1
force Choice 1
force DataIn 9'd10
run 10ns

force resetn 1
force Go 0
force Choice 1
force DataIn 9'd3
run 10ns

# load C = 3
force resetn 1
force Go 1
force Choice 1
force DataIn 9'd3
run 10ns

force resetn 1
force Go 0
force Choice 1
force DataIn 9'd2
run 10ns

# compute
run 200ns

#first test case
#set input values using the force command, signal names need to be in {} brackets
force Clock 0 0ns, 1 {5ns} -r 10ns
#resetn
force resetn 0
force Go 0
force Choice 0
force DataIn 0
run 10ns

# load A1 = 2
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd2
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd4
run 10ns

# load A2 = 2
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd2
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd3
run 10ns

# load B1 = 1
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd1
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd2
run 10ns

# load B2 = 1
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd2
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd4
run 10ns

# load C1 = 10
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd10
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd3
run 10ns

# load C2 = 5
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd5
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd2
run 10ns

# compute
run 200ns





#first test case
#set input values using the force command, signal names need to be in {} brackets
force Clock 0 0ns, 1 {5ns} -r 10ns
#resetn
force resetn 0
force Go 0
force Choice 1
force DataIn 0
run 10ns

# load A = 1
force resetn 1
force Go 1
force Choice 1
force DataIn 9'd1
run 10ns

force resetn 1
force Go 0
force Choice 1
force DataIn 9'd4
run 10ns

# load B = 4
force resetn 1
force Go 1
force Choice 1
force DataIn 9'd4
run 10ns

force resetn 1
force Go 0
force Choice 1
force DataIn 9'd3
run 10ns

# load C = 3
force resetn 1
force Go 1
force Choice 1
force DataIn 9'd3
run 10ns

force resetn 1
force Go 0
force Choice 1
force DataIn 9'd2
run 10ns

# compute
run 200ns

#Second test case
#set input values using the force command, signal names need to be in {} brackets
force Clock 0 0ns, 1 {5ns} -r 10ns
#resetn
force resetn 0
force Go 0
force Choice 0
force DataIn 0
run 10ns

# load A1 = 2
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd2
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd4
run 10ns

# load A2 = 3
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd3
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd3
run 10ns

# load B1 = 3
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd3
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd2
run 10ns

# load B2 = -3
force resetn 1
force Go 1
force Choice 0
force DataIn 9'b11111101
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd4
run 10ns

# load C1 = 10
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd10
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd3
run 10ns

# load C2 = 15
force resetn 1
force Go 1
force Choice 0
force DataIn 9'd15
run 10ns

force resetn 1
force Go 0
force Choice 0
force DataIn 9'd2
run 10ns

# compute
run 200ns













