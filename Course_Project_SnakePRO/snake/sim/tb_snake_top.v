`timescale 1ns / 1ps

module tb_snake_top();

    reg clk;
    reg rst_n;

    reg key0_right;
    reg key1_left;
    reg key2_down;
    reg key3_up;

    wire vga_hsync;
    wire vga_vsync;
    wire [15:0] rgb;
    wire stcp;
    wire shcp;
    wire ds;
    wire oe;
    wire LED;

    snake_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .key0_right(key0_right),
        .key1_left(key1_left),
        .key2_down(key2_down),
        .key3_up(key3_up),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .rgb(rgb),
        .stcp(stcp),
        .shcp(shcp),
        .ds(ds),
        .oe(oe),
        .LED(LED)
    );
	
	initial
	begin
	clk = 1'b0;
	end
	
	//clk:产生时钟
	always #20 clk <= ~clk;	 
	 
	initial begin
		rst_n = 0;
		#80;
		rst_n = 1;
	
		key0_right = 1;
		key1_left = 1;
		key2_down = 1;
		key3_up = 1;
	
		#60000000
		
		#2000 key0_right = 0;
		#2000 key0_right = 1;
		#100 key0_right = 0;
		#300000 key0_right = 1;
	
		#2000 key1_left = 0;
		#2000 key1_left = 1;
		#100 key1_left = 0;
		#300000 key1_left = 1;
	
		#2000 key2_down = 0;
		#2000 key2_down = 1;
		#100 key2_down = 0;
		#300000 key2_down = 1;
	
		#2000 key3_up = 0;
		#2000 key3_up = 1;
		#100 key3_up = 0;
		#300000 key3_up = 1;
	
	end
	
	initial begin
		$monitor("Time = %0t, vga_hsync = %b, vga_vsync = %b, LED = %b", $time, vga_hsync, vga_vsync, LED);
	end
	
endmodule