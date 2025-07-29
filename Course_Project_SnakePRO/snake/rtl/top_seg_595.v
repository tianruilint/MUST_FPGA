module top_seg_595
(
	input wire sys_clk, 
	input wire sys_rst_n, 
	input [7:0] bcd_data, 
	input wire clear_signal,
	input wire start_signal,
	
	output wire stcp, 
	output wire shcp, 
	output wire ds, 
	output wire oe 
);

	wire [15:0] data ;
	wire [5:0] point ; 
	wire seg_en ; 
	wire sign ;

	data_gen data_gen_inst
	(
	.sys_clk (sys_clk),
	.sys_rst_n (sys_rst_n), 
	.clear_signal (clear_signal), 
	.start_signal ( start_signal), 
	.data (data), 
	.point (point), 
	.seg_en (seg_en), 
	.sign (sign) 
);
	
	seg_595_dynamic seg_595_dynamic_inst
	(
	.sys_clk (sys_clk ), 
	.sys_rst_n (sys_rst_n ),
	.data (data ),
	.bcd_data(bcd_data),
	.point (point ),
	.seg_en (seg_en ),
	.sign (sign ),
	
	.stcp (stcp ),
	.shcp (shcp ), 
	.ds (ds ), 
	.oe (oe ) 
);

endmodule