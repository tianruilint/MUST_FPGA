module running_light
#(
parameter MAX = 25'd24_999_999
 )
(
input sys_clk,
input sys_rst_n,
output reg [3:0] led_out
);

reg [24:0] cnt;

always @(posedge sys_clk or negedge sys_rst_n)
 if(sys_rst_n == 1'b0)
 cnt <= 25'd0;
 else if(cnt == MAX)
 cnt <= 25'd0;
 else
 cnt <= cnt + 25'd1;


always @(posedge sys_clk or negedge sys_rst_n)
 if(sys_rst_n == 1'b0)
 led_out <= 4'b1110;
 else if(cnt == MAX)
 led_out <= {led_out[2:0],led_out[3]};
 else
 led_out <= led_out;
 
endmodule