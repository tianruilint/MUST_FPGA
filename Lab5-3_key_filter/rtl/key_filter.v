module key_filter(
	input sys_clk,
	input sys_rst_n,
	input key_in,

	output reg key_flag
);

	parameter CNT_MAX = 20'd999_999;
	reg [19:0] cnt_20ms;
	
	always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
	cnt_20ms <= 20'b0;
	else if(key_in == 1'b1)
	cnt_20ms <= 20'b0;
	else if(cnt_20ms == CNT_MAX && key_in == 1'b0)
	cnt_20ms <= cnt_20ms;
	else
	cnt_20ms <= cnt_20ms + 1'b1;
	
	always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
	key_flag <= 1'b0;
	else if(cnt_20ms == CNT_MAX - 1'b1)
	key_flag <= 1'b1;
	else
	key_flag <= 1'b0;

endmodule