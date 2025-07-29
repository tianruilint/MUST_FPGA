module game_ctrl_unit (
    input  wire       clk,        
    input  wire       rst_n,      
    input  wire       key0_right, 
    input  wire       key1_left,  
    input  wire       key2_down,  
    input  wire       key3_up,    
    input  wire       hit_wall,  
    input  wire       hit_body,   
    input  wire       hit_stone,  
    input  wire [11:0]bcd_data,   
    
    output reg        snake_display,
    output reg  [1:0] fact_status, 
    output reg  [1:0] game_status, 
    output wire       clear_signal, 
    output wire       start_signal  
);

    localparam RESTART = 2'b00,
               START   = 2'b01,
               PLAY    = 2'b10,
               DIE     = 2'b11;

    localparam WELCOME_TIME    = 32'd150000000,  
               FLASH_PERIOD    = 32'd100000000, 
               FLASH_INTERVAL  = 32'd12500000; 

    reg [32:0] cnt_clk;   
    reg [31:0] flash_cnt;  

    wire any_key_pressed = ~key0_right || ~key1_left || ~key2_down || ~key3_up;
	 
    assign start_signal = (game_status == PLAY);
    assign clear_signal = (game_status == START) && (any_key_pressed);


    wire game_over = hit_wall || hit_stone || hit_body || bcd_data[11:8] >= 1'd1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_clk <= 0;
            flash_cnt <= 0;
            snake_display <= 1'b1;
            game_status <= RESTART;
            fact_status <= 2'b00;
        end
        else begin
            case (game_status)
                RESTART: begin
                    cnt_clk <= cnt_clk + 1'b1;
                    if (cnt_clk > WELCOME_TIME) begin
                        if (~key2_down || ~key1_left || ~key0_right) begin
                            game_status <= START;
                            fact_status <= ~key2_down ? 2'b00 :
                                         ~key1_left  ? 2'b01 :
                                         ~key0_right ? 2'b10 : fact_status;
                        end
                    end
                end

                START: begin
                    game_status <= any_key_pressed ? PLAY : START;
                end

                PLAY: begin
                    game_status <= game_over ? DIE : PLAY;
                end

                DIE: begin
                    if (flash_cnt <= FLASH_PERIOD) begin
                        flash_cnt <= flash_cnt + 1'b1;
                        case (flash_cnt)
                            FLASH_INTERVAL * 1: snake_display <= 1'b0;
                            FLASH_INTERVAL * 2: snake_display <= 1'b1;
                            FLASH_INTERVAL * 3: snake_display <= 1'b0;
                            FLASH_INTERVAL * 4: snake_display <= 1'b1;
                            FLASH_INTERVAL * 5: snake_display <= 1'b0;
                            FLASH_INTERVAL * 6: snake_display <= 1'b1;
                        endcase
                    end
                    else if (any_key_pressed) begin
                        cnt_clk <= 0;
                        flash_cnt <= 0;
                        game_status <= RESTART;
                    end
                end

                default: game_status <= RESTART;
            endcase
        end
    end

endmodule