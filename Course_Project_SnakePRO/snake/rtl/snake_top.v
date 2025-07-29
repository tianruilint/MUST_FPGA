module snake_top
(
   input clk,		
	input rst_n,		
	
	input key0_right,  		
	input key1_left, 		
	input key2_down,    			
	input key3_up, 		 	

	output vga_hsync,	
	output vga_vsync,		
	output [15:0]rgb,	
	
	output wire stcp ,
   output wire shcp , 
   output wire ds , 
   output wire oe, 
	output wire LED
);

   wire [23:0]vga_rgb;	
	assign rgb={vga_rgb[23:19],vga_rgb[15:10],vga_rgb[7:3]};
	wire clk_25m;
	wire pll_locked;
	wire [1:0]snake_show;
	
	wire [9:0]pos_x;
	wire [9:0]pos_y;
	
	wire [5:0]apple_x;
	wire [4:0]apple_y;
	
	wire [5:0]head_x;
	wire [5:0]head_y;
	
	wire add_cube;
	
	wire[1:0]game_status;
	
	wire [3:0]body_status;
	wire hit_wall;
	wire hit_body;
	wire snake_display;
	
	wire [11:0]bcd_data;
	wire [7:0]bcd_data2;
	wire [11:0]bcd_data_best;
	wire hit_stone;
	
	wire [2:0]sw;

	assign sw=3'b101;

	reg LED_reg;

	assign LED=LED_reg;
	always@(posedge clk_25m or negedge rst_n) begin
		if(!rst_n) 
		LED_reg<=0;
		else if(hit_wall || hit_stone)
		   LED_reg<=~LED_reg;
		else
			LED_reg<=LED_reg;
	end	
	
    pll pll_inst (
			.areset             (~rst_n),
			.inclk0          (clk),
			.c0        (clk_25m),
			.locked          (pll_locked)
	);

	wire vga_clk;		
	wire vga_blank_n;	
	wire vga_sync_n;	
	
	assign vga_clk = clk_25m;
	assign vga_sync_n=1'b0;  
	
	wire  key0_right_flag;  		
	wire  key1_left_flag;		
	wire  key2_down_flag;   		
	wire  key3_up_flag; 		 		
	parameter CNT_MAX = 20'd499_999;

    key_filter #(
        .CNT_MAX(CNT_MAX)
    ) key_filter_inst1 (
        .sys_clk(clk_25m),
        .sys_rst_n(rst_n),
        .key_in(key0_right),
        .key_flag(key0_right_flag)
    );

    key_filter #(
        .CNT_MAX(CNT_MAX)
    ) key_filter_inst2 (
        .sys_clk(clk_25m),
        .sys_rst_n(rst_n),
        .key_in(key1_left),
        .key_flag(key1_left_flag)
    );


    key_filter #(
        .CNT_MAX(CNT_MAX)
    ) key_filter_inst3 (
        .sys_clk(clk_25m),
        .sys_rst_n(rst_n),
        .key_in(key2_down),
        .key_flag(key2_down_flag)
    );


    key_filter #(
        .CNT_MAX(CNT_MAX)
    ) key_filter_inst4 (
        .sys_clk(clk_25m),
        .sys_rst_n(rst_n),
        .key_in(key3_up),
        .key_flag(key3_up_flag)
    );

	wire [1:0]fact_status;
	wire clear_signal;
	wire start_signal;

    game_ctrl_unit game_ctrl_unit_inst(
       .clk(clk_25m),
	    .rst_n(rst_n),
	    .key0_right(~key0_right_flag),
	    .key1_left(~key1_left_flag),
	    .key2_down(~key2_down_flag),
	    .key3_up(~key3_up_flag),
       .game_status(game_status),
	 	 .snake_display(snake_display),
		 .hit_wall(hit_wall),
	 	 .hit_body(hit_body),
		 .hit_stone(hit_stone),
		 .bcd_data(bcd_data),
		 .fact_status(fact_status),
		 .clear_signal(clear_signal),
		 .start_signal(start_signal)
	);
	apple_generate apple_generate_inst (
		.clk(clk_25m),
		.rst_n(rst_n),
		.apple_x(apple_x),
		.apple_y(apple_y),
		.head_x(head_x),
		.head_y(head_y),
		.fact_status(fact_status),
		.add_cube(add_cube),
		.hit_stone(hit_stone)	
	);
	
	snake snake_inst (
	   .clk(clk_25m),
		.rst_n(rst_n),
		.sw(sw[2:0]),
		.key0_right(key0_right),
		.key1_left(key1_left),
		.key2_down(key2_down),
		.key3_up(key3_up),
		.snake_show(snake_show),
		.pos_x(pos_x),
		.pos_y(pos_y),
		.head_x(head_x),
		.head_y(head_y),
		.add_cube(add_cube),
		.game_status(game_status),
		.hit_body(hit_body),
		.snake_display(snake_display),
		.hit_wall(hit_wall),
		.body_status(body_status),
		.fact_status(fact_status)
	);

	VGA_control VGA_control_inst (
		.clk(clk_25m),
		.rst_n(rst_n),
		.game_status(game_status),
		.snake_show(snake_show),
		.bcd_data(bcd_data),
		.bcd_data_best(bcd_data_best),
		.pos_x(pos_x),
		.pos_y(pos_y),
		.apple_x(apple_x),
		.apple_y(apple_y),
		.vga_rgb(vga_rgb),
      .vga_hs(vga_hsync),
      .vga_blank_n(vga_blank_n),
      .vga_vs(vga_vsync),
	  .body_status(body_status),
	  .fact_status(fact_status)
	);

	score_ctrl score_ctrl_inst(
		.clk(clk_25m),
		.rst_n(rst_n),
		.add_cube(add_cube),
		.game_status(game_status),
		.bcd_data(bcd_data), 
		.bcd_data2(bcd_data2),
		.bcd_data_best(bcd_data_best)
);


	top_seg_595 top_seg_595_inst(
        .sys_clk (clk_25m), 
        .sys_rst_n(rst_n), 
        .bcd_data(bcd_data2), 
        .clear_signal(clear_signal), 
        .start_signal(start_signal),
        .stcp(stcp),
        .shcp(shcp),
        .ds(ds),
        .oe(oe)
);

endmodule

