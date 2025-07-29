transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/FPGA/Lab5/Key_filter/rtl {D:/FPGA/Lab5/Key_filter/rtl/key_filter.v}

vlog -vlog01compat -work work +incdir+D:/FPGA/Lab5/Key_filter/quartus_prj/../sim {D:/FPGA/Lab5/Key_filter/quartus_prj/../sim/tb_key_filter.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_key_filter

add wave *
view structure
view signals
run 1 ms
