`timescale 1ns/1ns
module tb_full_adder();

reg key_in1;
reg key_in2;
reg cin;

wire sum;
wire cout;

initial begin
key_in1 <= 1'b0;
key_in2 <= 1'b0;
cin <= 1'b0;
end

always #10 key_in1 <= {$random} % 2;

always #10 key_in2 <= {$random} % 2;

always #10 cin <= {$random} % 2;

full_adder full_adder_inst(
.key_in1 (key_in1),
.key_in2 (key_in2),
.cin (cin),

.sum (sum),
.cout (cout)
);

endmodule