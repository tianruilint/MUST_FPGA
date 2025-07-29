module  hc595_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire    [5:0]   sel         ,
    input   wire    [7:0]   seg         ,
    
    output  reg             stcp        ,
    output  reg             shcp        ,
    output  reg             ds          ,
    output  wire            oe       
);

	reg     [1:0]   cnt_4   ;  
	reg     [3:0]   cnt_bit ;  
	
	wire    [13:0]  data    ;  
	
	assign  data = {seg[0],seg[1],seg[2],seg[3],seg[4],seg[5],seg[6],seg[7],sel};
	
	assign oe = ~sys_rst_n;
	
	always@(posedge sys_clk or  negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			cnt_4 <=  2'd0;
		else    if(cnt_4 == 2'd3)
			cnt_4 <=  2'd0;
		else
			cnt_4 <=  cnt_4 +   1'b1;
	
	always@(posedge sys_clk or  negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			cnt_bit   <=  4'd0;
		else    if(cnt_4 == 2'd3 && cnt_bit == 4'd13)
			cnt_bit   <=  4'd0;
		else    if(cnt_4  ==  2'd3)
			cnt_bit   <=  cnt_bit   +   1'b1;
		else
			cnt_bit   <=  cnt_bit;
	
	always@(posedge sys_clk or  negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			stcp    <=  1'b0;
		else    if(cnt_bit == 4'd13 && cnt_4 == 2'd3)
			stcp    <=  1'b1;
		else
			stcp    <=  1'b0;
	
	always@(posedge sys_clk or  negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			shcp    <=  1'b0;
		else    if(cnt_4 >= 4'd2)
			shcp    <=  1'b1;
		else
			shcp    <=  1'b0;
	
	always@(posedge sys_clk or  negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			ds  <=  1'b0;
		else    if(cnt_4 == 2'd0)
			ds  <=  data[cnt_bit];
		else
			ds  <=  ds;
	
endmodule