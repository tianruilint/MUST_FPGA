`timescale 1ns/1ns
module tb_Digital_Comparator1();

reg in1;
reg in2;

wire less;
wire greater;
wire equal;

initial begin
in1 <= 1'b0;
in2 <= 1'b0;
end

always #10 in1 <= {$random} % 2;

always #10 in2 <= {$random} % 2;

Digital_Comparator1 Digital_Comparator1_inst
(
.in1(in1),
.in2(in2),
.less(less),
.greater(greater),
.equal(equal)
);

endmodule