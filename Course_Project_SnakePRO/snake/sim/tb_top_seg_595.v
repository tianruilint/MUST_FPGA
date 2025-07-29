`timescale 1ns/1ns
module tb_top_seg_595();

	wire stcp; 
	wire shcp;
	wire ds;
	wire oe;
	
	reg sys_clk;
	reg sys_rst_n;
	reg [7:0] bcd_data;
	reg clear_signal;
	reg start_signal;
	
	initial
	begin
	sys_clk = 1'b1;
	start_signal = 1'b1;
	clear_signal = 1'b0;
	bcd_data = 8'b0000_0001;
	sys_rst_n <= 1'b0;
	#100
	sys_rst_n <= 1'b1;
	end
	

	always #10 sys_clk <= ~sys_clk;
	

	defparam top_seg_595_inst.seg_595_dynamic_inst.seg_dynamic_inst.
	CNT_MAX=19;
	defparam top_seg_595_inst.data_gen_inst.CNT_MAX = 49;
	

	top_seg_595 top_seg_595_inst
	(
	.sys_clk (sys_clk), 
	.sys_rst_n (sys_rst_n), 
	.bcd_data (bcd_data),
	.clear_signal (clear_signal),
	.start_signal (start_signal),
	
	.stcp (stcp), 
	.shcp (shcp), 
	.ds (ds), 
	.oe (oe) 
	);
	
 endmodule