transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/FPGA/Line_Decoder2_4/Rtl {D:/FPGA/Line_Decoder2_4/Rtl/Line_Decoder2_4.v}

vlog -vlog01compat -work work +incdir+D:/FPGA/Line_Decoder2_4/Quartus_prj/../Sim {D:/FPGA/Line_Decoder2_4/Quartus_prj/../Sim/tb_Line_Decoder2_4.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_Line_Decoder2_4

add wave *
view structure
view signals
run 1 us
