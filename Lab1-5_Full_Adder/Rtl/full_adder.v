module full_adder
(
input key_in1,
input key_in2,
input cin,

output sum,
output cout
);

wire sum1;
wire cout1;
wire cout2;

half_adder half_adder1
(
.key_in1(key_in1),
.key_in2(key_in2),
.sum(sum1),
.cout(cout1)
);

half_adder half_adder2
(
.key_in1(sum1),
.key_in2(cin),
.sum(sum),
.cout(cout2)
);

assign cout = cout1 | cout2;

endmodule