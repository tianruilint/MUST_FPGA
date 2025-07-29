module score_ctrl (
    input wire clk,                  
    input wire rst_n,                
    input wire add_cube,            
    input wire [1:0] game_status,    
    output wire [11:0] bcd_data,     
    output wire [11:0] bcd_data_best,
    output wire [7:0] bcd_data2      
);


    parameter MAX_SCORE = 8'd100;   
    parameter RESTART = 2'b00;      


    reg [7:0] bin_data;           
    reg [7:0] bin_data_best;     


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bin_data <= 8'd0;
        else if (game_status == RESTART)
            bin_data <= 8'd0;
        else if (add_cube && (bin_data < MAX_SCORE))
            bin_data <= bin_data + 8'd1;
		  else
				bin_data <= bin_data;
    end


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bin_data_best <= 8'd0;
        else if (bin_data >= bin_data_best)
            bin_data_best <= bin_data;
		  else
				bin_data_best <= bin_data_best;
    end


    function [11:0] bin_to_bcd;
        input [7:0] bin_input;
        begin
            bin_to_bcd[3:0]  = bin_input % 10;           
            bin_to_bcd[7:4]  = (bin_input / 10) % 10;    
            bin_to_bcd[11:8] = (bin_input / 100) % 10;   
        end
    endfunction

    assign bcd_data = bin_to_bcd(bin_data);
    assign bcd_data_best = bin_to_bcd(bin_data_best);
    assign bcd_data2 = bin_data;

endmodule