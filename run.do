vlib work

# interface first, with coverage
vlog -cover bcesft FIFO_if.sv

# TB and everything else: no coverage instrumentation
# (FIFO.sv must NOT be in src_files.list)
vlog -f src_files.list +define+SIM

# DUT: code coverage only needs bcesft (keep +define+SIM so the assertions compile)
vlog -cover bcesft FIFO.sv

vsim -voptargs=+acc work.FIFO_top -coverage -assertdebug
run 0
add wave /FIFO_top/f_if/*
coverage save -onexit -assert -directive -cvg -codeAll FIFO_top.ucdb
run -all
quit -sim

vcover report FIFO_top.ucdb -details -annotate -all -output code_cvr.txt
