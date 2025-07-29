module VGA_control
(
	input clk,
	input rst_n,
	
	input [1:0]snake_show,
	input [1:0]game_status,
	input [11:0]bcd_data,
	input [11:0]bcd_data_best,
	input [5:0]apple_x,
	input [4:0]apple_y,
	input [1:0]fact_status,
	
	output [9:0]pos_x,
	output [9:0]pos_y,
	
	input  [3:0]body_status,
	output reg vga_hs,
	output reg vga_vs,
	output reg[23:0] vga_rgb,
	output vga_blank_n
);
	
	localparam RESTART = 2'b00;		
	localparam START = 2'b01;			
	localparam PLAY = 2'b10;			
	localparam DIE = 2'b11;				

	localparam NONE = 2'b00;
	localparam HEAD = 2'b01;
	localparam BODY = 2'b10;
	localparam WALL = 2'b11;
	
    localparam	RED = 24'hFE0000; 
    localparam	GREEN = 24'h50C878;
    localparam	BLUE = 24'h7FFFD4;
	localparam	YELLOW = 24'hCCCC4D;
    localparam	PINK = 24'hB85798;
	localparam	WHITE = 24'hFFFFFF;
	localparam	BLACK = 24'h000000;
	localparam  ICEYELLOW = 24'hafeeee;
	localparam	Salmon = 24'hE6CFE6; 
	localparam	Seashell = 24'h6633CC; 
	localparam	Seashell2 =  24'hDC143C;	
	localparam	Seashell3 =  24'hff9900;

    parameter            HS_A    =    96;       
    parameter            HS_B    =    48;       
    parameter            HS_C    =    640;      
    parameter            HS_D    =    16;       
    parameter            HS_E    =    800;      

    parameter            VS_A    =    2;        
    parameter            VS_B    =    33;       
    parameter            VS_C    =    480;      
    parameter            VS_D    =    10;        
    parameter            VS_E    =    525;       
    
    parameter            HS_WIDTH =   10;        
    parameter            VS_WIDTH =   10;        
	 
    localparam           SIDE_W = 11'd16; 			
    localparam           BLOCK_W = 11'd16;			
	 
	 parameter				 height = 93; 					
	 parameter				 width  = 125; 				
	 
	 parameter				 CHAR_W  =   160; 
	 parameter				 CHAR_H  =   32; 
	
	 reg        [HS_WIDTH - 1:0]        cnt_hs;   
    reg        [VS_WIDTH - 1:0]        cnt_vs;    

     reg			[27:0]						cnt;
	  reg			[28:0]						cnt_clk;
	 reg	  		[13:0]   					cnt_rom_address; 

	 reg			[11:0]						addr_h;
	 reg			[11:0]						addr_v;
		 
    wire       en_hs;          
    wire       en_vs;           
    wire       en;              
   
	 wire   		flag_clear_rom_address;
	 wire   		flag_clear_word_address;
	 wire   		flag_begin_h;			 
	 wire   		flag_begin_v;			
	 wire   		picture_flag_enable;		 
	 
	 wire		[23:0]		rom_data; 
	 wire		word_data;
	 
	 
	 
	 
	 wire    [9:0]   char_x  ;  
	 wire    [9:0]   char_y  ;  
	 reg     [159:0] char          [31:0]  ;  
	 
	 wire    [9:0]   char_x1  ;  
	 wire    [9:0]   char_y1  ;  
	 reg     [159:0] char_layer1   [31:0]  ;
	 
	 wire    [9:0]   char_x2  ;  
	 wire    [9:0]   char_y2  ;  
	 reg     [159:0] char_layer2   [31:0]  ;
	 
	 wire    [9:0]   char_x3  ;   
	 wire    [9:0]   char_y3  ;   
	 reg     [159:0] char_layer3   [31:0]  ;

	 wire    [9:0]   char_x4  ;  
	 wire    [9:0]   char_y4  ;  
	 reg     [159:0] char_layer4   [31:0]  ;
	 
	 wire    [9:0]   char_xx  ;   
	 wire    [9:0]   char_yx  ; 
	 reg     [127:0] charx    [31:0]  ; 
	 
    always @ (posedge clk, negedge rst_n)
        if (!rst_n)
            cnt_hs <= 0;
        else
            if (cnt_hs < HS_E - 1)
                cnt_hs <= cnt_hs + 1'b1;
            else
                cnt_hs <= 0;
					        
    always @ (posedge clk, negedge rst_n)
        if (!rst_n)
            cnt_vs <= 0;
        else
            if (cnt_hs == HS_E - 1)
                if (cnt_vs < VS_E - 1)
                    cnt_vs <= cnt_vs + 1'b1;
                else
                    cnt_vs <= 0;
            else
                cnt_vs <= cnt_vs;
					 
    always @ (posedge clk, negedge rst_n)
        if (!rst_n)
            vga_hs <= 1'b1;
        else
            if (cnt_hs < HS_A - 1)
                vga_hs <= 1'b0;
            else
                vga_hs <= 1'b1;
          
    always @ (posedge clk, negedge rst_n)
        if (!rst_n)
            vga_vs <= 1'b1;
        else
            if (cnt_vs < VS_A - 1) 
                vga_vs <= 1'b0;
            else
                vga_vs <= 1'b1;

		assign en_hs = (cnt_hs > HS_A + HS_B - 1)&& (cnt_hs < HS_E - HS_D);
		assign en_vs = (cnt_vs > VS_A + VS_B - 1) && (cnt_vs < VS_E - VS_D);
		assign en = en_hs && en_vs;
		assign vga_blank_n = en; 
		          
		assign pos_x = en ? (cnt_hs - (HS_A + HS_B - 1'b1)) : 0;
		assign pos_y = en ? (cnt_vs - (VS_A + VS_B - 1'b1)) : 0;
	 
		always@(posedge clk or negedge rst_n) begin
			if(!rst_n) begin
				cnt_clk <= 0;
				cnt<=0;
			end
				
			else if ( game_status == RESTART) begin
				cnt<=0;
				if(cnt_clk < 150000000 )begin

					cnt_clk <= cnt_clk+1;	
					if(pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 13 && pos_y[9:4] < 15&& char_layer4[char_y4][159-char_x4] == 1'b1) begin
						vga_rgb<= GREEN; end
					else				
					  vga_rgb <=  BLACK;
				
				end
		
				else if (150000000 <= cnt_clk && cnt_clk < 200000000 )begin
					cnt_clk <= cnt_clk+1;
					if(picture_flag_enable) begin
						vga_rgb <= rom_data;
					end
					else begin
						vga_rgb<= 24'b000000000000000000000000;
					end
				
				end
				
				else if(200000000 <= cnt_clk && cnt_clk < 300000000 )begin
					cnt_clk <= cnt_clk+1;	
					if(pos_x[9:4] >=5 && pos_x[9:4] < 13 && pos_y[9:4] >= 4 && pos_y[9:4] < 6&& charx[char_yx][159-char_xx] == 1'b1) begin
						vga_rgb<= WHITE; end
					else
					begin
					  if(pos_x[9:4] >= 0 && pos_x[9:4] < 15 )begin
						case (bcd_data_best[11:8])
							4'd0:begin
								if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
									vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
							else
										 vga_rgb = BLACK;
							end
						4'd1:begin
							if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
					else
										  vga_rgb = BLACK;

				end
						4'd2:begin
					if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd3:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd4:begin
						 if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd5:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
						  end

						4'd6:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd7:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd8:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd9:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end 
				default: 
								 vga_rgb = BLACK;
			endcase
			end
			else if(pos_x[9:4] >= 15 && pos_x[9:4] < 25)begin
			case (bcd_data_best[7:4])
					 4'd0:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						else
										 vga_rgb = BLACK;
						  end
					 4'd1:begin
						  if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
			
					end
					 4'd2:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
					end
					 4'd3:begin
			if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
									 vga_rgb = 24'hffa07a;
					 else
									vga_rgb = BLACK;	
					end
					 4'd4:begin
			
					 if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
									 vga_rgb = 24'hffa07a;
					 else
									vga_rgb = BLACK;	
					end
					 4'd5:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
						  end
					 4'd6:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
					end
					 4'd7:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
					end
					 4'd8:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
					end
					 4'd9:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_x[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
					end 
					default: 
										 vga_rgb = BLACK;
				endcase
		end
		else begin
		case (bcd_data_best[3:0])
					 4'd0:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
						  end
					 4'd1:begin
						  if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd2:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd3:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd4:begin
						  if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd5:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
						  end
					 4'd6:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd7:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd8:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd9:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end 
					default: 
										 vga_rgb = BLACK;
				   endcase
				    end
					end
					
					
				end
				
				
				



				
				else if(cnt_clk >= 300000000) begin
					if(pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 8 && pos_y[9:4] < 10&& char[char_y][159-char_x] == 1'b1) begin
						vga_rgb<= WHITE; end
					else if(pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 13 && pos_y[9:4] < 15 && char_layer1[char_y1][159-char_x1] == 1'b1)begin
				      vga_rgb<= GREEN; end
					else if(pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 16 && pos_y[9:4] < 18 && char_layer2[char_y2][159-char_x2] == 1'b1)begin
						vga_rgb<= YELLOW;end
					else if(pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 19 && pos_y[9:4] < 21 && char_layer3[char_y3][159-char_x3] == 1'b1)begin
						vga_rgb<= RED;end
					else begin
						vga_rgb<= BLACK;end
			
				end
			end
						
			else if ( game_status == PLAY|game_status == START) begin
				cnt<=0;
				if(pos_x[9:4] == apple_x && pos_y[9:4] == apple_y) begin
					vga_rgb = PINK;
				end					
				else if(snake_show == NONE) begin
					if(fact_status==1)begin
					if(pos_x[9:4] >=4 && pos_x[9:4] < 5 && pos_y[9:4] < 20 && pos_y[9:4] >= 10) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=35 && pos_x[9:4] < 36 && pos_y[9:4] < 20 && pos_y[9:4] >= 10) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=15 && pos_x[9:4] < 30 && pos_y[9:4] < 6 && pos_y[9:4] >= 5) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=10 && pos_x[9:4] < 30 && pos_y[9:4] < 25 && pos_y[9:4] >= 24) begin
						vga_rgb<= ICEYELLOW;
					end
					else
					vga_rgb = Seashell3;
				   end
					
					
					
					else if(fact_status==2)begin
					if(pos_x[9:4] >=4 && pos_x[9:4] < 5 && pos_y[9:4] < 25 && pos_y[9:4] >= 5) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=35 && pos_x[9:4] < 36 && pos_y[9:4] < 25 && pos_y[9:4] >= 5) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=15 && pos_x[9:4] < 30 && pos_y[9:4] < 6 && pos_y[9:4] >= 5) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=10 && pos_x[9:4] < 30 && pos_y[9:4] < 25 && pos_y[9:4] >= 24) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=10 && pos_x[9:4] < 30 && pos_y[9:4] < 16 && pos_y[9:4] >= 15) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=20 && pos_x[9:4] < 21 && pos_y[9:4] < 25 && pos_y[9:4] >= 5) begin
						vga_rgb<= ICEYELLOW;
					end			
					else
					vga_rgb = Seashell3;
					end

					else
					vga_rgb = Seashell3;
					end
				else if(snake_show == WALL) begin
					vga_rgb = RED;
				end
				else if(snake_show == HEAD|snake_show == BODY) begin
					case(body_status)
					4'b0001: vga_rgb = Seashell2;
					4'b0010:vga_rgb = WHITE;
					4'b0011:vga_rgb = BLUE;
					4'b0100:vga_rgb = Salmon;
					4'b0101:vga_rgb = PINK;
					default: vga_rgb = Seashell;
					endcase
				end
				else begin
					vga_rgb<= Seashell3;
				end
			end

			else if(bcd_data[11:8]==1'd1)begin
				if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
					vga_rgb = 24'hff80ff;

				else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
					vga_rgb = 24'hff80ff;

				else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
					vga_rgb = 24'hff80ff;
				else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
					vga_rgb = 24'hff80ff;
				else 
					vga_rgb = BLACK;
				end
				
			else if (game_status==DIE )  begin
				cnt_clk<=0;
				if(cnt<100000000)begin
					cnt<=cnt+1;
					if(pos_x[9:4] == apple_x && pos_y[9:4] == apple_y) begin
						vga_rgb = PINK;
					end					
				else if(snake_show == NONE) begin
					if(fact_status==1)begin
					if(pos_x[9:4] >=4 && pos_x[9:4] < 5 && pos_y[9:4] < 20 && pos_y[9:4] >= 10) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=35 && pos_x[9:4] < 36 && pos_y[9:4] < 20 && pos_y[9:4] >= 10) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=15 && pos_x[9:4] < 30 && pos_y[9:4] < 6 && pos_y[9:4] >= 5) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=10 && pos_x[9:4] < 30 && pos_y[9:4] < 25 && pos_y[9:4] >= 24) begin
						vga_rgb<= ICEYELLOW;
					end
					else
					vga_rgb = BLACK;
				   end
				
					else if(fact_status==2)begin
					if(pos_x[9:4] >=4 && pos_x[9:4] < 5 && pos_y[9:4] < 25 && pos_y[9:4] >= 5) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=35 && pos_x[9:4] < 36 && pos_y[9:4] < 25 && pos_y[9:4] >= 5) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=15 && pos_x[9:4] < 30 && pos_y[9:4] < 6 && pos_y[9:4] >= 5) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=10 && pos_x[9:4] < 30 && pos_y[9:4] < 25 && pos_y[9:4] >= 24) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=10 && pos_x[9:4] < 30 && pos_y[9:4] < 16 && pos_y[9:4] >= 15) begin
						vga_rgb<= ICEYELLOW;
					end
					else if(pos_x[9:4] >=20 && pos_x[9:4] < 21 && pos_y[9:4] < 25 && pos_y[9:4] >= 5) begin
						vga_rgb<= ICEYELLOW;
					end							
					else
					vga_rgb = BLACK; 
					end
					else
					vga_rgb = BLACK; 
					end					
					else if(snake_show == WALL) begin
						vga_rgb = RED;end
					else if(snake_show == HEAD|snake_show == BODY) begin
						case(body_status)
						4'b0001: vga_rgb = Seashell2;
						4'b0010:vga_rgb = WHITE;
						4'b0011:vga_rgb = BLUE;
						4'b0100:vga_rgb = Salmon;
						4'b0101:vga_rgb = PINK;
					default: vga_rgb = Seashell;
					endcase
					end
					else begin
					vga_rgb<= BLACK;
					end
				end
				else if(cnt>=100000000) begin
					if(pos_x[9:4] >= 0 && pos_x[9:4] < 15 )begin
						case (bcd_data[11:8])
							4'd0:begin
								if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
									vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
							else
										 vga_rgb = BLACK;
							end
						4'd1:begin
							if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
							else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
					else
										  vga_rgb = BLACK;

				end
						4'd2:begin
					if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd3:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd4:begin
						 if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd5:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
						  end

						4'd6:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd7:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd8:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end
						4'd9:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
				end 
				default: 
								 vga_rgb = BLACK;
			endcase
			end
			else if(pos_x[9:4] >= 15 && pos_x[9:4] < 25)begin
			case (bcd_data[7:4])
					 4'd0:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						else
										 vga_rgb = BLACK;
						  end
					 4'd1:begin
						  if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
			
					end
					 4'd2:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
					end
					 4'd3:begin
			if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
									 vga_rgb = 24'hffa07a;
					 else
									vga_rgb = BLACK;	
					end
					 4'd4:begin
			
					 if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
									 vga_rgb = 24'hffa07a;
					 else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
									 vga_rgb = 24'hffa07a;
					 else
									vga_rgb = BLACK;	
					end
					 4'd5:begin
						if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 14 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 6 && pos_x[9:4] < 8 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 12 && pos_x[9:4] < 14 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										  vga_rgb = BLACK;
						  end
					 4'd6:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
					end
					 4'd7:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
					end
					 4'd8:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
					end
					 4'd9:begin
				if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_x[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 24 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 16 && pos_x[9:4] < 18 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 22 && pos_x[9:4] < 24 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else
										 vga_rgb = BLACK;
					end 
					default: 
										 vga_rgb = BLACK;
				endcase
		end
		else begin
		case (bcd_data[3:0])
					 4'd0:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
						  end
					 4'd1:begin
						  if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd2:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd3:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd4:begin
						  if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd5:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
						  end
					 4'd6:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd7:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd8:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end
					 4'd9:begin
				if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 34 && pos_y[9:4] >= 20 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 26 && pos_x[9:4] < 28 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 8 && pos_y[9:4] < 16)
										  vga_rgb = 24'hffa07a;
						  else if(pos_x[9:4] >= 32 && pos_x[9:4] < 34 && pos_y[9:4] >= 14 && pos_y[9:4] < 22)
										  vga_rgb = 24'hffa07a;
						  else 
											vga_rgb = BLACK;
					end 
					default: 
										 vga_rgb = BLACK;
				endcase
				end
			end
		end
	 else
		 vga_rgb = 24'h000000;
	end

	rom	rom_inst (
		.address    (cnt_rom_address),
		.clock      (clk),
		.q          (rom_data)
	);

	
	always @( posedge clk or negedge rst_n ) begin
		 if ( !rst_n ) begin
		 cnt_rom_address <= 0;
		 end
		 else if ( flag_clear_rom_address ) begin 
			  cnt_rom_address <= 0;
		 end
			  else if ( picture_flag_enable) begin 
			  cnt_rom_address <= cnt_rom_address + 1;
			  end
			  else begin  
			  cnt_rom_address <= cnt_rom_address;
			end
		end
		
		assign flag_clear_rom_address = cnt_rom_address == height * width - 1;

		assign flag_begin_h = pos_x > ( ( 640 - width ) / 2 ) && pos_x < ( ( 640 - width ) / 2 ) + width + 1;
		assign flag_begin_v = pos_y > ( ( 480 - height )/2 ) && pos_y <( ( 480 - height )/2 ) + height + 1;
		assign picture_flag_enable = flag_begin_h && flag_begin_v;

assign  char_xx  =   (pos_x[9:4] >=5 && pos_x[9:4] < 13 && pos_y[9:4] >= 4 && pos_y[9:4] < 6)? (pos_x - 5*16) : 0;
assign  char_yx  =   (pos_x[9:4] >=5 && pos_x[9:4] < 13 && pos_y[9:4] >= 4 && pos_y[9:4] < 6)? (pos_y - 4*16) : 0;
 
assign  char_x  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)? (pos_x - 15*16) : 0;
assign  char_y  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)? (pos_y - 8*16) : 0;

assign  char_x1  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 13 && pos_y[9:4] < 15)? (pos_x - 15*16) : 0;
assign  char_y1  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 13 && pos_y[9:4] < 15)? (pos_y - 13*16) : 0;

assign  char_x2  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 16 && pos_y[9:4] < 18)? (pos_x - 15*16) : 0;
assign  char_y2  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 16 && pos_y[9:4] < 18)? (pos_y - 16*16) : 0;

assign  char_x3  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 19 && pos_y[9:4] < 21)? (pos_x - 15*16) : 0;
assign  char_y3  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 19 && pos_y[9:4] < 21)? (pos_y - 19*16) : 0;

assign  char_x4  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 13 && pos_y[9:4] < 15)? (pos_x - 15*16) : 0;
assign  char_y4  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 13 && pos_y[9:4] < 15)? (pos_y - 13*16) : 0;
 
always@(posedge clk)
    begin
        char[0]     <=  160'h0000000000000000000000000000000000000000;
        char[1]     <=  160'h0000000000000000000000000000000000000000; 
        char[2]     <=  160'h0000000000000000000000000000000000000000; 
        char[3]     <=  160'h0000000000000000000000000000000000000000; 
        char[4]     <=  160'h0000000000000000000000000000000000000000;
        char[5]     <=  160'h0000000000000000000000000000000000000000; 
        char[6]     <=  160'h0000000000000000000000000000000000000000; 
        char[7]     <=  160'h0000000000000000000000000000000000000000; 
        char[8]     <=  160'h7E00018000000000018000000000000000000000; 
        char[9]     <=  160'h7F00018001F001F0018000000000078003000000; 
        char[10]    <=  160'h6380000003F003F0000000000000078003000000;
        char[11]    <=  160'h6180000003000300000000000000018003000000; 
        char[12]    <=  160'h6180078003000300078003C00C30018007E00C30; 
        char[13]    <=  160'h618007800FF00FF0078007E00C30018007E00C30; 
        char[14]    <=  160'h618001800FF00FF001800E700C30018003000C30; 
        char[15]    <=  160'h618001800300030001800C000C30018003000C30; 
        char[16]    <=  160'h618001800300030001800C000C30018003000C30; 
        char[17]    <=  160'h638001800300030001800C000C30018003000C30; 
        char[18]    <=  160'h7F0001800300030001800E700E70018003000E70; 
        char[19]    <=  160'h7E0007E00300030007E007E007F007E003E007F0; 
        char[20]    <=  160'h000007E00300030007E003C003B007E001E003B0; 
        char[21]    <=  160'h0000000000000000000000000000000000000030;
        char[22]    <=  160'h0000000000000000000000000000000000000030; 
        char[23]    <=  160'h00000000000000000000000000000000000007E0; 
        char[24]    <=  160'h00000000000000000000000000000000000007C0; 
        char[25]    <=  160'h0000000000000000000000000000000000000000; 
        char[26]    <=  160'h0000000000000000000000000000000000000000; 
        char[27]    <=  160'h0000000000000000000000000000000000000000; 
        char[28]    <=  160'h0000000000000000000000000000000000000000; 
        char[29]    <=  160'h0000000000000000000000000000000000000000; 
        char[30]    <=  160'h0000000000000000000000000000000000000000; 
        char[31]    <=  160'h0000000000000000000000000000000000000000;
    end


always@(posedge clk)
    begin
        char_layer1[0]     <=  160'h0000000000000000000000000000000000000000;
        char_layer1[1]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[2]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[3]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[4]     <=  160'h0000000000000000000000000000000000000000;
        char_layer1[5]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[6]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[7]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[8]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[9]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[10]    <=  160'h0000000000000000000000000000000000000000;
        char_layer1[11]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[12]    <=  160'h0300000000000000000000000000000000000600; 
        char_layer1[13]    <=  160'h0300000000000000000000000000000000000E00; 
        char_layer1[14]    <=  160'h0300001E000330001E0003300000000000003E00; 
        char_layer1[15]    <=  160'h0300000300033000330003700000000000000600; 
        char_layer1[16]    <=  160'h0300000300033000330003800000000000000600; 
        char_layer1[17]    <=  160'h0300001F000330003F0003000000000000000600; 
        char_layer1[18]    <=  160'h0300003300033000300003000000000000000600; 
        char_layer1[19]    <=  160'h0300003300033000300003000000000000000600; 
        char_layer1[20]    <=  160'h03F0001F0001E0001E0003000000000000000600; 
        char_layer1[21]    <=  160'h0000000000006000000000000000000000000000;
        char_layer1[22]    <=  160'h000000000000C000000000000000000000000000; 
        char_layer1[23]    <=  160'h0000000000078000000000000000000000000000; 
        char_layer1[24]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[25]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[26]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[27]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[28]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[29]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[30]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer1[31]    <=  160'h0000000000000000000000000000000000000000;
    end                         
	                              

always@(posedge clk)
    begin
        char_layer4[0]     <=  160'h0000000000000000000000000000000000000000;
        char_layer4[1]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer4[2]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer4[3]     <=  160'h0000000000000000000000000000000000000000;
        char_layer4[4]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer4[5]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer4[6]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer4[7]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer4[8]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer4[9]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer4[10]    <=  160'h0000000000000000000000000000000000000000;
        char_layer4[11]    <=  160'h00F000306000200010C001F8003F8003F0000780; 
        char_layer4[12]    <=  160'h0118001060002000118001000030800318001CC0; 
        char_layer4[13]    <=  160'h0308001860006000110001000010C00108001060; 
        char_layer4[14]    <=  160'h0200001860005000120001000010400108003020; 
        char_layer4[15]    <=  160'h0200001C60005000160001000010C00108002020; 
        char_layer4[16]    <=  160'h03000014600090001C0001000010800108002020; 
        char_layer4[17]    <=  160'h01C0001460009000180001300011800110002020; 
        char_layer4[18]    <=  160'h0070001260008800180003F8001F0001E0002020; 
        char_layer4[19]    <=  160'h00180012600108001C000100001C000180002020; 
        char_layer4[20]    <=  160'h000800136003F800140001000010000140002020; 
        char_layer4[21]    <=  160'h000800116003FC00120001000010000140002020;
        char_layer4[22]    <=  160'h00080011E0020400130001000010000120002020; 
        char_layer4[23]    <=  160'h02080010E0020400110001000010000130002020; 
        char_layer4[24]    <=  160'h02080010E0020600118001000010000110001040; 
        char_layer4[25]    <=  160'h031800106006020010C0010800100001080018C0;  
        char_layer4[26]    <=  160'h01F0001060040200104003FC001000010E000F80;  
        char_layer4[27]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer4[28]    <=  160'h0000000000000000000000000000000000000000;  
        char_layer4[29]    <=  160'h0000000000000000000000000000000000000000;  
        char_layer4[30]    <=  160'h0000000000000000000000000000000000000000;  
        char_layer4[31]    <=  160'h0000000000000000000000000000000000000000; 
    end                             

	 
always@(posedge clk)
    begin
        char_layer2[0]     <=  160'h0000000000000000000000000000000000000000;
        char_layer2[1]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[2]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[3]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[4]     <=  160'h0000000000000000000000000000000000000000;
        char_layer2[5]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[6]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[7]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[8]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[9]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[10]    <=  160'h0000000000000000000000000000000000000000;
        char_layer2[11]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[12]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[13]    <=  160'h0180000000000000000000000000000000000F00; 
        char_layer2[14]    <=  160'h0180000000000000000000000000000000001980; 
        char_layer2[15]    <=  160'h0180000F000198000F0001980000000000001980; 
        char_layer2[16]    <=  160'h0180000180019800198001B80000000000000180; 
        char_layer2[17]    <=  160'h0180000180019800198001C00000000000000300; 
        char_layer2[18]    <=  160'h0180000F800198001F8001800000000000000600; 
        char_layer2[19]    <=  160'h0180001980019800180001800000000000000C00; 
        char_layer2[20]    <=  160'h0180001980019800180001800000000000001800; 
        char_layer2[21]    <=  160'h01F8000F8000F0000F0001800000000000001F80;
        char_layer2[22]    <=  160'h0000000000003000000000000000000000000000; 
        char_layer2[23]    <=  160'h0000000000006000000000000000000000000000; 
        char_layer2[24]    <=  160'h000000000003C000000000000000000000000000; 
        char_layer2[25]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[26]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[27]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[28]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[29]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[30]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer2[31]    <=  160'h0000000000000000000000000000000000000000;
    end                             




always@(posedge clk)
    begin
        char_layer3[0]     <=  160'h0000000000000000000000000000000000000000;
        char_layer3[1]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[2]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[3]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[4]     <=  160'h0000000000000000000000000000000000000000;
        char_layer3[5]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[6]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[7]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[8]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[9]     <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[10]    <=  160'h0180000000000000000000000000000000000F00;
        char_layer3[11]    <=  160'h0180000000000000000000000000000000001980; 
        char_layer3[12]    <=  160'h0180000F000198000F0001980000000000001980; 
        char_layer3[13]    <=  160'h0180000180019800198001B80000000000000180; 
        char_layer3[14]    <=  160'h0180000180019800198001C00000000000000700; 
        char_layer3[15]    <=  160'h0180000F800198001F8001800000000000000180; 
        char_layer3[16]    <=  160'h0180001980019800180001800000000000001980; 
        char_layer3[17]    <=  160'h0180001980019800180001800000000000001980; 
        char_layer3[18]    <=  160'h01F8000F8000F0000F0001800000000000000F00; 
        char_layer3[19]    <=  160'h0000000000003000000000000000000000000000; 
        char_layer3[20]    <=  160'h0000000000006000000000000000000000000000; 
        char_layer3[21]    <=  160'h000000000003C000000000000000000000000000;
        char_layer3[22]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[23]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[24]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[25]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[26]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[27]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[28]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[29]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[30]    <=  160'h0000000000000000000000000000000000000000; 
        char_layer3[31]    <=  160'h0000000000000000000000000000000000000000;
    end  

	 
always@(posedge clk)
    begin
        charx[0]      <=  128'h00000000000000000000000000000000;
        charx[1]      <=  128'h00000000000000000000000000000000; 
        charx[2]      <=  128'h00000000000000000000000000000000; 
        charx[3]      <=  128'h00000000000000000000000000000000; 
        charx[4]      <=  128'h00000000000000000000000000000000;
        charx[5]      <=  128'h00000000000000000000000000000000; 
        charx[6]      <=  128'h00000000000000000000000000000000; 
        charx[7]      <=  128'h00000000000000000000000000000000; 
        charx[8]      <=  128'h00000000000000000000000000000000; 
        charx[9]      <=  128'h00000000000000000000000000000000; 
        charx[10]     <=  128'h0000000007C000000000030007E00600;
        charx[11]     <=  128'h00000000066000000000030001800600; 
        charx[12]     <=  128'h03C00000066003C003E007E0018007C0; 
        charx[13]     <=  128'h06600000066006600600030001800660; 
        charx[14]     <=  128'h0660000007C006600600030001800660; 
        charx[15]     <=  128'h07E00000066007E003C0030001800660; 
        charx[16]     <=  128'h06000000066006000060030001800660; 
        charx[17]     <=  128'h06000000066006000060030001800660; 
        charx[18]     <=  128'h03C0000007C003C007C001E001800660; 
        charx[19]     <=  128'h00000000000000000000000000000000; 
        charx[20]     <=  128'h00000000000000000000000000000000; 
        charx[21]     <=  128'h00000000000000000000000000000000;
        charx[22]     <=  128'h00000000000000000000000000000000; 
        charx[23]     <=  128'h00000000000000000000000000000000; 
        charx[24]     <=  128'h00000000000000000000000000000000; 
        charx[25]     <=  128'h00000000000000000000000000000000; 
        charx[26]     <=  128'h00000000000000000000000000000000; 
        charx[27]     <=  128'h00000000000000000000000000000000; 
        charx[28]     <=  128'h00000000000000000000000000000000; 
        charx[29]     <=  128'h00000000000000000000000000000000; 
        charx[30]     <=  128'h00000000000000000000000000000000; 
        charx[31]     <=  128'h00000000000000000000000000000000;
    end                        



 
 
endmodule
		 