module vm_Refund
(
input sys_clk,
input sys_rst_n,
input pi_money_one,
input pi_money_half,

output po_money_half,
output po_money_one,
output reg po_cola
);

parameter IDLE = 4'b0001;
parameter HALF = 4'b0010;
parameter ONE = 4'b0100;
parameter ONE_HALF = 4'b1000;

reg [3:0] state;
wire [1:0] pi_money;
reg [1:0] po_money;
reg [3:0] state_saved;
reg [1:0] pi_money_saved;

assign pi_money = {pi_money_one, pi_money_half};

always@(posedge sys_clk)
begin
    if(sys_rst_n == 1'b1)
        state_saved <= state;
        pi_money_saved <= pi_money;
end



always@(posedge sys_clk or negedge sys_rst_n)
if(sys_rst_n == 1'b0)
state <= IDLE;
else case(state)
IDLE : if(pi_money == 2'b01)
state <= HALF;
else if(pi_money == 2'b10)
state <= ONE;
else
state <= IDLE;
HALF : if(pi_money == 2'b01)
state <= ONE;
else if(pi_money == 2'b10)
state <= ONE_HALF;
else
state <= HALF;
ONE : if(pi_money == 2'b01)
state <= ONE_HALF;
else if(pi_money == 2'b10)
state <= IDLE;
else
state <= ONE;
ONE_HALF : if(pi_money == 2'b01)
state <= IDLE;
else if(pi_money == 2'b10)
state <= IDLE;
else
state <= ONE_HALF;
default : state <= IDLE;
endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
    begin
        if((state_saved == ONE_HALF && pi_money_saved != 2'b00) || (state_saved == ONE && pi_money_saved == 2'b10))
            po_cola <= 1'b1;
        else
            po_cola <= 1'b0;
    end
	 else if((state == ONE_HALF && pi_money == 2'b01) || (state == ONE_HALF && pi_money == 2'b10) || (state == ONE && pi_money == 2'b10))
        po_cola <= 1'b1;
    else
        po_cola <= 1'b0;


always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
    begin
        case(state_saved)
            IDLE: po_money <= pi_money_saved;
            HALF: 
                case(pi_money_saved)
                    2'b01: po_money <= 2'b10;
                    2'b10: po_money <= 2'b11;
                    default: po_money <= 2'b10;
                endcase
            ONE:
                case(pi_money_saved)
                    2'b01: po_money <= 2'b11;
                    2'b10: po_money <= 2'b00;
                    default: po_money <= 2'b11;
                endcase
            ONE_HALF:
                case(pi_money_saved)
                    2'b01: po_money <= 2'b00;
                    2'b10: po_money <= 2'b01;
                    default: po_money <= 2'b00;
                endcase
            default: po_money <= 2'b00;
        endcase
    end
    else if((state == ONE_HALF) && (pi_money == 2'b10))
        po_money <= 2'b01;
    else
        po_money <= 2'b00;


assign {po_money_one, po_money_half} = po_money;

endmodule