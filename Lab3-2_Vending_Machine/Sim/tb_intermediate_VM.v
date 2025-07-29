`timescale 1ns/1ns
module tb_intermediate_VM();

reg sys_clk;
reg sys_rst_n;
reg pi_money_one;
reg pi_money_half;
reg random_data_gen;

wire po_cola;
wire po_money;

initial begin
sys_clk = 1'b1;
sys_rst_n <= 1'b0;
#20
sys_rst_n <= 1'b1;
end

always #10 sys_clk = ~sys_clk;

 always@(posedge sys_clk or negedge sys_rst_n)
 if(sys_rst_n == 1'b0)
 random_data_gen <= 1'b0;
 else
 random_data_gen <= {$random} % 2;


 always@(posedge sys_clk or negedge sys_rst_n)
 if(sys_rst_n == 1'b0)
 pi_money_one <= 1'b0;
 else
 pi_money_one <= random_data_gen;


 always@(posedge sys_clk or negedge sys_rst_n)
 if(sys_rst_n == 1'b0)
 pi_money_half <= 1'b0;
 else

 pi_money_half <= ~random_data_gen;

 wire [3:0] state = intermediate_VM_inst.state;
 wire [1:0] pi_money = intermediate_VM_inst.pi_money;

 intermediate_VM intermediate_VM_inst(
 .sys_clk (sys_clk ),
 .sys_rst_n (sys_rst_n ),
 .pi_money_one (pi_money_one ),
 .pi_money_half (pi_money_half ),

 .po_cola (po_cola ),
 .po_money (po_money )
 );

 endmodule