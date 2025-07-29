module Line_Decoder2_4
(
input in1,
input in2,
input in3,

output reg [3:0] out
);

always@(*)
case({in1, in2, in3})
3'b000 : out = 4'b0000;
3'b010 : out = 4'b0000;
3'b100 : out = 4'b0000;
3'b110 : out = 4'b0000;
3'b001 : out = 4'b0001;
3'b011 : out = 4'b0010;
3'b101 : out = 4'b0100;
3'b111 : out = 4'b1000;
default: out = 4'b0000;
endcase

endmodule