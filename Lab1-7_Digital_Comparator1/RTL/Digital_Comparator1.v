module Digital_Comparator1(
input in1,
input in2,

output reg less,
output reg greater,
output reg equal
);

always @(in1 or in2) begin
if(in1<in2)
{less,equal,greater} <= 3'b011;
else if(in1==in2)
{less,equal,greater} <= 3'b101;
else
{less,equal,greater} <= 3'b110;
end

endmodule