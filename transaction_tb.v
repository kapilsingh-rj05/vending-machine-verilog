`include "transaction.v"

module transaction_tb();

    reg clk;
    reg[3:0] amount;
    reg reset;
    wire out;
    wire[3:0] change;

    transaction uut(.clk(clk), .amount(amount), .reset(reset), .out(out), .change(change));

    initial begin
        clk = 0;
    end

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

    initial begin
        reset = 0;
        #6 reset = 1; amount = 4'd5;
        #10 amount = 4'd5;
        #10 amount = 4'd10;
        #10 amount = 4'd0;
        #100 $finish;
    end

endmodule