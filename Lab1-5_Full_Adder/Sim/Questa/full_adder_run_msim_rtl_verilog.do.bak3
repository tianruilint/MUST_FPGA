transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/FPGA/Full_Adder/Rtl {D:/FPGA/Full_Adder/Rtl/half_adder.v}
vlog -vlog01compat -work work +incdir+D:/FPGA/Full_Adder/Rtl {D:/FPGA/Full_Adder/Rtl/full_adder.v}

vlog -vlog01compat -work work +incdir+D:/FPGA/Full_Adder/Quartus_prj/../Sim {D:/FPGA/Full_Adder/Quartus_prj/../Sim/tb_full_adder.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_full_adder

add wave *
view structure
view signals
run 1 us
