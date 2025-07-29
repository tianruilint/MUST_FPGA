transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/FPGA/Lab5/VGA_ROM/quarts_prj/ip_core/clk_gen {D:/FPGA/Lab5/VGA_ROM/quarts_prj/ip_core/clk_gen/clk_gen.v}
vlog -vlog01compat -work work +incdir+D:/FPGA/Lab5/VGA_ROM/quarts_prj/ip_core/rom_pic {D:/FPGA/Lab5/VGA_ROM/quarts_prj/ip_core/rom_pic/rom_pic.v}
vlog -vlog01compat -work work +incdir+D:/FPGA/Lab5/VGA_ROM/rtl {D:/FPGA/Lab5/VGA_ROM/rtl/vga_rom_pic.v}
vlog -vlog01compat -work work +incdir+D:/FPGA/Lab5/VGA_ROM/rtl {D:/FPGA/Lab5/VGA_ROM/rtl/vga_pic.v}
vlog -vlog01compat -work work +incdir+D:/FPGA/Lab5/VGA_ROM/rtl {D:/FPGA/Lab5/VGA_ROM/rtl/vga_ctrl.v}
vlog -vlog01compat -work work +incdir+D:/FPGA/Lab5/VGA_ROM/quarts_prj/db {D:/FPGA/Lab5/VGA_ROM/quarts_prj/db/clk_gen_altpll.v}

vlog -vlog01compat -work work +incdir+D:/FPGA/Lab5/VGA_ROM/quarts_prj/../sim {D:/FPGA/Lab5/VGA_ROM/quarts_prj/../sim/tb_vga_rom_pic.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_vga_rom_pic

add wave *
view structure
view signals
run 10 ms
