module syn_flip_flop(
 input sys_clk,
 input sys_rst_n,
 input key_in,
 output reg led_out
);

always@(posedge sys_clk)

if(sys_rst_n == 1'b0)
 led_out <= 1'b0;
else
 led_out <= key_in;
 
endmodule