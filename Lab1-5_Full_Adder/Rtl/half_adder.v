module half_adder
(
input key_in1,
input key_in2,
output sum,
output cout
);

assign {cout,sum} = key_in1 + key_in2;

endmodule