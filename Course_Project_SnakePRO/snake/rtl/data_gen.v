module data_gen
#(
	parameter CNT_MAX = 23'd2499_999, 
	parameter DATA_MAX= 20'D999_999 
)
(
	input wire sys_clk, 
	input wire sys_rst_n, 

	input wire clear_signal, 
	input wire start_signal, 
	output wire [15:0] data, 
	output wire [5:0] point, 
	output reg seg_en, 
	output wire sign 
 );


	reg [22:0] cnt_100ms ; 
	reg cnt_flag ; 
	
	assign point = 6'b010_000;
	assign sign = 1'b0;

	wire start_signal_en;
	assign start_signal_en=start_signal;

	always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
	cnt_100ms <= 23'd0;
	else if(cnt_100ms == CNT_MAX || clear_signal)
	cnt_100ms <= 23'd0;
	else if(start_signal_en==1'b1)
	cnt_100ms <= cnt_100ms + 1'b1;
	else
	cnt_100ms <= cnt_100ms;

	always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
	cnt_flag <= 1'b0;
	else if(cnt_100ms == CNT_MAX - 1'b1 || clear_signal)
	cnt_flag <= 1'b1;
	else
	cnt_flag <= 1'b0;

	reg	[15:0]	data_s;
	reg	[15:0]	data_ms;
	assign	data	=	data_s;

	always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
	data_ms <= 'd0;
	else if(((data_ms == 9) && (cnt_flag == 1'b1)) || clear_signal)
	data_ms <= 'd0;
	else if(cnt_flag == 1'b1)
	data_ms <= data_ms + 1'b1;
	else
	data_ms <= data_ms;

	always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
	data_s <= 'd0;
	else if(clear_signal)
	data_s <= 'd0;
	else if((data_ms == 9) && (cnt_flag == 1'b1) )
	data_s <= data_s + 1'b1;
	else
	data_s <= data_s;

	always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
	seg_en <= 1'b0;
	else
	seg_en <= 1'b1;

endmodule