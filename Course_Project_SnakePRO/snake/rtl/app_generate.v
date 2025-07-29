module apple_generate(
	input clk,  
	input rst_n,
	
	input [5:0]head_x,
	input [5:0]head_y,

	input [1:0]fact_status,
	
	output reg [5:0]apple_x,
	output reg [4:0]apple_y,
	output reg hit_stone,

	output reg add_cube
);

	reg [31:0]clk_cnt;
	reg [10:0]random_num;
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			random_num <= 11'b1; 
		else 
			random_num <= {random_num[9:0], random_num[10] ^ random_num[8]};
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			clk_cnt <= 0;
			apple_x <= 20;
			apple_y <= 10;
			add_cube <= 0;
			hit_stone<=0;
		end
		else begin
			if(apple_x == head_x && apple_y == head_y) begin
				add_cube <= 1;
				apple_x <= (random_num[10:5] > 38) ? (random_num[10:5] - 25) : (random_num[10:5] == 0) ? 1 : random_num[10:5];
				apple_y <= (random_num[4:0] > 28) ? (random_num[4:0] - 3) : (random_num[4:0] == 0) ? 1:random_num[4:0];
			end  
			else if(fact_status==1)begin
			  add_cube <= 0;
			  if(apple_y <20 && apple_y >=10 && apple_x== 35)
			  apple_x<=apple_x+1;
			  else if(apple_y <20 && apple_y >=10 && apple_x== 4)
			  apple_x<=apple_x+1;
			  else if(apple_x <30 && apple_x >=15 && apple_y== 5)
			  apple_y<=apple_y+1;
			  else if(apple_x <30 && apple_x >=10 && apple_y== 24)
			  apple_y<=apple_y+1;
			  else
			  apple_x<=apple_x;
			  
			  if(head_x >=4 && head_x <5 && head_y <20 && head_y >=10)
				hit_stone<=1;
			  else if(head_x >=35 && head_x <36 && head_y <20 && head_y >=10)
				hit_stone<=1;
			  else if(head_x >=15 && head_x <30 && head_y <6 && head_y >=5)
				hit_stone<=1;
				else if(head_x >=10 && head_x <30 && head_y <25 && head_y >=24)
				hit_stone<=1;
			  else
				hit_stone<=0;
				end
		
			else if(fact_status==2)begin
			  add_cube <= 0;
			   if(apple_x==4 && apple_y < 25 && apple_y >= 5)
			  apple_x<=apple_x+1;
			  else if(apple_x==35 && apple_y < 25 && apple_y >= 5)
			  apple_x<=apple_x+1;
			  else if(apple_x  >=15 && apple_x < 30 && apple_y == 5)
			  apple_y<=apple_y+1;
			  else if(apple_x  >=10 && apple_x < 30 && apple_y == 24)
			  apple_y<=apple_y+1;
			  else if(apple_x==20 && apple_y  < 25 && apple_y  >= 5)	 
			  apple_x<=apple_x+1;
			  else if(apple_x  >=10 && apple_x  < 30 && apple_y  == 15)
			  apple_x<=apple_x+1;		  
			  else
			  apple_x<=apple_x;
		  		
			  if(head_x  >=20 && head_x  < 21 && head_y  < 25 && head_y  >= 5)
				hit_stone<=1;
			  else if(head_x  >=4 && head_x  < 5 && head_y  < 25 && head_y  >= 5)
				hit_stone<=1;
			  else if(head_x  >=35 && head_x  < 36 && head_y  < 25 && head_y  >= 5)
				hit_stone<=1;
			  else if(head_x  >=15 && head_x  < 30 && head_y  < 6 && head_y  >= 5)
			    hit_stone<=1;
			   else if(head_x  >=10 && head_x  < 30 && head_y  < 25 && head_y  >= 24)
				hit_stone<=1;
			  else if(head_x  >=10 && head_x  < 30 && head_y  < 16 && head_y  >= 15)
				hit_stone<=1;
				else
				hit_stone<=0;
			end
			else begin
				add_cube <= 0;
				hit_stone<=0;
			end
		end
		end
endmodule