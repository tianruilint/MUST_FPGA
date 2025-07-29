module snake(
    input clk,             
    input rst_n,          
    
    input [2:0] sw,       
    input key0_right,     
    input key1_left,       
    input key2_down,       
    input key3_up,        
    
    input [9:0] pos_x,     
    input [9:0] pos_y,     
    
    output [5:0] head_x,   
    output [5:0] head_y,    
    
    output reg [3:0] body_status,
    input add_cube,        
    input [1:0] game_status,
    input snake_display,   
    input [1:0] fact_status,
    
    output reg hit_body, 
    output reg hit_wall,   
    
    output reg [1:0] snake_show 
);

    localparam UP = 2'b00;
    localparam DOWN = 2'b01;
    localparam LEFT = 2'b10;
    localparam RIGHT = 2'b11;
    
    localparam NONE = 2'b00;
    localparam HEAD = 2'b01;
    localparam BODY = 2'b10;
    localparam WALL = 2'b11;
    
    localparam RESTART = 2'b00;
    localparam PLAY = 2'b10;
    localparam DIE = 2'b11;


    reg [3:0] cube_num;     
    reg [5:0] cube_x[15:0]; 
    reg [5:0] cube_y[15:0];
    reg [15:0] is_exist;   
    reg addcube_state;      
    reg [31:0] clk_cnt;     
    reg [23:0] speed;       
    reg [1:0] direct_r;    
    reg [1:0] direct_next;  
	 
	 integer i1;
	 integer i2;
	 integer i3;
	 integer i4;
	 integer i5;

    assign head_x = cube_x[0];
    assign head_y = cube_y[0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            speed <= 24'd12500000;
            direct_r <= RIGHT;
        end
        else if (game_status == RESTART) begin
            speed <= 24'd12500000;
            direct_r <= RIGHT;
        end
        else begin
            direct_r <= direct_next;
            case (fact_status)
                2'd0: speed <= 24'd2500000;  
                2'd1: speed <= 24'd6250000; 
                2'd2: speed <= 24'd3125000; 
                default: speed <= 24'd12500000;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
	    clk_cnt <= 0;
            init_snake_position();
            hit_wall <= 0;
            hit_body <= 0;
        end
        else if (game_status == RESTART) begin
	    clk_cnt <= 0;
            init_snake_position();
            hit_wall <= 0;
            hit_body <= 0;
        end
        else begin
		if (clk_cnt == speed) begin
                clk_cnt <= 0;
                if (game_status == PLAY) begin
                    // Wall collision check
                    if ((direct_r == UP && cube_y[0] == 1) ||
                        (direct_r == DOWN && cube_y[0] == 28) ||
                        (direct_r == LEFT && cube_x[0] == 1) ||
                        (direct_r == RIGHT && cube_x[0] == 38)) begin
                        hit_wall <= 1;
                    end
                    // Body collision check
                    else if (check_body_collision(1'b1)) begin
                        hit_body <= 1;
                    end
                    else begin
                        move_snake();
                    end
                end
            end
            else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end

    always @(*) begin
        case (direct_r)
            UP: direct_next = (~key1_left) ? LEFT : 
                             (~key0_right) ? RIGHT : UP;
            DOWN: direct_next = (~key1_left) ? LEFT :
                               (~key0_right) ? RIGHT : DOWN;
            LEFT: direct_next = (~key3_up) ? UP :
                               (~key2_down) ? DOWN : LEFT;
            RIGHT: direct_next = (~key3_up) ? UP :
                                (~key2_down) ? DOWN : RIGHT;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            is_exist <= 16'd31;
            cube_num <= 5;
            addcube_state <= 0;
        end
        else if (game_status == RESTART) begin
            is_exist <= 16'd31;
            cube_num <= 5;
            addcube_state <= 0;
        end
        else begin
            case (addcube_state)
                0: if (add_cube) begin
                    cube_num <= cube_num + 1;
                    is_exist[cube_num] <= 1;
                    addcube_state <= 1;
                end
                1: if (!add_cube) begin
                    addcube_state <= 0;
                end
            endcase
        end
    end

    always @(pos_x or pos_y) begin
        body_status <= get_body_status(pos_x[9:4], pos_y[9:4]);
    end

always @(pos_x or pos_y) begin
    if(pos_x >= 0 && pos_x < 640 && pos_y >= 0 && pos_y < 480) begin

        if(pos_x[9:4] == 0 || pos_y[9:4] == 0 || pos_x[9:4] == 39 || pos_y[9:4] == 29)
            snake_show = WALL;
        

        else if(pos_x[9:4] == cube_x[0] && pos_y[9:4] == cube_y[0] && is_exist[0])
            snake_show = (snake_display == 1) ? HEAD : NONE;
        

        else begin
            snake_show = NONE;
            for(i1 = 1; i1 < 16; i1 = i1 + 1) begin
                if(pos_x[9:4] == cube_x[i1] && pos_y[9:4] == cube_y[i1] && is_exist[i1]) begin
                    snake_show = (snake_display == 1) ? BODY : NONE;
                end
            end
        end
    end
end




    function automatic [3:0] get_body_status;
        input [9:4] x, y;
        begin
            get_body_status = 0;
            for (i2 = 0; i2 < 16; i2 = i2 + 1) begin
                if (x == cube_x[i2] && y == cube_y[i2]) begin
                    get_body_status = (i2 == 0) ? 1 :
                                    (i2 < 5) ? i2 + 1 :
				    (i2 == 5)? 5 :
				    (i2 > 5)? i2-4 :
				    (i2 == 8)? 5 :
				    (i2 > 8)? 11-i2 :
                                    (i2 > 10) ? 16-i2 : 1;
                end
            end
        end
    endfunction

    task automatic init_snake_position;
        begin
            for (i3 = 0; i3 < 16; i3 = i3 + 1) begin
                if (i3 < 5) begin
                    cube_x[i3] <= 10 - i3;
                    cube_y[i3] <= 5;
                end
                else begin
                    cube_x[i3] <= 0;
                    cube_y[i3] <= 0;
                end
            end
        end
    endtask

    function automatic check_body_collision;
        input dummy;  
        begin
            check_body_collision = 0;
            for (i4 = 1; i4 < 16; i4 = i4 + 1) begin
                if (cube_y[0] == cube_y[i4] && cube_x[0] == cube_x[i4] && is_exist[i4]) begin
                    check_body_collision = 1;
                end
            end
        end
    endfunction

    task automatic move_snake;
        begin
            for (i5 = 1; i5 < 16; i5 = i5 + 1) begin
                cube_x[i5] <= cube_x[i5-1];
                cube_y[i5] <= cube_y[i5-1];
            end
            
            case (direct_r)
                UP: begin
		       if(cube_y[0] == 1)
			    hit_wall <= 1;
		       else
			    cube_y[0] <= cube_y[0]-1;
		       end
                DOWN: begin
		       if(cube_y[0] == 28)
			    hit_wall <= 1;
		       else
			    cube_y[0] <= cube_y[0]+1;
		       end
                LEFT: begin
		       if(cube_x[0] == 1)
			    hit_wall <= 1;
		       else
			    cube_x[0] <= cube_x[0]-1;
		       end
                RIGHT: begin
		       if(cube_x[0] == 38)
			    hit_wall <= 1;
		       else
			    cube_x[0] <= cube_x[0]+1;
		       end
            endcase
        end
    endtask




endmodule