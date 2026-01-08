module MoneyCounterWrapper (
    input  logic clk,
    input  logic resetN,
    
    input  logic [19:0] increaseAmount, 
    input  logic [19:0] decreaseAmount,    
    input  logic shopPulse,
    
    output logic [19:0] currentMoney
);

    import GlobalsPKG::*;

    logic [19:0] activeDecrease;
    assign activeDecrease = (shopPulse) ? decreaseAmount : 20'd0;

    Counter #(
        .WIDTH($bits(MONEY))
    ) internal_counter (
        .clk(clk),
        .resetN(resetN),
        .increase(increaseAmount),
        .decrease(activeDecrease),
        .value(currentMoney)
    );

endmodule