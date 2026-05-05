module vending_all_in_one (
    input clk,              // 100 MHz
    input rst_btn,
    input insert_btn,
    input select_btn,
    input [1:0] coin_sw,
    input [1:0] item_sw,

    output reg dispense_led,
    output reg [4:0] change_led,
    output reg [1:0] item_led
);

    // ================= CLOCK DIVIDER =================
    reg [22:0] clk_count = 0;
    reg slow_clk = 0;

    always @(posedge clk) begin
        if (clk_count == 5000000) begin
            clk_count <= 0;
            slow_clk <= ~slow_clk;
        end else
            clk_count <= clk_count + 1;
    end

    // ================= DEBOUNCE =================
    reg [3:0] rst_shift=0, ins_shift=0, sel_shift=0;
    reg rst, insert, select;

    always @(posedge slow_clk) begin
        rst_shift <= {rst_shift[2:0], rst_btn};
        ins_shift <= {ins_shift[2:0], insert_btn};
        sel_shift <= {sel_shift[2:0], select_btn};

        rst    <= (rst_shift == 4'b1111);
        insert <= (ins_shift == 4'b1111);
        select <= (sel_shift == 4'b1111);
    end

    // ================= FSM =================
   // parameter TEA=10, COFFEE=15, SAMOSA=20, CHIPS=25;
    parameter TEA=5, COFFEE=5, SAMOSA=10, CHIPS=2;
    parameter IDLE=0, ADD=1, DISP=2;

    reg [1:0] state = IDLE;
    reg [5:0] balance = 0;

    // coin decode
    function [4:0] coin_val;
        input [1:0] c;
        case(c)
            2'b00: coin_val=1;
            2'b01: coin_val=2;
            2'b10: coin_val=5;
            2'b11: coin_val=10;
        endcase
    endfunction

    // price decode
    function [5:0] price;
        input [1:0] s;
        case(s)
            2'b00: price=TEA;
            2'b01: price=COFFEE;
            2'b10: price=SAMOSA;
            2'b11: price=CHIPS;
        endcase
    endfunction

    // FSM operation
    always @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            balance <= 0;
            dispense_led <= 0;
            change_led <= 0;
        end else begin
            dispense_led <= 0;

            case(state)
                IDLE: begin
                    balance <= 0;
                    if (insert)
                        state <= ADD;
                end

                ADD: begin
                    if (insert)
                        balance <= balance + coin_val(coin_sw);

                    if (select)
                        state <= DISP;
                end
                
                DISP: begin
                    if (balance >= price(item_sw)) begin
                        dispense_led <= 1;
                        item_led <= item_sw;
                        change_led <= balance - price(item_sw);
                    end else begin
                        change_led <= balance;
                    end
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule