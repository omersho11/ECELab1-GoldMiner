module ScoreCounterWrapper (
    input  logic clk,
    input  logic resetN,
    input  logic [19:0] increase,
	 
    output logic [19:0] value
);
    import GlobalsPKG::*; 

    Counter #(
        .WIDTH($bits(SCORE)) 
    ) counter_inst (
        .clk(clk),
        .resetN(resetN),
        .increase(increase),
        .decrease(20'd0),
        .value(value)
    );
endmodule