transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/FPGA/Digital_Comparator1/RTL {D:/FPGA/Digital_Comparator1/RTL/Digital_Comparator1.v}

vlog -vlog01compat -work work +incdir+D:/FPGA/Digital_Comparator1/Quartus_prj/../Sim {D:/FPGA/Digital_Comparator1/Quartus_prj/../Sim/tb_Digital_Comparator1.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_Digital_Comparator1

add wave *
view structure
view signals
run 1 us
