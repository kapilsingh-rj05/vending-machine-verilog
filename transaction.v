//FSM
module transaction(
    input clk,
    input[3:0] amount,
    input reset,
    output reg out,
    output reg[3:0] change
);

    parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;

    reg[1:0] state, next_state;

    //state transition
    always@(*) begin
        case(state)
            S0: begin
                if(amount==4'd0) begin
                    next_state = S0;
                    change = 4'd0;
                    out = 1'b0;
                end
                else if(amount==4'd5) begin
                    next_state = S1;
                    change = 4'd0;
                    out = 0;
                end
                else if(amount==4'd10) begin
                    next_state = S2;
                    change = 4'd0;
                    out = 0;
                end
            end
            S1: begin
                if(amount==4'd0) begin
                    next_state = S0;
                    change = 4'd5;
                    out = 0;
                end
                else if(amount==4'd5) begin
                    next_state = S2;
                    change = 4'd0;
                    out = 0;
                end
                else if(amount==4'd10) begin
                    next_state = S0;
                    change = 4'd0;
                    out = 1;
                end
            end
            S2: begin
                if(amount==4'd0) begin
                    next_state = S0;
                    change = 4'd10;
                    out = 0;
                end
                else if(amount==4'd5) begin
                    next_state = S0;
                    change = 4'd0;
                    out = 1;
                end
                else if(amount==4'd10) begin
                    next_state = S0;
                    change = 4'd5;
                    out = 1;
                end
            end
        endcase
    end

    always@(posedge clk or negedge reset) begin
        if(!reset) begin
            state <= S0;
        end
        else begin
            state <= next_state;
        end
    end

endmodule